#!/usr/bin/env bash
# Lab 05 teardown - remove every resource this lab created, then prove it.
#
# Idempotent: safe to run twice, and safe to run after a partial create.
# Exits non-zero if anything is still active. Resources that are already
# scheduled for deletion are reported separately and do not fail the run,
# because a second run would then never succeed.
#
# Cost note: the KMS key cannot be deleted immediately. schedule-key-deletion
# leaves it PendingDeletion for at least 7 days, and the key keeps accruing its
# monthly charge for the whole window. See the README cost table.
#
set -euo pipefail

PREFIX="soa-c03-lab05"
REGION="${AWS_REGION:-${AWS_DEFAULT_REGION:-us-east-1}}"
KEY_ALIAS="alias/${PREFIX}-key"
PARAM_PATH="${PREFIX}/"
SECRET_NAME="${PREFIX}/api-credential"
KMS_WINDOW="${KMS_WINDOW:-7}"
# delete-secret accepts only 7 or 30 days for the recovery window.
SECRET_WINDOW="${SECRET_WINDOW:-7}"

export AWS_REGION="$REGION"

if [[ -z "${AWS_PROFILE:-}" ]]; then
  echo "ERROR: set AWS_PROFILE to the authorized profile before running." >&2
  exit 1
fi
if [[ "$SECRET_WINDOW" != "7" && "$SECRET_WINDOW" != "30" ]]; then
  echo "ERROR: SECRET_WINDOW must be 7 or 30, not ${SECRET_WINDOW}." >&2
  exit 1
fi

ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
BUCKET="${PREFIX}-${ACCOUNT_ID}-${REGION}"

echo "region: $REGION"
echo "== 1. AWS Config rules =="
# Delete every rule this lab created, whatever identifier it was created with.
for rule in $(aws configservice describe-config-rules \
    --query "ConfigRules[?starts_with(ConfigRuleName, '${PREFIX}-')].ConfigRuleName" \
    --output text 2>/dev/null); do
  [[ -z "$rule" ]] && continue
  aws configservice delete-config-rule --config-rule-name "$rule" 2>/dev/null \
    && echo "  deleted $rule" \
    || echo "  WARNING: could not delete $rule"
done
echo "  (recorders and delivery channels are account-level and never touched)"

echo
echo "== 2. Secrets Manager =="
for name in $(aws secretsmanager list-secrets \
    --query "SecretList[?starts_with(Name, '${PREFIX}/')].Name" --output text 2>/dev/null); do
  [[ -z "$name" ]] && continue
  aws secretsmanager delete-secret --secret-id "$name" \
    --recovery-window-in-days "$SECRET_WINDOW" >/dev/null 2>&1 \
    && echo "  scheduled deletion of $name (${SECRET_WINDOW}-day recovery window)" \
    || echo "  WARNING: could not delete $name"
done

echo
echo "== 3. SSM parameters =="
for name in $(aws ssm get-parameters-by-path --path "$PARAM_PATH" --recursive \
    --query 'Parameters[].Name' --output text 2>/dev/null); do
  [[ -z "$name" ]] && continue
  aws ssm delete-parameter --name "$name" >/dev/null \
    && echo "  deleted $name" \
    || echo "  WARNING: could not delete $name"
done

echo
echo "== 4. S3 =="
BUCKET_STATE="absent"
if aws s3api head-bucket --bucket "$BUCKET" >/dev/null 2>&1; then
  BUCKET_STATE="present"
  OBJECTS="$(aws s3api list-objects-v2 --bucket "$BUCKET" --query 'Contents[].Key' --output text 2>/dev/null)"
  if [[ -n "$OBJECTS" && "$OBJECTS" != "None" ]]; then
    for key in $OBJECTS; do
      aws s3api delete-object --bucket "$BUCKET" --key "$key" >/dev/null 2>&1 \
        && echo "  deleted object $key" || echo "  WARNING: could not delete $key"
    done
  fi
  if aws s3api delete-bucket --bucket "$BUCKET" >/dev/null 2>&1; then
    echo "  deleted bucket ${PREFIX}-****${ACCOUNT_ID: -4}-${REGION}"
    BUCKET_STATE="absent"
  else
    echo "  WARNING: bucket still present"
  fi
else
  HEAD_ERR="$(aws s3api head-bucket --bucket "$BUCKET" 2>&1 || true)"
  case "$HEAD_ERR" in
    *404*|*NoSuchBucket*) echo "  bucket not present" ;;
    *) echo "  bucket lookup inconclusive:"
       printf '%s\n' "$HEAD_ERR" | head -3
       BUCKET_STATE="unknown" ;;
  esac
