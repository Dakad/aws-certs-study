#!/usr/bin/env bash
# Lab 04, Step 5 — restore the snapshot and time it against your RTO claim.
#
# This is the spine of the lab. A restore is not done when AWS says `available`;
# it is done when the database answers and the data is proven correct. The script
# times both and prints them separately, because collapsing them into one number
# is exactly the mistake an RTO claim hides.
#
# It also refuses to run while a previous restore target still exists, so
# repeating the measurement costs one instance's runtime and not a second one.
#
# Environment:
#   RESTORE_LABEL   free text for the run file's LAB_RESTORE_TARGET_LABEL
#   KEEP_RESTORED=1 do not print the delete hint at the end
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/lab04.sh
. "$SCRIPT_DIR/lib/lab04.sh"

lab_need_profile
lab_require_run
lab_load
lab_names
RESTORE_LABEL="${RESTORE_LABEL:-snapshot-$LAB_SNAPSHOT}"

echo "== What is about to be restored, and what it will contain =="
echo "  source snapshot : $LAB_SNAPSHOT"
echo "  taken at        : $LAB_SNAPSHOT_TIME UTC"
echo "  target instance : $LAB_RESTORED"
echo
echo "  A restore creates a NEW instance beside the damaged one. That is the"
echo "  'isolate' part of a restore plan: nothing is overwritten, so the original"
echo "  evidence survives. Traffic is not moved here, and a real plan would have to"
echo "  define that cut-over separately."

EXISTING="$(lab_instance_field "$LAB_RESTORED" DBInstanceIdentifier)"
if [[ "$EXISTING" != "None" && -n "$EXISTING" ]]; then
  echo
  echo "  $LAB_RESTORED already exists, which would both cost money and hide which"
  echo "  restore you were timing. Delete it first:"
  echo "    aws rds delete-db-instance --db-instance-identifier $LAB_RESTORED --skip-final-snapshot"
  exit 1
fi

echo
echo "== T0: the moment the restore is requested =="
echo "  T0 is a decision time, not a failure time. A real RTO also has to absorb"
echo "  detection time and the human or automation that decides to restore. Add"
echo "  those from your own numbers; this script cannot measure them."
LAB_RESTORE_REQUEST_EPOCH="$(lab_epoch)"
echo "  T0 = $LAB_RESTORE_REQUEST_EPOCH ($(lab_iso_from_epoch "$LAB_RESTORE_REQUEST_EPOCH"))"

echo
echo "== Requesting the restore =="
aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier "$LAB_RESTORED" \
  --db-snapshot-identifier "$LAB_SNAPSHOT" \
  --db-instance-class "${LAB_INSTANCE_CLASS:-db.t3.micro}" \
  --no-multi-az \
  --no-deletion-protection \
  --publicly-accessible \
  --vpc-security-group-ids "$LAB_SG" \
  --tags "Key=Name,Value=${LAB_RESTORED}" "Key=${LAB_TAG_KEY},Value=${LAB_TAG_VALUE}" \
  --query 'DBInstance.{Id:DBInstanceIdentifier,Status:DBInstanceStatus}' --output table

if ! lab_wait_instance "$LAB_RESTORED" "restored instance" "${RESTORE_TIMEOUT:-2400}"; then
  echo
  echo "  The restore did not reach available. Do not delete it yet: its status and"
  echo "  events are the only evidence of how far it got, and they are what you would"
  echo "  be reading at 03:00 during a real incident."
  echo "    aws rds describe-db-instances --db-instance-identifier $LAB_RESTORED"
  echo "    aws rds describe-events --source-identifier $LAB_RESTORED --source-type db-instance --duration 6"
  exit 1
fi

LAB_RESTORE_AVAILABLE_EPOCH="$(lab_epoch)"
LAB_RESTORE_ELAPSED_AVAILABLE=$(( LAB_RESTORE_AVAILABLE_EPOCH - LAB_RESTORE_REQUEST_EPOCH ))
echo
echo "  control-plane elapsed: ${LAB_RESTORE_ELAPSED_AVAILABLE}s to report 'available'"

REST_ENDPOINT="$(lab_instance_field "$LAB_RESTORED" Endpoint.Address)"
REST_PORT="$(lab_instance_field "$LAB_RESTORED" Endpoint.Port)"
echo "  endpoint: $REST_ENDPOINT:$REST_PORT"

echo
echo "== Waiting until it actually answers a query =="
if lab_wait_sql "$REST_ENDPOINT" "$REST_PORT" "restored instance" "${SQL_TIMEOUT:-900}"; then
  LAB_RESTORE_SQL_EPOCH="$(lab_epoch)"
  LAB_RESTORE_ELAPSED_SQL=$(( LAB_RESTORE_SQL_EPOCH - LAB_RESTORE_REQUEST_EPOCH ))
  echo "  usable elapsed:       ${LAB_RESTORE_ELAPSED_SQL}s from T0"
else
  lab_die "instance is available but never answered a query, so the RTO is unmet at any value; the data has not been proven"
fi

LAB_RESTORE_TARGET_LABEL="$RESTORE_LABEL"
lab_save

echo
echo "== Timed result =="
printf '  %-38s %s\n' "snapshot age at T0 (data freshness)" \
  "$(( LAB_RESTORE_REQUEST_EPOCH - LAB_SNAPSHOT_EPOCH ))s"
printf '  %-38s %s\n' "T0 -> available (control plane)" \
  "${LAB_RESTORE_ELAPSED_AVAILABLE}s"
printf '  %-38s %s\n' "T0 -> answers a query (usable)" "${LAB_RESTORE_ELAPSED_SQL}s"
echo
echo "  Only the third line is a candidate for an RTO. The first line is an RPO"
echo "  number. Compare all three against what you wrote in the Step 1 worksheet."

echo
echo "== Verifying the restored copy =="
if lab_verify_data "$REST_ENDPOINT" "$REST_PORT" \
     "$LAB_SEED_ROWS" "0" "$LAB_SEED_FIRST5" "$LAB_SEED_SUM" "$LAB_SEED_NEWEST_GOOD"; then
  echo
  echo "  Proven: the restored copy has the pre-incident rows, the checksum matches,"
  echo "  and the poison row is absent. This is a recovery, not a guess."
else
  echo
  echo "  The restore completed but the data is not what you claimed to recover."
  echo "  An available database with the wrong contents is not a recovery."
  exit 1
fi

cat <<EOF

  Keep this instance while you do step 07 if you want to compare the two recovery
  points side by side. It bills until it is deleted.

  When you are done with it:
    aws rds delete-db-instance --db-instance-identifier $LAB_RESTORED \\
      --skip-final-snapshot --delete-automated-backups
EOF
