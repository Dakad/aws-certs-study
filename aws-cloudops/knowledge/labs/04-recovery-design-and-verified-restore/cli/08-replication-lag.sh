#!/usr/bin/env bash
# Lab 04, Step 8 — stress the cross-Region replica and measure catch-up time.
#
# Inserts a burst of rows on the primary, then polls CloudWatch ReplicaLag in
# the DR region until it drops to 0 (or < 1 second) or a 5-minute timeout.
# This demonstrates the asynchronous nature of cross-Region replication and
# the RPO exposure it represents.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/lab04.sh
. "$SCRIPT_DIR/lib/lab04.sh"

lab_need_profile
lab_require_run
lab_load
lab_names

: "${LAB_DR_REGION:?run file is missing LAB_DR_REGION — run step 01 with LAB_DR_REGION set}"
: "${LAB_DR_REPLICA_ENDPOINT:?run file is missing LAB_DR_REPLICA_ENDPOINT — run step 07 first}"
: "${LAB_PRIMARY_ENDPOINT:?run file is missing LAB_PRIMARY_ENDPOINT — run step 01 first}"

BURST_ROWS="${LAB_LAG_BURST_ROWS:-10000}"
BURST_BATCH="${LAB_LAG_BURST_BATCH:-1000}"
TIMEOUT_SECONDS="${LAB_LAG_TIMEOUT:-300}"

echo "== Replication lag stress test =="
echo "  primary endpoint   : $LAB_PRIMARY_ENDPOINT:$LAB_PRIMARY_PORT"
echo "  replica endpoint   : $LAB_DR_REPLICA_ENDPOINT (region $LAB_DR_REGION)"
echo "  burst rows         : $BURST_ROWS (in batches of $BURST_BATCH)"
echo "  timeout            : ${TIMEOUT_SECONDS}s"

echo
echo "== Baseline replication lag before burst =="
aws cloudwatch get-metric-statistics --region "$LAB_DR_REGION" \
  --namespace AWS/RDS --metric-name ReplicaLag \
  --dimensions Name=DBInstanceIdentifier,Value="$LAB_REPLICA" \
  --start-time "$(date -u -d '5 minutes ago' +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -v-5M +%Y-%m-%dT%H:%M:%SZ)" \
  --end-time "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --period 60 --statistics Average \
  --query 'Datapoints[].{Time:Timestamp,Value:Average}' --output table || echo "  no datapoints yet"

echo
echo "== Writing burst on primary =="
LAB_LAG_MARKER_ID="LAG-${LAB_RUN_SUFFIX}"
LAB_LAG_WROTE_EPOCH="$(lab_epoch)"
echo "  burst start: $LAB_LAG_WROTE_EPOCH ($(lab_iso_from_epoch "$LAB_LAG_WROTE_EPOCH"))"

BATCHES=$(( (BURST_ROWS + BURST_BATCH - 1) / BURST_BATCH ))
i=1
while [ "$i" -le "$BATCHES" ]; do
  START_ID=$(( (i - 1) * BURST_BATCH + 100000 ))
  END_ID=$(( i * BURST_BATCH + 99999 ))
  if [ "$END_ID" -gt $(( 100000 + BURST_ROWS - 1 )) ]; then
    END_ID=$(( 100000 + BURST_ROWS - 1 ))
  fi
  lab_sql "$LAB_PRIMARY_ENDPOINT" "$LAB_PRIMARY_PORT" "
INSERT INTO public.lab04_events (id, kind, payload, marker)
SELECT g, 'lagtest', 1, '${LAB_LAG_MARKER_ID}'
FROM generate_series($START_ID, $END_ID) AS g;" >/dev/null
  i=$(( i + 1 ))
done

echo "  burst complete: $(lab_epoch) ($(lab_iso_from_epoch "$(lab_epoch)"))"

echo
echo "== Polling ReplicaLag until < 1s or timeout =="
START_POLL="$(lab_epoch)"
LAST_LAG=""
while :; do
  NOW="$(lab_epoch)"
  ELAPSED=$(( NOW - START_POLL ))
  if [ "$ELAPSED" -ge "$TIMEOUT_SECONDS" ]; then
    echo
    echo "  TIMEOUT after ${TIMEOUT_SECONDS}s. Last observed lag: ${LAST_LAG:-none}"
    break
  fi

  LAG_JSON="$(aws cloudwatch get-metric-statistics --region "$LAB_DR_REGION" \
    --namespace AWS/RDS --metric-name ReplicaLag \
    --dimensions Name=DBInstanceIdentifier,Value="$LAB_REPLICA" \
    --start-time "$(date -u -d '2 minutes ago' +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -v-2M +%Y-%m-%dT%H:%M:%SZ)" \
    --end-time "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    --period 60 --statistics Average --output json 2>/dev/null || echo '{"Datapoints":[]}')"

  LAG_VAL="$(printf '%s' "$LAG_JSON" | python3 -c '
import sys, json
try:
    data = json.load(sys.stdin)
    pts = data.get("Datapoints", [])
    if pts:
        latest = max(pts, key=lambda p: p["Timestamp"])
        print(int(latest.get("Average", 0)))
    else:
        print("")
except Exception:
    print("")' 2>/dev/null || echo "")"

  if [ -n "$LAG_VAL" ]; then
    LAST_LAG="$LAG_VAL"
    printf '  [%4ss] ReplicaLag: %ss\r' "$ELAPSED" "$LAG_VAL"
    if [ "$LAG_VAL" -lt 1 ]; then
      echo
      echo "  ReplicaLag dropped below 1 second."
      break
    fi
  else
    printf '  [%4ss] ReplicaLag: (no datapoint yet)\r' "$ELAPSED"
  fi
  sleep 10
done

LAB_LAG_SEEN_EPOCH="$(lab_epoch)"
LAB_LAG_SECONDS=$(( LAB_LAG_SEEN_EPOCH - LAB_LAG_WROTE_EPOCH ))
lab_save

echo
echo "== Final verification on replica =="
LAG_ROWS="$(lab_sql "$LAB_DR_REPLICA_ENDPOINT" "$LAB_PRIMARY_PORT" \
  "SELECT count(*) FROM public.lab04_events WHERE marker = '${LAB_LAG_MARKER_ID}';" || echo 0)"
echo "  lag-test rows on replica: $LAG_ROWS (expected $BURST_ROWS)"

echo
echo "== Summary =="
printf '  %-30s %s\n' "burst start" "$(lab_iso_from_epoch "$LAB_LAG_WROTE_EPOCH") UTC"
printf '  %-30s %s\n' "lag caught up" "$(lab_iso_from_epoch "$LAB_LAG_SEEN_EPOCH") UTC"
printf '  %-30s %s\n' "replication lag duration" "${LAB_LAG_SECONDS}s"
printf '  %-30s %s\n' "rows replicated" "$LAG_ROWS / $BURST_ROWS"
echo
echo "  The replication lag duration is the RPO exposure of this cross-Region"
echo "  replica at this moment. If the primary region failed during that window,"
echo "  those writes would be lost. No alarm fires for this — you must measure it."
EOF