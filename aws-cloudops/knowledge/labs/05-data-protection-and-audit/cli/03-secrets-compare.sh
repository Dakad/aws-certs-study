#!/usr/bin/env bash
# Lab 05, Step 3 - what actually separates Secrets Manager from an SSM SecureString.
#
# Read-only apart from one deliberate, reversible overwrite of the lab's own
# parameter. Both services hide the value from list and describe; only an
# explicit get returns it; only one of them has a native rotation model.
#
set -euo pipefail

PREFIX="soa-c03-lab05"
REGION="${AWS_REGION:-${AWS_DEFAULT_REGION:-us-east-1}}"
PARAM_NAME="${PREFIX}/db-password"
PLAIN_PARAM_NAME="${PREFIX}/plain-token"
SECRET_NAME="${PREFIX}/api-credential"

export AWS_REGION="$REGION"

if [[ -z "${AWS_PROFILE:-}" ]]; then
  echo "ERROR: set AWS_PROFILE to the authorized profile before running." >&2
  exit 1
fi
if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: jq is required by this script and was not found on PATH." >&2
  exit 1
fi

# ---------------------------------------------------------- 1. nothing is listed
echo "== 1. Listing is not reading =="
echo "secretsmanager list-secrets:"
aws secretsmanager list-secrets \
  --query 'SecretList[].{Name:Name,Description:Description,KmsKeyId:KmsKeyId,LastChangedDate:LastChangedDate}' \
  --output table 2>/dev/null | head -20 || echo "  (unavailable)"

echo
echo "ssm describe-parameters:"
aws ssm describe-parameters --parameter-filters "Key=Name,Option=BeginsWith,Values=${PREFIX}" \
  --query 'Parameters[].{Name:Name,Type:Type,KeyId:KeyId,Tier:Tier}' \
  --output table

cat <<'GUIDE'
  Neither list call returns a value. Both services make you name one item and
  ask again. That is a deliberate design choice: the read path is the auditable
  one, and it is the path you can revoke.
GUIDE

# ------------------------------------------------------------ 2. the read path
echo
echo "== 2. The read path returns a value, and only that path does =="
echo "secretsmanager get-secret-value:"
aws secretsmanager get-secret-value --secret-id "$SECRET_NAME" \
  --query '{Name:Name,VersionId:VersionId,VersionStages:VersionStages,CreatedDate:CreatedDate,Length:(.SecretString|length)}' \
  --output json 2>/dev/null | jq . || echo "  (unavailable)"

echo
echo "ssm get-parameter --with-decryption:"
aws ssm get-parameter --name "$PARAM_NAME" --with-decryption \
  --query 'Parameter.{Name:Name,Type:Type,Version:Version,KeyId:KeyId,Length:(.Value|length)}' \
  --output json 2>/dev/null | jq . || echo "  (unavailable)"

cat <<'GUIDE'
  Value lengths only. Printing the secret proves nothing you cannot already get
  from the file, and it puts credential material in your scrollback and your
  notes. Length is enough to show the value came back.
GUIDE

# -------------------------------------------- 3. versioning and rotation staging
echo
echo "== 3. Versioning: numbers versus staging labels =="
echo "ssm get-parameter-history (versions carry numbers, no state):"
aws ssm get-parameter-history --name "$PARAM_NAME" \
  --query 'Parameters[].{Version:Version,Type:Type,LastModifiedDate:LastModifiedDate,Labels:Labels}' \
  --output table

echo
echo "secretsmanager describe-secret VersionIdsToStages (versions carry states):"
aws secretsmanager describe-secret --secret-id "$SECRET_NAME" \
  --query 'VersionIdsToStages' --output json 2>/dev/null | jq . || echo "  (unavailable)"

echo
echo "secretsmanager RotationEnabled / RotationLambdaARN:"
aws secretsmanager describe-secret --secret-id "$SECRET_NAME" \
  --query '{RotationEnabled:RotationEnabled,RotationLambdaARN:RotationLambdaARN,ScheduleExpression:RotationRules.ScheduleExpression,Duration:RotationRules.Duration}' \
  --output json 2>/dev/null | jq . || echo "  (unavailable)"

cat <<'GUIDE'
  This is the practical difference, and it is not "one is encrypted".
  Secrets Manager versions are named AWSPENDING, AWSCURRENT, AWSPREVIOUS, so a
  rotation can have a new value staged, promoted, and rolled back while the old
  one is still served. A Parameter Store SecureString has version numbers and no
  such states: rotation is your own code plus a consumer that will read the new
  value at the right moment.
  RotationEnabled is False here because this lab creates no rotation Lambda and
  no RDS secret. False means "not configured", not "cannot rotate".
GUIDE

# -------------------------------------- 4. a real overwrite, then read it back
echo
echo "== 4. Overwriting in place, and what that does to the read path =="
aws ssm put-parameter --name "$PARAM_NAME" --type SecureString --overwrite \
  --value "lab05-rotated-value" >/dev/null
echo "parameter overwritten; version now:"
aws ssm get-parameter --name "$PARAM_NAME" --query 'Parameter.Version' --output text

cat <<'GUIDE'
  --overwrite is in-place. The old version is still in the history and a caller
  that pins a version keeps seeing the old value. An application that caches the
  parameter continues to use the cached value until it refreshes. That is the
  rotation failure mode you have to design around, and it is invisible in both
  the AWS Console and the parameter's own describe output.
GUIDE

# ------------------------------------------------------- 5. failure behaviour
echo
echo "== 5. What each service returns when you get it wrong =="
set +e
echo "wrong secret id:"
aws secretsmanager get-secret-value --secret-id "${PREFIX}/does-not-exist" 2>&1 | head -4
echo
echo "wrong parameter name:"
aws ssm get-parameter --name "${PREFIX}/does-not-exist" 2>&1 | head -4
echo
echo "pinned version that does not exist:"
aws secretsmanager get-secret-value --secret-id "$SECRET_NAME" \
  --version-id "00000000-0000-0000-0000-000000000000" 2>&1 | head -4
set -e

cat <<'GUIDE'
  Compare the error shapes. Distinguishing "not found", "not authorized", and
  "no such version" is what stops you from reading a permissions problem as a
  missing resource during an incident.
GUIDE

cat <<'GUIDE'
  Neither store is free. Both bill per item per month plus per API call, and
  neither bills for the value's length. Check the current per-item and
  per-request rates for your region before choosing one for a workload - see the
  cost table in the README, which marks these numbers as assumptions to confirm.
GUIDE