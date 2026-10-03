#!/usr/bin/env bash
# Lab 04, Step 1 — create the workload the recovery targets will protect.
#
# Creates: one RDS for PostgreSQL instance (single-AZ on purpose), one security
#          group allowing this machine to reach the database port, and one run
#          state file so the later scripts agree on identifiers.
#
# Deliberately absent: Multi-AZ (a standby instance roughly doubles instance
# cost), a customer-managed KMS key (RDS encrypts at rest with the AWS managed
# key by default), Performance Insights, CloudWatch log exports, a load balancer
# and a NAT gateway. None of them is needed to learn restore verification.
#
# If you do add a customer-managed key later, `aws kms schedule-key-deletion`
# leaves it pending for at least 7 days and the key keeps billing until deletion
# completes. That is a reason not to create one here.
#
# Required environment:
#   AWS_PROFILE   authorized playground or personal-account profile
# Optional environment:
#   AWS_REGION            default us-east-1
#   LAB_DR_REGION         default us-west-2, used by step 08
#   LAB_INSTANCE_CLASS    default db.t3.micro
#   LAB_BACKUP_LEAD_SECONDS  default 900; how far ahead the backup window is set
#   PUBLIC_IP             override the auto-detected /32 for the SG rule
#   SKIP_INGRESS=1        create no ingress rule (no SQL from this machine)
#   BACKUP_WINDOW / MAINTENANCE_WINDOW  override the computed windows
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/lab04.sh
. "$SCRIPT_DIR/lib/lab04.sh"

lab_need_profile
lab_need_cmd aws
[[ -n "${AWS_PROFILE:-}" ]] || lab_die "set AWS_PROFILE to the authorized profile before running"

LAB_RUN_SUFFIX="$(lab_new_suffix)"
LAB_REGION="$AWS_REGION"
LAB_DR_REGION="${LAB_DR_REGION:-us-west-2}"
LAB_DB_USER="labadmin"
LAB_DB_NAME="postgres"
LAB_INSTANCE_CLASS="${LAB_INSTANCE_CLASS:-db.t3.micro}"
LAB_ENGINE="postgres"
LAB_ALLOCATED_STORAGE=20
LAB_PORT=5432
LAB_TAG_KEY="soa-c03-lab04"
LAB_TAG_VALUE="$LAB_RUN_SUFFIX"
export LAB_DB_USER LAB_DB_NAME

