#!/usr/bin/env bash
# Lab 05, Step 1 - create the disposable data-protection resources.
#
# Creates one KMS customer-managed key (CMK), one private S3 bucket with default
# SSE-KMS, two objects that disagree about their encryption, one SSM SecureString
# protected by that key, one plain String parameter as a contrast, and one Secrets
# Manager secret protected by the same key.
#
# Cost: the CMK is the only resource that bills by time (about $1/month).
# The bucket holds a few hundred bytes. Everything else is per-request.
#
# Read this file before running it. Nothing here touches an existing resource.
#
# Required environment:
#   AWS_PROFILE       authorized playground or personal-account profile
#   AWS_REGION        optional; defaults to AWS_DEFAULT_REGION, then us-east-1
#
set -euo pipefail

PREFIX="soa-c03-lab05"
REGION="${AWS_REGION:-${AWS_DEFAULT_REGION:-us-east-1}}"
KEY_ALIAS="alias/${PREFIX}-key"
PARAM_NAME="${PREFIX}/db-password"
PLAIN_PARAM_NAME="${PREFIX}/plain-token"
SECRET_NAME="${PREFIX}/api-credential"
OBJ_KMS="rest/inherits-bucket-default.txt"
OBJ_AES="rest/per-object-override.txt"

export AWS_REGION="$REGION"

if [[ -z "${AWS_PROFILE:-}" ]]; then
  echo "ERROR: set AWS_PROFILE to the authorized profile before running." >&2
  exit 1
fi
if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: jq is required by this script and was not found on PATH." >&2
  exit 1
fi

redact() { printf '****%s' "${1: -4}"; }

echo "== Step 0: identity and region =="
IDENTITY="$(aws sts get-caller-identity --output json)"
CALLER_ARN="$(printf '%s' "$IDENTITY" | jq -r '.Arn')"
ACCOUNT_ID="$(printf '%s' "$IDENTITY" | jq -r '.Account')"
# Everything after the account segment, so the account ID is not echoed.
CALLER_KIND="$(printf '%s' "$CALLER_ARN" | cut -d: -f6-)"
echo "region:  $REGION"
echo "account: $(redact "$ACCOUNT_ID")"
echo "caller:  ${CALLER_KIND:-unknown} (account redacted)"
echo "(nothing above is recorded in this repository)"

# The bucket name is derived from the account and region so that every later
# script and the teardown can rebuild it without a state file. That does put the
# account ID inside the bucket name - see the README note on this trade-off.
BUCKET="${PREFIX}-${ACCOUNT_ID}-${REGION}"

# ------------------------------------------------------- idempotency preflight
echo
echo "== Preflight: refusing to run twice over live resources =="
if aws s3api head-bucket --bucket "$BUCKET" >/dev/null 2>&1; then
  echo "ERROR: bucket ${BUCKET} already exists. Run ./cli/99-teardown.sh first." >&2
  exit 1
fi
EXISTING_ALIAS="$(aws kms list-aliases \
  --query "Aliases[?AliasName=='${KEY_ALIAS}'].AliasName" --output text 2>/dev/null || echo None)"
if [[ "$EXISTING_ALIAS" != "None" && -n "$EXISTING_ALIAS" ]]; then
  echo "ERROR: ${KEY_ALIAS} already exists. Run ./cli/99-teardown.sh first." >&2
  exit 1
fi

# ------------------------------------------------------------------- 1. the CMK
echo
echo "== 1. Customer-managed KMS key =="
KEY_ID="$(aws kms create-key \
  --description "SOA-C03 lab 05 encryption key (disposable)" \
  --key-usage ENCRYPT_DECRYPT \
  --origin AWS_KMS \
  --tags "TagKey=${PREFIX},TagValue=true" \
  --query 'KeyMetadata.KeyId' --output text)"
aws kms create-alias --alias-name "$KEY_ALIAS" --target-key-id "$KEY_ID"
KEY_ARN="$(aws kms describe-key --key-id "$KEY_ID" --query 'KeyMetadata.Arn' --output text)"
echo "key:   $(redact "$KEY_ARN")"
echo "alias: $KEY_ALIAS"

cat <<'GUIDE'
  Note on the --tags format: KMS uses TagKey=/TagValue= in shorthand, while IAM
  and SSM use Key=/Value=. Getting that backwards fails with a param error, not
  with a silent no-op.
GUIDE

# ----------------------------------------------------------------- 2. the bucket
echo
echo "== 2. Private S3 bucket with SSE-KMS default =="
if [[ "$REGION" == "us-east-1" ]]; then
  aws s3api create-bucket --bucket "$BUCKET" >/dev/null
else
  aws s3api create-bucket --bucket "$BUCKET" \
    --create-bucket-configuration "LocationConstraint=${REGION}" >/dev/null
fi
echo "bucket: $(redact "$BUCKET")-${REGION}"

