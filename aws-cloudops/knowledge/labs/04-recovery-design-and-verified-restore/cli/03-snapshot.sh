#!/usr/bin/env bash
# Lab 04, Step 3 — take one manual snapshot and record how old it is.
#
# Two separate facts are established here, and the difference between them is
# the RPO:
#   * the snapshot's own age when you decide to restore (a data-freshness number)
#   * when it was taken (SnapshotCreateTime), which is what a restore actually
#     restores to
# Both are printed. Neither is the RTO, and confusing them is the usual mistake.
#
# This script also reports whether the first AUTOMATED backup has happened yet,
# because step 07 needs one and cannot assume it. Automated backups are what
# extend the point-in-time-recovery window; a manual snapshot does not.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/lab04.sh
. "$SCRIPT_DIR/lib/lab04.sh"

lab_need_profile
lab_require_run
lab_load
lab_names

echo "== Current restorable window on the primary =="
aws rds describe-db-instances --db-instance-identifier "$LAB_PRIMARY" \
  --query 'DBInstances[0].{Id:DBInstanceIdentifier,BackupWindow:PreferredBackupWindow,Retention:BackupRetentionPeriod,LatestRestorableTime:LatestRestorableTime}' \
  --output table

echo
echo "== Has the first automated backup finished? =="
echo "  (reading the backup events rather than assuming; RDS emits these messages"
echo "   for 'Backing up DB instance' and 'Finished DB Instance backup')"
aws rds describe-events --source-identifier "$LAB_PRIMARY" --source-type db-instance \
  --duration 6 --query 'Events[].{Date:Date,Message:Message}' --output table

echo
echo "== Creating the manual snapshot $LAB_SNAPSHOT =="
if aws rds describe-db-snapshots --db-snapshot-identifier "$LAB_SNAPSHOT" \
     --query 'DBSnapshots[0].DBSnapshotIdentifier' --output text 2>/dev/null | grep -q "$LAB_SNAPSHOT"; then
  echo "  $LAB_SNAPSHOT already exists; not creating a second one."
else
  aws rds create-db-snapshot \
    --db-instance-identifier "$LAB_PRIMARY" \
    --db-snapshot-identifier "$LAB_SNAPSHOT" \
    --tags "Key=Name,Value=${LAB_SNAPSHOT}" "Key=${LAB_TAG_KEY},Value=${LAB_TAG_VALUE}" \
    --query 'DBSnapshot.{Id:DBSnapshotIdentifier,Status:Status,Engine:Engine,AllocatedStorage:AllocatedStorage}' \
    --output table
fi

lab_wait_snapshot "$LAB_SNAPSHOT" "snapshot" 1800

echo
echo "== Snapshot facts =="
printf '  %-22s %s\n' "id"         "$(lab_snap_field "$LAB_SNAPSHOT" DBSnapshotIdentifier)"
printf '  %-22s %s\n' "type"       "$(lab_snap_field "$LAB_SNAPSHOT" SnapshotType)"
printf '  %-22s %s\n' "created"    "$(lab_snap_field "$LAB_SNAPSHOT" SnapshotCreateTime)"
printf '  %-22s %s\n' "status"     "$(lab_snap_field "$LAB_SNAPSHOT" Status)"
printf '  %-22s %s\n' "storage GiB" "$(lab_snap_field "$LAB_SNAPSHOT" AllocatedStorage)"
printf '  %-22s %s\n' "az"         "$(lab_snap_field "$LAB_SNAPSHOT" AvailabilityZone)"
printf '  %-22s %s\n' "encrypted"  "$(lab_snap_field "$LAB_SNAPSHOT" Encrypted)"

LAB_SNAPSHOT_TIME="$(lab_snap_field "$LAB_SNAPSHOT" SnapshotCreateTime)"
LAB_SNAPSHOT_EPOCH="$(lab_epoch_from_iso "$LAB_SNAPSHOT_TIME" || true)"
if [[ -z "$LAB_SNAPSHOT_EPOCH" ]]; then
  lab_die "could not read SnapshotCreateTime ('$LAB_SNAPSHOT_TIME'); record it by hand from the Console before step 5"
fi
NOW="$(lab_epoch)"
lab_save

echo
echo "  snapshot taken at : $LAB_SNAPSHOT_TIME UTC (epoch $LAB_SNAPSHOT_EPOCH)"
echo "  now                : $(lab_iso_from_epoch "$NOW") UTC (epoch $NOW)"
echo "  snapshot age now   : $(( NOW - LAB_SNAPSHOT_EPOCH ))s"
echo
echo "  If you decided to restore right now, the data you could recover would be"
echo "  up to $(( NOW - LAB_SNAPSHOT_EPOCH ))s old. That number is the RPO this snapshot"
echo "  offers at this instant. It grows by one second every second — nothing about"
echo "  the snapshot itself improves, and no alarm will tell you."

cat <<'EOF'

  Continue with ./cli/04-poison.sh
EOF
