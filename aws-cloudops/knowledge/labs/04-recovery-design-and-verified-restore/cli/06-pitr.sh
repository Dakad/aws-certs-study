#!/usr/bin/env bash
# Lab 04, Step 6 — point-in-time recovery to the moment before the bad write.
#
# Restores the primary DB instance to a new instance using the automated
# backup's point-in-time window, targeting LAB_BAD_WRITE_TIME (recorded in
# step 04). This demonstrates that automated backups provide a second recovery
# path with a different RPO than a manual snapshot.
#
# The target time is LAB_BAD_WRITE_TIME minus a small lead (default 60s) to
# ensure the restore lands cleanly before the poison write. The lead can be
# overridden with LAB_PITR_LEAD_SECONDS.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/lab04.sh
. "$SCRIPT_DIR/lib/lab04.sh"

lab_need_profile
lab_require_run
lab_load
lab_names

: "${LAB_BAD_WRITE_TIME:?run file is missing LAB_BAD_WRITE_TIME — run step 04 first}"
: "${LAB_BAD_WRITE_EPOCH:?run file is missing LAB_BAD_WRITE_EPOCH — run step 04 first}"

LEAD="${LAB_PITR_LEAD_SECONDS:-60}"
LAB_PITR_TARGET_EPOCH=$(( LAB_BAD_WRITE_EPOCH - LEAD ))
LAB_PITR_TARGET_TIME="$(lab_iso_from_epoch "$LAB_PITR_TARGET_EPOCH")"

echo "== Point-in-Time Recovery target =="
echo "  bad write at : $LAB_BAD_WRITE_TIME UTC (epoch $LAB_BAD_WRITE_EPOCH)"
echo "  target time  : $LAB_PITR_TARGET_TIME UTC (epoch $LAB_PITR_TARGET_EPOCH)"
echo "  lead         : ${LEAD}s before the bad write"
echo
echo "  This must fall inside the automated backup window. The primary's"
echo "  LatestRestorableTime is the ceiling; the restore will fail if the"
echo "  target is after it or before the first automated backup completed."

aws rds describe-db-instances --db-instance-identifier "$LAB_PRIMARY" \
  --query 'DBInstances[0].{Id:DBInstanceIdentifier,LatestRestorable:LatestRestorableTime,EarliestRestorable:EarliestRestorableTime}' \
  --output table

EXISTING="$(lab_instance_field "$LAB_PITR" DBInstanceIdentifier)"
if [[ "$EXISTING" != "None" && -n "$EXISTING" ]]; then
  echo
  echo "  $LAB_PITR already exists. Delete it first:"
  echo "    aws rds delete-db-instance --db-instance-identifier $LAB_PITR --skip-final-snapshot"
  exit 1
fi

echo
echo "== T0: requesting the PITR =="
LAB_PITR_REQUEST_EPOCH="$(lab_epoch)"
echo "  T0 = $LAB_PITR_REQUEST_EPOCH ($(lab_iso_from_epoch "$LAB_PITR_REQUEST_EPOCH"))"

aws rds restore-db-instance-to-point-in-time \
  --source-db-instance-identifier "$LAB_PRIMARY" \
  --target-db-instance-identifier "$LAB_PITR" \
  --restore-time "$LAB_PITR_TARGET_TIME" \
  --db-instance-class "${LAB_INSTANCE_CLASS:-db.t3.micro}" \
  --no-multi-az \
  --no-deletion-protection \
  --publicly-accessible \
  --vpc-security-group-ids "$LAB_SG" \
  --tags "Key=Name,Value=${LAB_PITR}" "Key=${LAB_TAG_KEY},Value=${LAB_TAG_VALUE}" "Key=Step,Value=06" \
  --query 'DBInstance.{Id:DBInstanceIdentifier,Status:DBInstanceStatus}' --output table

if ! lab_wait_instance "$LAB_PITR" "PITR instance" "${PITR_TIMEOUT:-3600}"; then
  echo
  echo "  The PITR did not reach available. Do not delete it yet:"
  echo "    aws rds describe-db-instances --db-instance-identifier $LAB_PITR"
  echo "    aws rds describe-events --source-identifier $LAB_PITR --source-type db-instance --duration 6"
  exit 1
fi

LAB_PITR_AVAILABLE_EPOCH="$(lab_epoch)"
LAB_PITR_ELAPSED_AVAILABLE=$(( LAB_PITR_AVAILABLE_EPOCH - LAB_PITR_REQUEST_EPOCH ))
echo
echo "  control-plane elapsed: ${LAB_PITR_ELAPSED_AVAILABLE}s to report 'available'"

PITR_ENDPOINT="$(lab_instance_field "$LAB_PITR" Endpoint.Address)"
PITR_PORT="$(lab_instance_field "$LAB_PITR" Endpoint.Port)"
echo "  endpoint: $PITR_ENDPOINT:$PITR_PORT"

echo
echo "== Waiting until it actually answers a query =="
if lab_wait_sql "$PITR_ENDPOINT" "$PITR_PORT" "PITR instance" "${SQL_TIMEOUT:-900}"; then
  LAB_PITR_SQL_EPOCH="$(lab_epoch)"
  LAB_PITR_ELAPSED_SQL=$(( LAB_PITR_SQL_EPOCH - LAB_PITR_REQUEST_EPOCH ))
  echo "  usable elapsed:       ${LAB_PITR_ELAPSED_SQL}s from T0"
else
  lab_die "PITR instance is available but never answered a query"
fi

LAB_PITR_TARGET_TIME="$LAB_PITR_TARGET_TIME"
lab_save

echo
echo "== Timed result =="
printf '  %-38s %s\n' "PITR target time (data freshness)" "$LAB_PITR_TARGET_TIME UTC"
printf '  %-38s %s\n' "bad write time" "$LAB_BAD_WRITE_TIME UTC"
printf '  %-38s %s\n' "data gap (RPO at target)" "$(( LAB_BAD_WRITE_EPOCH - LAB_PITR_TARGET_EPOCH ))s"
printf '  %-38s %s\n' "T0 -> available (control plane)" "${LAB_PITR_ELAPSED_AVAILABLE}s"
printf '  %-38s %s\n' "T0 -> answers a query (usable)" "${LAB_PITR_ELAPSED_SQL}s"
echo
echo "  The 'data gap' line is the RPO this PITR recovers to. Compare it against"
echo "  the snapshot's age at the same T0 (step 05). The smaller the gap, the"
echo "  better the RPO — but the PITR window only exists if automated backups ran."

echo
echo "== Verifying the PITR copy =="
echo "  Expected: all $LAB_SEED_ROWS good rows, 0 poison rows, checksum $LAB_SEED_SUM"
if lab_verify_data "$PITR_ENDPOINT" "$PITR_PORT" \
     "$LAB_SEED_ROWS" "0" "$LAB_SEED_FIRST5" "$LAB_SEED_SUM" "$LAB_SEED_NEWEST_GOOD"; then
  echo
  echo "  Proven: the PITR copy has the pre-incident rows, the checksum matches,"
  echo "  and the poison row is absent. This is a recovery to ${LEAD}s before the bad write."
else
  echo
  echo "  The PITR completed but the data is not what you claimed to recover."
  echo "  An available database with the wrong contents is not a recovery."
  exit 1
fi

cat <<EOF

  Keep this instance while you do step 07 if you want to compare the three
  recovery points side by side (primary, snapshot restore, PITR). It bills until
  deleted.

  When done:
    aws rds delete-db-instance --db-instance-identifier $LAB_PITR \\
      --skip-final-snapshot --delete-automated-backups
EOF