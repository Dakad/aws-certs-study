#!/usr/bin/env bash
# Lab 06, Step 8 — plant a state lock so you can see what contention looks like.
#
# Creates: one object in the state bucket (<key>.tflock) and/or one item in the
#          DynamoDB lock table, depending on LAB_LOCK_MODE.
# Deletes: nothing. Use cli/99-teardown.sh, or tofu force-unlock, to release it.
#
# Why a script instead of "run two terminals":
#   Lock contention is a race. Setting it up by hand means winning the race, and
#   a race you cannot reproduce is a race you cannot learn from. Planting the
#   lock artefact directly makes the failure deterministic while still going
#   through OpenTofu's real acquisition path — nothing here bypasses the tool.
#
# Two modes, because OpenTofu supports two mechanisms:
#
#   LAB_LOCK_MODE=s3        plants <key>.tflock in the bucket.
#                           Matches use_lockfile=true, the mechanism the OpenTofu
#                           documentation prefers. Acquisition is a conditional
#                           write (If-None-Match: *), so an existing object means
#                           the write is refused.
#
#   LAB_LOCK_MODE=dynamodb  plants an item keyed LockID=<bucket>/<key>.
#                           Matches dynamodb_table=<table>. Acquisition is a
#                           conditional PutItem, so an existing item means the
#                           write is refused.
#
# Required environment:
#   AWS_PROFILE        authorized playground or personal-account profile
#   LAB_STATE_BUCKET   printed by cli/01
#   LAB_STATE_KEY      printed by cli/01
# Optional environment:
#   LAB_LOCK_MODE   s3 (default) or dynamodb
#   LAB_LOCK_TABLE  required for LAB_LOCK_MODE=dynamodb
#   AWS_REGION      default us-east-1
#
set -euo pipefail

AWS_REGION="${AWS_REGION:-us-east-1}"
LAB_LOCK_MODE="${LAB_LOCK_MODE:-s3}"

if [[ -z "${AWS_PROFILE:-}" ]]; then
  echo "ERROR: set AWS_PROFILE to the authorized profile before running." >&2
  exit 1
fi
if [[ -z "${LAB_STATE_BUCKET:-}" || -z "${LAB_STATE_KEY:-}" ]]; then
  echo "ERROR: set LAB_STATE_BUCKET and LAB_STATE_KEY (cli/01 prints both)." >&2
  exit 1
fi

LOCK_ID="11111111-2222-3333-4444-$(printf '%04d' "$$")"
LOCK_KEY="${LAB_STATE_KEY}.tflock"
LOCK_TABLE_ID="${LAB_STATE_BUCKET}/${LAB_STATE_KEY}"

echo "== 0: identity =="
aws sts get-caller-identity --output json \
  | jq -r '"  account: ...." + (.Account[-4:]) + "  (redacted)"'
echo "  mode:  $LAB_LOCK_MODE"
echo "  lock id: $LOCK_ID"
echo

case "$LAB_LOCK_MODE" in
  s3)
    # The .tflock payload is a JSON document with the same field names OpenTofu
    # writes. Its exact serialisation is not contractual; what matters for the
    # exercise is that the object exists, so the conditional write is refused.
    LOCK_BODY="$(jq -cn \
      --arg id "$LOCK_ID" \
      --arg who "${USER:-$(whoami)}@$(hostname)" \
      --arg ver "$(tofu version | head -1)" \
      --arg created "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
      '{ID:$id,Operation:"OperationTypePlan",Who:$who,Version:$ver,Created:$created,Info:"lab 06 planted lock"}')"

    echo "== Planting $LOCK_KEY =="
    # --if-none-match '*' is the same conditional the backend uses. If something
    # is already holding the lock, this call fails and that failure is itself
    # the correct result.
    if aws s3api put-object \
      --bucket "$LAB_STATE_BUCKET" \
      --key "$LOCK_KEY" \
      --body "$LOCK_BODY" \
      --content-type application/json \
      --if-none-match '*' >/dev/null 2>&1; then
      echo "  planted"
    else
      echo "  could not plant: something already holds this lock."
      echo "  That is contention working. Run 'tofu plan' and read the error."
      exit 0
    fi
    echo
    echo "  Lock object:"
    aws s3api get-object --bucket "$LAB_STATE_BUCKET" --key "$LOCK_KEY" - | jq .
    ;;

  dynamodb)
    if [[ -z "${LAB_LOCK_TABLE:-}" ]]; then
      echo "ERROR: LAB_LOCK_MODE=dynamodb needs LAB_LOCK_TABLE (cli/01 prints it)." >&2
      exit 1
    fi
    echo "== Planting DynamoDB item LockID=$LOCK_TABLE_ID =="
    if aws dynamodb put-item \
      --table-name "$LAB_LOCK_TABLE" \
      --item "{\"LockID\":{\"S\":\"$LOCK_TABLE_ID\"},\"Info\":{\"S\":\"{\\\"ID\\\":\\\"$LOCK_ID\\\",\\\"Operation\\\":\\\"OperationTypePlan\\\",\\\"Who\\\":\\\"planted-by-lab-06\\\",\\\"Version\\\":\\\"1\\\",\\\"Created\\\":\\\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\\\"}\"}}" \
      --condition-expression 'attribute_not_exists(LockID)' >/dev/null 2>&1; then
      echo "  planted"
    else
      echo "  could not plant: a lock item already exists for this state."
      echo "  Run 'tofu plan' and read the error."
      exit 0
    fi
    echo
    aws dynamodb get-item \
      --table-name "$LAB_LOCK_TABLE" \
      --key "{\"LockID\":{\"S\":\"$LOCK_TABLE_ID\"}}" \
      --output json
    ;;

  *)
    echo "ERROR: LAB_LOCK_MODE must be s3 or dynamodb." >&2
    exit 1
    ;;
esac

cat <<EOF

== Lock held. Now try to do real work. ==

  cd ../tofu
  tofu plan -lock-timeout=0s -out=locked.tfplan

-lock-timeout=0s means "fail immediately rather than wait". A real pipeline
sets a longer timeout, and the difference between a fast failure and a ten
minute stall is exactly why you set one deliberately.

Expect one of:
  * "Error acquiring the state lock" naming $LOCK_ID. The clean case.
  * A state-digest or integrity complaint. The DynamoDB path stores a digest of
    the state alongside the lock, so a hand-planted item can be rejected for
    that reason instead. Same lesson: the backend refused to proceed because it
    could not prove it had exclusive, uncorrupted access.

Release it:

  tofu force-unlock -force $LOCK_ID

force-unlock is for a run that crashed while holding the lock. It is not a way
to take a lock from someone else's live run — that lock means their apply is in
flight, and clearing it is how two writers end up writing the same state.
EOF
