#!/usr/bin/env bash
# Lab 04, Step 99 — full cleanup in dependency-aware order.
#
# Deletes every resource created by steps 01-08. The script tolerates missing
# identifiers (a step may not have run) and exits non-zero if any resource
# tagged soa-c03-lab04 remains after the pass.
#
# Order (dependencies first):
#   08. measurement only — no persistent resources
#   07. cross-Region replica (delete in DR region)
#   06. PITR instance
#   05. snapshot restore instance
#   04. no persistent resources
#   03. manual snapshot
#   02. no persistent resources
#   01. primary DB instance, security group, KMS key (if created), VPC
#
# Final verification: query all resource types by tag. Print "clean" only if
# zero remain; exit non-zero otherwise.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/lab04.sh
. "$SCRIPT_DIR/lib/lab04.sh"

lab_need_profile

RUN_FILE="${LAB_RUN_FILE:-$SCRIPT_DIR/.env.lab04-run}"

# Load identifiers if the run file exists; tolerate missing.
if [ -f "$RUN_FILE" ]; then
  # shellcheck disable=SC1090
  . "$RUN_FILE"
fi

LAB_TAG_KEY="${LAB_TAG_KEY:-soa-c03-lab04}"
LAB_TAG_VALUE="${LAB_TAG_VALUE:-}"
LAB_REGION="${LAB_REGION:-${AWS_REGION:-us-east-1}}"
LAB_DR_REGION="${LAB_DR_REGION:-us-west-2}"

echo "== Teardown starting =="
echo "  run file: $RUN_FILE"
echo "  primary region: $LAB_REGION"
echo "  DR region: $LAB_DR_REGION"
echo "  tag filter: ${LAB_TAG_KEY}=${LAB_TAG_VALUE:-'*'}"

# ---------------------------------------------------------------------------
# Helper: delete an RDS instance and wait for it to be gone.
# Uses the waiter `db-instance-deleted` which is bounded (~10 min).
# If the instance does not exist, logs and continues.
delete_db_instance() {
  local id="$1" region="$2" label="$3"
  echo "  deleting $label: $id (region $region)"
  if aws rds describe-db-instances --db-instance-identifier "$id" --region "$region" >/dev/null 2>&1; then
    aws rds delete-db-instance --db-instance-identifier "$id" \
      --skip-final-snapshot --delete-automated-backups --region "$region" >/dev/null
    echo "    waiting for deletion..."
    if aws rds wait db-instance-deleted --db-instance-identifier "$id" --region "$region" 2>/dev/null; then
      echo "    deleted"
    else
      echo "    waiter timed out or failed; check Console"
    fi
  else
    echo "    not found (already gone or never created)"
  fi
}

# Helper: delete a DB snapshot if it exists.
delete_db_snapshot() {
  local id="$1" region="$2" label="$3"
  echo "  deleting $label: $id (region $region)"
  if aws rds describe-db-snapshots --db-snapshot-identifier "$id" --region "$region" >/dev/null 2>&1; then
    aws rds delete-db-snapshot --db-snapshot-identifier "$id" --region "$region" >/dev/null
    echo "    deleted"
  else
    echo "    not found"
  fi
}

# Helper: delete a security group if it exists and is not the default.
delete_sg() {
  local id="$1" region="$2" label="$3" vpc_id="$4"
  echo "  deleting $label: $id (region $region)"
  if aws ec2 describe-security-groups --group-ids "$id" --region "$region" >/dev/null 2>&1; then
    # Revoke any non-default ingress rules first (best effort)
    aws ec2 revoke-security-group-ingress --group-id "$id" --region "$region" \
      --ip-permissions "$(aws ec2 describe-security-groups --group-ids "$id" --region "$region" \
        --query 'SecurityGroups[0].IpPermissions' --output json 2>/dev/null || echo '[]')" 2>/dev/null || true
    aws ec2 delete-security-group --group-id "$id" --region "$region" 2>/dev/null && echo "    deleted" || echo "    delete failed (may have dependencies)"
  else
    echo "    not found"
  fi
}

# Helper: schedule KMS key deletion (7-day minimum).
schedule_kms_key_deletion() {
  local key_id="$1" region="$2" label="$3"
  echo "  scheduling deletion for $label: $key_id (region $region)"
  if [ -n "$key_id" ] && [ "$key_id" != "None" ]; then
    aws kms schedule-key-deletion --key-id "$key_id" --pending-window-in-days 7 --region "$region" >/dev/null 2>&1 \
      && echo "    scheduled (7-day window)" || echo "    already pending or not found"
  else
    echo "    no key ID recorded"
  fi
}

