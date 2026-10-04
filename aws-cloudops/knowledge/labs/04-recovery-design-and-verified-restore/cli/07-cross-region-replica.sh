#!/usr/bin/env bash
# Lab 04, Step 7 — create a cross-Region read replica in LAB_DR_REGION.
#
# This demonstrates the cross-Region disaster recovery path. The replica is
# created asynchronously; replication lag is measured in step 08. The replica
# can be promoted to a standalone primary in the DR region if the primary
# region is lost.
#
# Prerequisites:
#   - The primary DB instance must have automated backups enabled (backup
#     retention > 0), which step 01 does.
#   - The account must have permission to create RDS instances in LAB_DR_REGION.
#   - The DR region must have a default VPC or a DB subnet group; this script
#     creates a security group in the DR region's default VPC.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/lab04.sh
. "$SCRIPT_DIR/lib/lab04.sh"

lab_need_profile
lab_require_run
lab_load
lab_names

: "${LAB_DR_REGION:?run file is missing LAB_DR_REGION — set it in step 01 or export before running}"

echo "== Cross-Region read replica target =="
echo "  primary region : $LAB_REGION"
echo "  DR region      : $LAB_DR_REGION"
echo "  source DB      : $LAB_PRIMARY"
echo "  replica name   : $LAB_REPLICA"

aws rds describe-db-instances --db-instance-identifier "$LAB_PRIMARY" \
  --query 'DBInstances[0].{Id:DBInstanceIdentifier,Status:DBInstanceStatus,Engine:Engine,BackupRetention:BackupRetentionPeriod,MultiAZ:MultiAZ,LatestRestorable:LatestRestorableTime}' \
  --output table

EXISTING="$(aws rds describe-db-instances --db-instance-identifier "$LAB_REPLICA" --region "$LAB_DR_REGION" \
  --query 'DBInstances[0].DBInstanceIdentifier' --output text 2>/dev/null || echo None)"
if [[ "$EXISTING" != "None" && -n "$EXISTING" ]]; then
  echo
  echo "  $LAB_REPLICA already exists in $LAB_DR_REGION. Delete it first:"
  echo "    aws rds delete-db-instance --db-instance-identifier $LAB_REPLICA --skip-final-snapshot --region $LAB_DR_REGION"
  exit 1
fi

echo
echo "== Preparing the DR region security group =="
DR_VPC_ID="$(aws ec2 describe-vpcs --filters Name=isDefault,Values=true --region "$LAB_DR_REGION" \
  --query 'Vpcs[0].VpcId' --output text 2>/dev/null || echo None)"
if [[ "$DR_VPC_ID" == "None" || -z "$DR_VPC_ID" ]]; then
  lab_die "the DR region ($LAB_DR_REGION) has no default VPC; create a DB subnet group there first, or run in a region with a default VPC"
fi
echo "  DR default VPC: $DR_VPC_ID"

aws ec2 create-security-group --region "$LAB_DR_REGION" \
  --group-name "$LAB_DR_SG" \
  --description "SOA-C03 lab 04 cross-region replica ingress (disposable)" \
  --vpc-id "$DR_VPC_ID" \
  --tag-specifications "ResourceType=security-group,Tags=[{Key=Name,Value=${LAB_DR_SG}},{Key=${LAB_TAG_KEY},Value=${LAB_TAG_VALUE}}]" \
  --query 'GroupId' --output text

MY_IP="$(lab_public_ip)"
echo "  opening 5432/tcp to ${MY_IP}/32 in $LAB_DR_REGION"
aws ec2 authorize-security-group-ingress --region "$LAB_DR_REGION" \
  --group-name "$LAB_DR_SG" \
  --ip-permissions "IpProtocol=tcp,FromPort=5432,ToPort=5432,IpRanges=[{CidrIp=${MY_IP}}]"

echo
echo "== Creating the cross-Region read replica =="
REPLICA_REQUEST_EPOCH="$(lab_epoch)"
echo "  requested at: $REPLICA_REQUEST_EPOCH ($(lab_iso_from_epoch "$REPLICA_REQUEST_EPOCH"))"

aws rds create-db-instance-read-replica \
  --region "$LAB_DR_REGION" \
  --db-instance-identifier "$LAB_REPLICA" \
  --source-db-instance-identifier "$LAB_PRIMARY" \
  --db-instance-class "${LAB_INSTANCE_CLASS:-db.t3.micro}" \
  --no-multi-az \
  --no-deletion-protection \
  --publicly-accessible \
  --vpc-security-group-ids "$LAB_DR_SG" \
  --tags "Key=Name,Value=${LAB_REPLICA}" "Key=${LAB_TAG_KEY},Value=${LAB_TAG_VALUE}" "Key=Step,Value=07" \
  --query 'DBInstance.{Id:DBInstanceIdentifier,Status:DBInstanceStatus}' --output table