fi

echo
echo "== 5. KMS =="
KEY_ID="$(aws kms list-aliases \
  --query "Aliases[?AliasName=='${KEY_ALIAS}'].TargetKeyId" --output text 2>/dev/null || echo None)"
if [[ -n "$KEY_ID" && "$KEY_ID" != "None" ]]; then
  STATE="$(aws kms describe-key --key-id "$KEY_ID" --query 'KeyMetadata.KeyState' --output text 2>/dev/null || echo Unknown)"
  if [[ "$STATE" == "PendingDeletion" ]]; then
    echo "  key is already PendingDeletion; removing the alias only"
    aws kms delete-alias --alias-name "$KEY_ALIAS" >/dev/null 2>&1 \
      && echo "  deleted $KEY_ALIAS" || echo "  WARNING: could not delete $KEY_ALIAS"
  else
    aws kms schedule-key-deletion --key-id "$KEY_ID" \
      --pending-window-in-days "$KMS_WINDOW" >/dev/null \
      && echo "  scheduled deletion of the key (${KMS_WINDOW}-day minimum window; it still bills until it completes)" \
      || echo "  WARNING: could not schedule key deletion"
  fi
else
  echo "  ${KEY_ALIAS} not found"
fi

echo
echo "== 6. Verification =="
FAILED=0
check() {
  local label="$1" result="$2"
  if [[ "$result" == "None" || -z "$result" ]]; then
    printf '  %-24s empty  OK\n' "$label"
  else
    printf '  %-24s %s  STILL PRESENT\n' "$label" "$result"
    FAILED=1
  fi
}
note() {
  local label="$1" result="$2"
  if [[ "$result" == "None" || -z "$result" ]]; then
    printf '  %-24s empty  OK\n' "$label"
  else
    printf '  %-24s %s  pending, not active\n' "$label" "$result"
  fi
}

if [[ "$BUCKET_STATE" == "absent" ]]; then
  check "bucket" "None"
else
  check "bucket" "$BUCKET_STATE"
fi
check "ssm parameters" "$(aws ssm get-parameters-by-path --path "$PARAM_PATH" --recursive \
  --query 'Parameters[].Name' --output text 2>/dev/null || echo None)"
check "secrets manager" "$(aws secretsmanager list-secrets \
  --query "SecretList[?starts_with(Name, '${PREFIX}/')].Name" --output text 2>/dev/null || echo None)"
note "secrets pending del." "$(aws secretsmanager list-secrets --include-planned-deletion \
  --query "SecretList[?starts_with(Name, '${PREFIX}/')].Name" --output text 2>/dev/null || echo None)"
check "kms alias" "$(aws kms list-aliases \
  --query "Aliases[?starts_with(AliasName, 'alias/${PREFIX}')].AliasName" \
  --output text 2>/dev/null || echo None)"
check "config rules" "$(aws configservice describe-config-rules \
  --query "ConfigRules[?starts_with(ConfigRuleName, '${PREFIX}-')].ConfigRuleName" \
  --output text 2>/dev/null || echo None)"

KEY_ID_FINAL="$(aws kms list-aliases \
  --query "Aliases[?AliasName=='${KEY_ALIAS}'].TargetKeyId" --output text 2>/dev/null || echo None)"
if [[ -n "$KEY_ID_FINAL" && "$KEY_ID_FINAL" != "None" ]]; then
  STATE="$(aws kms describe-key --key-id "$KEY_ID_FINAL" \
    --query 'KeyMetadata.KeyState' --output text 2>/dev/null || echo Unknown)"
  if [[ "$STATE" == "PendingDeletion" ]]; then
    note "kms key" "PendingDeletion"
  else
    check "kms key" "$STATE"
  fi
else
  echo "  kms key                 the alias is gone, so the key ID is no longer"
  echo "                          resolvable by name. If you scheduled deletion in"
  echo "                          step 5 the key disappears at the end of its window."
fi

echo
if [[ "$FAILED" -eq 0 ]]; then
  cat <<'DONE'
clean - no active soa-c03-lab05 resource remains.

Two items are intentionally not instant, and neither is usable any more:
  the KMS key is PendingDeletion and bills for at least 7 more days
  the secret is scheduled for deletion inside its recovery window
Confirm both in the Console before calling the lab finished.
DONE
else
  echo "INCOMPLETE - see the STILL PRESENT rows above."
fi
exit "$FAILED"