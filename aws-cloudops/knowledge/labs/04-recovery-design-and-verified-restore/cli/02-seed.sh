#!/usr/bin/env bash
# Lab 04, Step 2 — create a table whose contents are known exactly.
#
# Nothing here is a backup. This step only produces something whose state you
# already know, so that a later restore can be checked instead of admired.
# Explicit primary keys (1..20) are deliberate: "are rows 1-5 still here?" then
# has an unambiguous answer.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/lab04.sh
. "$SCRIPT_DIR/lib/lab04.sh"

lab_need_profile
lab_require_run
lab_load

LAB_SEED_ROWS="${LAB_SEED_ROWS:-20}"
LAB_SEED_FIRST5="${LAB_SEED_FIRST5:-5}"
LAB_SEED_SUM="$(awk -v n="$LAB_SEED_ROWS" 'BEGIN{s=0;i=1;while(i<=n){s+=i;i++};print s}')"
export LAB_SEED_ROWS LAB_SEED_FIRST5 LAB_SEED_SUM

echo "== Primary endpoint =="
echo "  $LAB_PRIMARY_ENDPOINT:$LAB_PRIMARY_PORT"
lab_wait_sql "$LAB_PRIMARY_ENDPOINT" "$LAB_PRIMARY_PORT" "primary" 600

echo
echo "== Refusing to double-seed =="
EXISTING="$(lab_sql "$LAB_PRIMARY_ENDPOINT" "$LAB_PRIMARY_PORT" \
  "SELECT count(*) FROM information_schema.tables WHERE table_schema='public' AND table_name='lab04_events';" || echo 0)"
if [[ "${EXISTING:-0}" != "0" ]]; then
  lab_die "public.lab04_events already exists on $LAB_PRIMARY. Seed exactly once per run; tear down and start a new run instead of reseeding."
fi

echo
echo "== Creating the table and $LAB_SEED_ROWS known rows =="
lab_sql "$LAB_PRIMARY_ENDPOINT" "$LAB_PRIMARY_PORT" "
CREATE TABLE public.lab04_events (
  id          bigint PRIMARY KEY,
  kind        text        NOT NULL,
  payload     integer     NOT NULL,
  marker      text        NOT NULL,
  written_at  timestamptz NOT NULL DEFAULT now()
);
INSERT INTO public.lab04_events (id, kind, payload, marker)
SELECT g, 'good', g, '${LAB_RUN_SUFFIX}'
FROM generate_series(1, ${LAB_SEED_ROWS}) AS g;" >/dev/null

LAB_SEED_NEWEST_GOOD="$(lab_sql "$LAB_PRIMARY_ENDPOINT" "$LAB_PRIMARY_PORT" \
  "SELECT to_char(max(written_at), 'YYYY-MM-DD HH24:MI:SS') FROM public.lab04_events WHERE kind='good';")"
LAB_SEED_EPOCH="$(lab_epoch)"
lab_save

echo "  seeded. Newest good row written at $LAB_SEED_NEWEST_GOOD UTC"
echo
echo "== Reading it back with the same canary query used later =="
lab_verify_data "$LAB_PRIMARY_ENDPOINT" "$LAB_PRIMARY_PORT" \
  "$LAB_SEED_ROWS" "0" "$LAB_SEED_FIRST5" "$LAB_SEED_SUM" "$LAB_SEED_NEWEST_GOOD"

cat <<'EOF'

  Record the checksum. After step 4 this database will not match it, and the only
  thing that can restore that state is the snapshot from step 3 or a point-in-time
  restore from the automated backup. A green backup job proves neither.
EOF