# ---------------------------------------------------------------------------
# Step 08: no persistent resources
echo
echo "== Step 08 (measurement) — no persistent resources to delete =="

# ---------------------------------------------------------------------------
# Step 07: cross-Region replica
echo
echo "== Step 07: cross-Region replica =="
if [ -n "${LAB_REPLICA:-}" ]; then
  delete_db_instance "$LAB_REPLICA" "$LAB_DR_REGION" "cross-region replica"
fi
if [ -n "${LAB_DR_SG:-}" ]; then
  DR_VPC_ID="$(aws ec2 describe-vpcs --filters Name=isDefault,Values=true --region "$LAB_DR_REGION" --query 'Vpcs[0].VpcId' --output text 2>/dev/null || echo '')"
  delete_sg "$LAB_DR_SG" "$LAB_DR_REGION" "DR security group" "$DR_VPC_ID"
fi

# ---------------------------------------------------------------------------
# Step 06: PITR instance
echo
echo "== Step 06: PITR instance =="
if [ -n "${LAB_PITR:-}" ]; then
  delete_db_instance "$LAB_PITR" "$LAB_REGION" "PITR instance"
fi

# ---------------------------------------------------------------------------
# Step 05: snapshot restore instance
echo
echo "== Step 05: snapshot restore instance =="
if [ -n "${LAB_RESTORED:-}" ]; then
  delete_db_instance "$LAB_RESTORED" "$LAB_REGION" "snapshot restore instance"
fi

# ---------------------------------------------------------------------------
# Step 04: no persistent resources
echo
echo "== Step 04 (poison write) — no persistent resources =="

# ---------------------------------------------------------------------------
# Step 03: manual snapshot
echo
echo "== Step 03: manual snapshot =="
if [ -n "${LAB_SNAPSHOT:-}" ]; then
  delete_db_snapshot "$LAB_SNAPSHOT" "$LAB_REGION" "manual snapshot"
fi

# ---------------------------------------------------------------------------
# Step 02: no persistent resources
echo
echo "== Step 02 (seed) — no persistent resources =="

# ---------------------------------------------------------------------------
# Step 01: primary DB instance, security group, KMS key, VPC
echo
echo "== Step 01: primary resources =="
if [ -n "${LAB_PRIMARY:-}" ]; then
  delete_db_instance "$LAB_PRIMARY" "$LAB_REGION" "primary DB instance"
fi

if [ -n "${LAB_SG:-}" ]; then
  VPC_ID="$(aws ec2 describe-vpcs --filters Name=isDefault,Values=true --region "$LAB_REGION" --query 'Vpcs[0].VpcId' --output text 2>/dev/null || echo '')"
  delete_sg "$LAB_SG" "$LAB_REGION" "primary security group" "$VPC_ID"
fi

if [ -n "${LAB_KMS_KEY_ID:-}" ]; then
  schedule_kms_key_deletion "$LAB_KMS_KEY_ID" "$LAB_REGION" "KMS key"
fi

# VPC is not deleted here — it is the account's default VPC and shared.
# If you created a dedicated VPC for this lab, delete it manually after
# confirming no ENIs remain:
#   aws ec2 describe-network-interfaces --filters Name=vpc-id,Values=<vpc-id>
#   aws ec2 delete-vpc --vpc-id <vpc-id>

# ---------------------------------------------------------------------------
# Final verification: tag scan across resource types
echo
echo "== Final verification: scanning for resources tagged ${LAB_TAG_KEY}=${LAB_TAG_VALUE:-'*'} =="

LEFTOVER=0

# RDS instances in primary region
echo "  RDS instances (primary):"
aws rds describe-db-instances --region "$LAB_REGION" \
  --query "DBInstances[?TagList[?Key=='${LAB_TAG_KEY}' && Value=='${LAB_TAG_VALUE}']].{Id:DBInstanceIdentifier,Status:DBInstanceStatus}" \
  --output table 2>/dev/null || true
RDS_COUNT=$(aws rds describe-db-instances --region "$LAB_REGION" \
  --query "length(DBInstances[?TagList[?Key=='${LAB_TAG_KEY}' && Value=='${LAB_TAG_VALUE}']])" --output text 2>/dev/null || echo 0)
if [ "$RDS_COUNT" -gt 0 ]; then
  LEFTOVER=1
fi

# RDS instances in DR region
echo "  RDS instances (DR):"
aws rds describe-db-instances --region "$LAB_DR_REGION" \
  --query "DBInstances[?TagList[?Key=='${LAB_TAG_KEY}' && Value=='${LAB_TAG_VALUE}']].{Id:DBInstanceIdentifier,Status:DBInstanceStatus}" \
  --output table 2>/dev/null || true