# 20 characters from [A-Za-z0-9] only: no quoting hazards in the run file and no
# character RDS rejects in a master password (it rejects / " and @).
PW_RAW="$(LC_ALL=C head -c 128 /dev/urandom | LC_ALL=C tr -dc 'A-Za-z0-9')"
LAB_DB_PASSWORD="$(printf '%s' "$PW_RAW" | cut -c1-20)"
[[ ${#LAB_DB_PASSWORD} -eq 20 ]] || lab_die "could not generate a master password"
export LAB_DB_PASSWORD

echo "== Step 0: identity, region, and what this run will be called =="
aws sts get-caller-identity
echo "region:               $LAB_REGION"
echo "cross-Region partner: $LAB_DR_REGION (used in step 08)"
echo "instance class:       $LAB_INSTANCE_CLASS"
echo "run suffix:           $LAB_RUN_SUFFIX"
echo "identifiers are per-run, so a second run cannot collide with this one."

echo
echo "== Confirming the engine is available here =="
aws rds describe-db-engine-versions --engine "$LAB_ENGINE" --default-only \
  --query 'DBEngineVersions[0].{Engine:Engine,Version:EngineVersion}' --output table

echo
echo "== Computing the backup and maintenance windows =="
WINDOW_LINE="$(lab_compute_windows)"
LAB_BACKUP_DAY="$(printf '%s' "$WINDOW_LINE" | cut -d' ' -f1)"
LAB_BACKUP_WINDOW="$(printf '%s' "$WINDOW_LINE" | cut -d' ' -f2)"
# RDS wants the maintenance window as ddd:hh:mm-ddd:hh:mm, so the day prefix goes
# on both ends of the HH:MM-HH:MM range that lab_compute_windows prints.
MAINT_FROM="$(printf '%s' "$WINDOW_LINE" | cut -d' ' -f3 | cut -d'-' -f1)"
MAINT_TO="$(printf '%s' "$WINDOW_LINE" | cut -d' ' -f3 | cut -d'-' -f2)"
LAB_MAINTENANCE_WINDOW="$LAB_BACKUP_DAY:$MAINT_FROM-$LAB_BACKUP_DAY:$MAINT_TO"
echo "  backup window:      $LAB_BACKUP_WINDOW (UTC)"
echo "  maintenance window: $LAB_MAINTENANCE_WINDOW (UTC)"
echo
echo "  The backup window is deliberately only minutes away, so the first automated"
echo "  backup lands during this session and point-in-time recovery is testable now."
echo "  Step 07 confirms that it actually happened rather than assuming it."

lab_names
echo
echo "  instance:  $LAB_PRIMARY"
echo "  snapshot:  $LAB_SNAPSHOT"
echo "  security group: $LAB_SG"

echo
echo "== Creating the security group =="
VPC_ID="$(aws ec2 describe-vpcs --filters Name=isDefault,Values=true \
  --query 'Vpcs[0].VpcId' --output text 2>/dev/null || echo None)"
if [[ "$VPC_ID" == "None" || -z "$VPC_ID" ]]; then
  lab_die "this account/region has no default VPC; RDS needs a VPC plus a DB subnet group. Stop here and create one, or run this lab in another region."
fi
echo "  default VPC: $VPC_ID"

aws ec2 create-security-group --group-name "$LAB_SG" \
  --description "SOA-C03 lab 04 RDS ingress (disposable)" --vpc-id "$VPC_ID" \
  --tag-specifications "ResourceType=security-group,Tags=[{Key=Name,Value=${LAB_SG}},{Key=${LAB_TAG_KEY},Value=${LAB_TAG_VALUE}}]" \
  --query 'GroupId' --output text

if [[ "${SKIP_INGRESS:-0}" != "1" ]]; then
  MY_IP="$(lab_public_ip)"
  echo "  opening ${LAB_PORT}/tcp to ${MY_IP}/32 (this machine only, no 0.0.0.0/0)"
  aws ec2 authorize-security-group-ingress --group-name "$LAB_SG" \
    --ip-permissions "IpProtocol=tcp,FromPort=${LAB_PORT},ToPort=${LAB_PORT},IpRanges=[{CidrIp=${MY_IP}}]"
else
  echo "  SKIP_INGRESS=1: no rule added, so steps 02-08 cannot run SQL against it"
fi

echo
echo "== Creating the DB instance =="
echo "  single-AZ on purpose: Multi-AZ is a separate mechanism to a separate"
echo "  disaster, and a standby instance roughly doubles the instance cost."
aws rds create-db-instance \
  --db-instance-identifier "$LAB_PRIMARY" \
  --db-instance-class "$LAB_INSTANCE_CLASS" \
  --engine "$LAB_ENGINE" \
  --allocated-storage "$LAB_ALLOCATED_STORAGE" \
  --storage-type gp3 \
  --master-username "$LAB_DB_USER" \
  --master-user-password "$LAB_DB_PASSWORD" \
  --db-name "$LAB_DB_NAME" \
  --port "$LAB_PORT" \
  --no-multi-az \
  --no-deletion-protection \
  --publicly-accessible \
  --backup-retention-period 1 \
  --preferred-backup-window "$LAB_BACKUP_WINDOW" \
  --preferred-maintenance-window "$LAB_MAINTENANCE_WINDOW" \
  --vpc-security-group-ids "$LAB_SG" \
  --tags "Key=Name,Value=${LAB_PRIMARY}" "Key=${LAB_TAG_KEY},Value=${LAB_TAG_VALUE}" \
  --query 'DBInstance.{Id:DBInstanceIdentifier,Status:DBInstanceStatus,AZ:AvailabilityZone,MultiAZ:MultiAZ,StorageType:StorageType,Encryption:StorageEncryptionType}' \
  --output table

lab_save
lab_wait_instance "$LAB_PRIMARY" "primary" 1800

LAB_PRIMARY_ENDPOINT="$(aws rds describe-db-instances --db-instance-identifier "$LAB_PRIMARY" \
  --query 'DBInstances[0].Endpoint.Address' --output text)"
LAB_PRIMARY_PORT="$(aws rds describe-db-instances --db-instance-identifier "$LAB_PRIMARY" \
  --query 'DBInstances[0].Endpoint.Port' --output text)"
echo "  endpoint: $LAB_PRIMARY_ENDPOINT:$LAB_PRIMARY_PORT"
echo
echo "  This is the whole primary. Note what describe-db-instances can already tell"
echo "  you, before anything has gone wrong:"
aws rds describe-db-instances --db-instance-identifier "$LAB_PRIMARY" \
  --query 'DBInstances[0].{Id:DBInstanceIdentifier,Status:DBInstanceStatus,AZ:AvailabilityZone,SecondaryAZ:SecondaryAvailabilityZone,MultiAZ:MultiAZ,BackupWindow:PreferredBackupWindow,Retention:BackupRetentionPeriod,LatestRestorableTime:LatestRestorableTime,Encryption:StorageEncryptionType,StorageType:StorageType}' \
  --output table

lab_save

cat <<EOF

== Created. Continue with the lab README ==

  Step 2   ./cli/02-seed.sh            create the table and 20 known rows
  Step 3   ./cli/03-snapshot.sh        manual snapshot, and record its age
  Step 4   ./cli/04-poison.sh          the bad write you will recover from
  Step 5   ./cli/05-restore-and-time.sh    time a restore against your RTO claim

  Teardown: ./cli/99-teardown.sh

  No AWS resource was created outside this run's identifier prefix
  (soa-c03-lab04-*-${LAB_RUN_SUFFIX}) and its tagged security group.
EOF