aws s3api put-public-access-block --bucket "$BUCKET" \
  --public-access-block-configuration \
  '{"BlockPublicAcls":true,"BlockPublicPolicy":true,"IgnorePublicAcls":true,"RestrictPublicBuckets":true}' \
  >/dev/null
echo "public access block: all four settings true"

aws s3api put-bucket-tagging --bucket "$BUCKET" \
  --tagging "{\"TagSet\":[{\"Key\":\"${PREFIX}\",\"Value\":\"true\"}]}" >/dev/null

aws s3api put-bucket-encryption --bucket "$BUCKET" \
  --server-side-encryption-configuration \
  "{\"Rules\":[{\"ApplyServerSideEncryptionByDefault\":{\"SSEAlgorithm\":\"aws:kms\",\"KMSMasterKeyID\":\"${KEY_ARN}\"}}]}" \
  >/dev/null
echo "default encryption: aws:kms with the lab key"

# ----------------------------------------------------------------- 3. the objects
# --body takes a file path for this operation, so both bodies are temp files.
BODY_ONE="$(mktemp)"
BODY_TWO="$(mktemp)"
printf 'inherits the bucket default\n' > "$BODY_ONE"
printf 'explicitly asks for AES256\n' > "$BODY_TWO"

echo
echo "== 3. Two objects that disagree about encryption =="
aws s3api put-object --bucket "$BUCKET" --key "$OBJ_KMS" --body "$BODY_ONE" >/dev/null
echo "  $OBJ_KMS -> no per-object SSE argument"
aws s3api put-object --bucket "$BUCKET" --key "$OBJ_AES" --body "$BODY_TWO" \
  --server-side-encryption AES256 >/dev/null
echo "  $OBJ_AES -> --server-side-encryption AES256"
rm -f "$BODY_ONE" "$BODY_TWO"

# ------------------------------------------------------------- 4. SSM parameters
echo
echo "== 4. SSM Parameter Store: one SecureString, one plain String =="
# Both values are obviously fake. A real value here would land in your shell
# history and be visible in `ps`; the AWS CLI docs for create-secret warn about
# exactly this. Do not copy a real secret into this repository either way.
aws ssm put-parameter \
  --name "$PARAM_NAME" \
  --description "SOA-C03 lab 05 SecureString protected by the lab CMK" \
  --type SecureString \
  --key-id "$KEY_ARN" \
  --tier Standard \
  --value "lab05-not-a-real-password" \
  --overwrite \
  --tags "Key=${PREFIX},Value=true" >/dev/null
echo "  $PARAM_NAME (SecureString, Standard tier, lab CMK)"

aws ssm put-parameter \
  --name "$PLAIN_PARAM_NAME" \
  --description "SOA-C03 lab 05 unencrypted String, for contrast only" \
  --type String \
  --tier Standard \
  --value "lab05-not-a-real-token" \
  --overwrite \
  --tags "Key=${PREFIX},Value=true" >/dev/null
echo "  $PLAIN_PARAM_NAME (String, no encryption)"

# ----------------------------------------------------------- 5. Secrets Manager
echo
echo "== 5. Secrets Manager secret on the same CMK =="
aws secretsmanager create-secret \
  --name "$SECRET_NAME" \
  --description "SOA-C03 lab 05 secret (disposable)" \
  --kms-key-id "$KEY_ARN" \
  --secret-string '{"username":"lab05","password":"lab05-not-a-real-password"}' \
  --tags "Key=${PREFIX},Value=true" >/dev/null
echo "  $SECRET_NAME (no recovery window argument exists on create-secret)"

# ------------------------------------------------------- 6. Config, read-only
echo
echo "== 6. Read-only check for Step 5 (AWS Config) =="
RECORDERS="$(aws configservice describe-configuration-recorders \
  --configuration-recorder-names default --output json 2>/dev/null || echo '{}')"
printf '%s' "$RECORDERS" | jq -r '
  if (.ConfigurationRecorders // []) | length == 0 then
    "  no recorder named default: Step 5 will skip"
  else
    "  recorder recording = " +
    ((.ConfigurationRecorders[0].recording // false) | tostring)
  end'

cat <<EOF

== Created. Nothing here is touched by another lab. ==
  key     $KEY_ALIAS
  bucket  ${PREFIX}-$(redact "$ACCOUNT_ID")-${REGION}
  objects $OBJ_KMS, $OBJ_AES
  ssm     $PARAM_NAME, $PLAIN_PARAM_NAME
  secret  $SECRET_NAME

Next, from the lab README:
  Step 2  ./cli/02-prove-encryption.sh
  Step 3  ./cli/03-secrets-compare.sh
  Step 4  ./cli/04-audit-evidence.sh
  Step 5  ./cli/05-config-compliance.sh   (optional, costs money)

Teardown: ./cli/99-teardown.sh
EOF