DR_RDS_COUNT=$(aws rds describe-db-instances --region "$LAB_DR_REGION" \
  --query "length(DBInstances[?TagList[?Key=='${LAB_TAG_KEY}' && Value=='${LAB_TAG_VALUE}']])" --output text 2>/dev/null || echo 0)
if [ "$DR_RDS_COUNT" -gt 0 ]; then
  LEFTOVER=1
fi

# RDS snapshots
echo "  RDS snapshots:"
aws rds describe-db-snapshots --region "$LAB_REGION" \
  --query "DBSnapshots[?TagList[?Key=='${LAB_TAG_KEY}' && Value=='${LAB_TAG_VALUE}']].{Id:DBSnapshotIdentifier,Status:Status}" \
  --output table 2>/dev/null || true
SNAP_COUNT=$(aws rds describe-db-snapshots --region "$LAB_REGION" \
  --query "length(DBSnapshots[?TagList[?Key=='${LAB_TAG_KEY}' && Value=='${LAB_TAG_VALUE}']])" --output text 2>/dev/null || echo 0)
if [ "$SNAP_COUNT" -gt 0 ]; then
  LEFTOVER=1
fi

# Security groups
echo "  Security groups (primary):"
aws ec2 describe-security-groups --region "$LAB_REGION" \
  --filters "Name=tag:${LAB_TAG_KEY},Values=${LAB_TAG_VALUE}" \
  --query 'SecurityGroups[].{Id:GroupId,Name:GroupName}' --output table 2>/dev/null || true
SG_COUNT=$(aws ec2 describe-security-groups --region "$LAB_REGION" \
  --filters "Name=tag:${LAB_TAG_KEY},Values=${LAB_TAG_VALUE}" \
  --query 'length(SecurityGroups)' --output text 2>/dev/null || echo 0)
if [ "$SG_COUNT" -gt 0 ]; then
  LEFTOVER=1
fi

echo "  Security groups (DR):"
aws ec2 describe-security-groups --region "$LAB_DR_REGION" \
  --filters "Name=tag:${LAB_TAG_KEY},Values=${LAB_TAG_VALUE}" \
  --query 'SecurityGroups[].{Id:GroupId,Name:GroupName}' --output table 2>/dev/null || true
DR_SG_COUNT=$(aws ec2 describe-security-groups --region "$LAB_DR_REGION" \
  --filters "Name=tag:${LAB_TAG_KEY},Values=${LAB_TAG_VALUE}" \
  --query 'length(SecurityGroups)' --output text 2>/dev/null || echo 0)
if [ "$DR_SG_COUNT" -gt 0 ]; then
  LEFTOVER=1
fi

# KMS keys (only those with the tag; note: KMS tags are on the key, not aliases)
echo "  KMS keys (primary):"
aws kms list-keys --region "$LAB_REGION" --query 'Keys[].KeyId' --output text 2>/dev/null | tr '\t' '\n' | while read -r kid; do
  if [ -n "$kid" ]; then
    TAGS=$(aws kms list-resource-tags --key-id "$kid" --region "$LAB_REGION" --query "Tags[?Key=='${LAB_TAG_KEY}' && Value=='${LAB_TAG_VALUE}']" --output text 2>/dev/null || echo "")
    if [ -n "$TAGS" ]; then
      echo "    $kid (tagged)"
      LEFTOVER=1
    fi
  fi
done || true

# Also check the DR region for KMS keys (cross-region replica doesn't create one, but be thorough)
echo "  KMS keys (DR):"
aws kms list-keys --region "$LAB_DR_REGION" --query 'Keys[].KeyId' --output text 2>/dev/null | tr '\t' '\n' | while read -r kid; do
  if [ -n "$kid" ]; then
    TAGS=$(aws kms list-resource-tags --key-id "$kid" --region "$LAB_DR_REGION" --query "Tags[?Key=='${LAB_TAG_KEY}' && Value=='${LAB_TAG_VALUE}']" --output text 2>/dev/null || echo "")
    if [ -n "$TAGS" ]; then
      echo "    $kid (tagged)"
      LEFTOVER=1
    fi
  fi
done || true

echo
if [ "$LEFTOVER" -eq 0 ]; then
  echo "clean"
  exit 0
else
  echo "FAIL: resources with tag ${LAB_TAG_KEY}=${LAB_TAG_VALUE:-'*'} still exist. Inspect the output above." >&2
  exit 1
fi