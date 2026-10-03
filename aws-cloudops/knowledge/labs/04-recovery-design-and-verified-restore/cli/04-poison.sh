#!/usr/bin/env bash
# Lab 04, Step 4 — write something you will be glad to recover from.
#
# This is the incident. It deletes five of the known rows and leaves one row
# behind that should never have been there, and it records the exact instant of
# the write. That instant is what step 07 targets, and it is also the moment
# the business loses data from that instant onwards — which is where the RPO
# claim in the worksheet becomes either true or false.
#
# Nothing here raises an alarm, sends a notification, or fails visibly. That is
# the point: a bad write is silent.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/lab04.sh
. "$SCRIPT_DIR/lib/lab04.sh"

lab_need_profile
lab_require_run
lab_load
lab_names

POISON_ID=9001
POISON_MARKER="POISON-${LAB_RUN_SUFFIX}"
LEAD="${LAB_PITR_LEAD_SECONDS:-60}"
FIRST5_SUM=$(( LAB_SEED_FIRST5 * (LAB_SEED_FIRST5 + 1) / 2 ))
export POISON_ID POISON_MARKER

echo "== The write is about to happen =="
echo "  target: $LAB_PRIMARY_ENDPOINT:$LAB_PRIMARY_PORT  db $LAB_DB_NAME"
echo "  effect: delete good rows 1-$LAB_SEED_FIRST5, insert one row marked $POISON_MARKER"
echo "  alarm:  none. No CloudWatch alarm, notification or event is created by this."

BEFORE_EPOCH="$(lab_epoch)"
echo
echo "== Taking the pre-write clock reading, then writing =="
echo "  pre-write epoch: $BEFORE_EPOCH"
lab_sql "$LAB_PRIMARY_ENDPOINT" "$LAB_PRIMARY_PORT" "
BEGIN;
DELETE FROM public.lab04_events WHERE id <= ${LAB_SEED_FIRST5};
INSERT INTO public.lab04_events (id, kind, payload, marker)
VALUES (${POISON_ID}, 'poison', -1, '${POISON_MARKER}');
COMMIT;" >/dev/null
LAB_BAD_WRITE_EPOCH="$(lab_epoch)"
LAB_BAD_WRITE_TIME="$(lab_iso_from_epoch "$LAB_BAD_WRITE_EPOCH")"
lab_save

echo "  post-write epoch: $LAB_BAD_WRITE_EPOCH ($LAB_BAD_WRITE_TIME UTC)"
echo
echo "  Everything written after $LAB_BAD_WRITE_TIME is unrecoverable except by a"
echo "  mechanism that captured it. The snapshot in step 03 does not contain this."

echo
echo "== The damage, read with the same canary query =="
echo "  These numbers are the 'before' state that any correct restore must differ from."
if lab_verify_data "$LAB_PRIMARY_ENDPOINT" "$LAB_PRIMARY_PORT" \
     $(( LAB_SEED_ROWS - LAB_SEED_FIRST5 )) "1" "0" \
     $(( LAB_SEED_SUM - FIRST5_SUM )) ""; then
  echo
  echo "  The primary is damaged as intended. Good — that is the state you now recover from."
else
  lab_die "the primary is not in the expected damaged state; investigate before restoring"
fi

echo
echo "== A snapshot restores to the moment it was taken, not to now =="
echo "  snapshot taken at : $LAB_SNAPSHOT_TIME"
echo "  bad write at      : $LAB_BAD_WRITE_TIME"
echo
echo "  So a restore from that snapshot CANNOT undo this write. Restoring from a"
echo "  backup that predates the incident is what recovery from this incident means;"
echo "  anything written between the snapshot and now is gone either way. That"
echo "  interval is your RPO exposure, and no amount of waiting changes it."
echo
echo "  step 07 instead targets $(( LAB_BAD_WRITE_EPOCH - LEAD ))s, ${LEAD}s before this"
echo "  write, using the automated backup's point-in-time window."

cat <<'EOF'

  Continue with ./cli/05-restore-and-time.sh
EOF