echo
echo "== Waiting for replica to become available in $LAB_DR_REGION =="
if ! lab_wait_instance "$LAB_REPLICA" "cross-region replica" "${REPLICA_TIMEOUT:-3600}"; then
  echo
  echo "  The replica did not reach available. Do not delete it yet:"
  echo "    aws rds describe-db-instances --db-instance-identifier $LAB_REPLICA --region $LAB_DR_REGION"
  echo "    aws rds describe-events --source-identifier $LAB_REPLICA --source-type db-instance --duration 6 --region $LAB_DR_REGION"
  exit 1
fi

REPLICA_AVAILABLE_EPOCH="$(lab_epoch)"
REPLICA_ELAPSED_AVAILABLE=$(( REPLICA_AVAILABLE_EPOCH - REPLICA_REQUEST_EPOCH ))

echo
echo "  control-plane elapsed: ${REPLICA_ELAPSED_AVAILABLE}s to report 'available'"

REPLICA_ENDPOINT="$(aws rds describe-db-instances --db-instance-identifier "$LAB_REPLICA" --region "$LAB_DR_REGION" \
  --query 'DBInstances[0].Endpoint.Address' --output text)"
REPLICA_PORT="$(aws rds describe-db-instances --db-instance-identifier "$LAB_REPLICA" --region "$LAB_DR_REGION" \
  --query 'DBInstances[0].Endpoint.Port' --output text)"
echo "  endpoint: $REPLICA_ENDPOINT:$REPLICA_PORT"

echo
echo "== Waiting until it actually answers a query =="
if lab_wait_sql "$REPLICA_ENDPOINT" "$REPLICA_PORT" "cross-region replica" "${SQL_TIMEOUT:-900}"; then
  REPLICA_SQL_EPOCH="$(lab_epoch)"
  REPLICA_ELAPSED_SQL=$(( REPLICA_SQL_EPOCH - REPLICA_REQUEST_EPOCH ))
  echo "  usable elapsed:       ${REPLICA_ELAPSED_SQL}s from request"
else
  lab_die "replica is available but never answered a query"
fi

echo
echo "== Replica status from the primary region's view =="
aws rds describe-db-instances --db-instance-identifier "$LAB_PRIMARY" \
  --query 'DBInstances[0].ReadReplicaDBInstanceIdentifiers' --output table

aws rds describe-db-instances --db-instance-identifier "$LAB_REPLICA" --region "$LAB_DR_REGION" \
  --query 'DBInstances[0].{Id:DBInstanceIdentifier,Status:DBInstanceStatus,ReplicaMode:ReadReplicaSourceDBInstanceIdentifier,ReplicaStatus:ReadReplicaDBClusterIdentifiers}' --output table

echo
echo "== Initial replication lag (CloudWatch, last 5 min, 1-min periods) =="
aws cloudwatch get-metric-statistics --region "$LAB_DR_REGION" \
  --namespace AWS/RDS --metric-name ReplicaLag \
  --dimensions Name=DBInstanceIdentifier,Value="$LAB_REPLICA" \
  --start-time "$(date -u -d '5 minutes ago' +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -v-5M +%Y-%m-%dT%H:%M:%SZ)" \
  --end-time "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --period 60 --statistics Average \
  --query 'Datapoints[].{Time:Timestamp,Value:Average}' --output table || echo "  no ReplicaLag datapoints yet (replica may be too new)"

LAB_DR_REPLICA_ENDPOINT="$REPLICA_ENDPOINT"
lab_save

cat <<EOF

== Cross-Region replica created ==

  replica endpoint: $LAB_DR_REPLICA_ENDPOINT:$REPLICA_PORT
  provisioning time: ${REPLICA_ELAPSED_SQL}s from request to usable

  The replica is now asynchronously replicating from the primary. Any writes to
  the primary will appear on the replica after the replication lag. Step 08
  stresses this and measures the catch-up time.

  Next: ./cli/08-replication-lag.sh

  To promote the replica (making it a standalone primary in the DR region):
    aws rds promote-read-replica --db-instance-identifier $LAB_REPLICA --region $LAB_DR_REGION
EOF