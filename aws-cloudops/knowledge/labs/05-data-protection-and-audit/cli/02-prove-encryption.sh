#!/usr/bin/env bash
# Lab 05, Step 2 - prove which encryption is in effect, and separate encryption
# configuration from authorization.
#
# Read-only. Nothing in this script creates, changes, or deletes anything.
#
# The question this answers: for one object and one parameter, what can I read
# that tells me a customer-managed key is doing the encryption, and what would
# still look the same if the caller had no permission to use that key?
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

ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
BUCKET="${PREFIX}-${ACCOUNT_ID}-${REGION}"
KEY_ID="$(aws kms list-aliases --key-id "$KEY_ALIAS" --query 'Aliases[0].TargetKeyId' --output text)"
if [[ -z "$KEY_ID" || "$KEY_ID" == "None" ]]; then
  echo "ERROR: ${KEY_ALIAS} not found. Run ./cli/01-create.sh first." >&2
  exit 1
fi
CALLER_ARN="$(aws sts get-caller-identity --query Arn --output text)"

# ------------------------------------------------------------------- 1. the key
echo "== 1. The customer-managed key =="
aws kms describe-key --key-id "$KEY_ID" \
  --query 'KeyMetadata.{KeyId:KeyId,State:KeyState,Manager:KeyManager,Usage:KeyUsage,Origin:Origin,Spec:CustomerMasterKeySpec,Created:CreationDate,Description:Description,DeletionDate:DeletionDate}' \
  --output table

echo "aliases pointing at this key:"
aws kms list-aliases --key-id "$KEY_ID" \
  --query 'Aliases[].AliasName' --output text

echo
echo "key policy statements:"
aws kms get-key-policy --key-id "$KEY_ID" --policy-name default --query 'Policy' --output text \
  | jq -r '.Statement[] | "  effect=\(.Effect) actions=\(.Action|join(",")) principals=\(.Principal|tostring)"'

cat <<'GUIDE'
  Read the key policy before the IAM policy. A KMS key is usable only when the
  key policy allows it AND an IAM policy allows it. Encryption being configured
  tells you nothing about whether a caller may decrypt.
GUIDE

# --------------------------------------------------- 2. grants held by services
echo
echo "== 2. Grants that let AWS services use the key on your behalf =="
aws kms list-grants --key-id "$KEY_ID" \
  --query 'Grants[].{Name:Name,GranteeServicePrincipal:GranteeServicePrincipal,GranteePrincipal:GranteePrincipal,Operations:Operations}' \
  --output table 2>/dev/null || echo "  (no grants, or the call was denied)"

cat <<'GUIDE'
  A grant with GranteeServicePrincipal=aws:s3 is not a permission for a human.
  It is the grant under which S3 asks KMS to decrypt on the caller's behalf,
  and the grant is bound to the bucket. Nothing on this key lets a caller skip
  the S3 authorization check by decrypting directly.
GUIDE

# ------------------------------------------------------ 3. bucket default + per-object
echo
echo "== 3. Bucket default encryption =="
aws s3api get-bucket-encryption --bucket "$BUCKET" \
  --query 'ServerSideEncryptionConfiguration.Rules[].ApplyServerSideEncryptionByDefault.{Algorithm:SSEAlgorithm,KMSMasterKeyID:KMSMasterKeyID}' \
  --output table

echo
echo "== 4. Per-object encryption, read back from the object metadata =="
for obj in "$OBJ_KMS" "$OBJ_AES"; do
  printf '  %s\n' "$obj"
  aws s3api head-object --bucket "$BUCKET" --key "$obj" \
    --query '{ServerSideEncryption:ServerSideEncryption,SSEKMSKeyId:SSEKMSKeyId,BucketKeyEnabled:BucketKeyEnabled,Size:ContentLength}' \
    --output json 2>/dev/null | jq -r 'to_entries[] | "      \(.key): \(.value // "absent")"'
done

echo
echo "decrypting the bucket-default object end to end (this is the proof):"
aws s3api get-object --bucket "$BUCKET" --key "$OBJ_KMS" /dev/stdout 2>/dev/null || \
  echo "  FAILED to read it back; record that outcome and stop guessing."

cat <<'GUIDE'
  Predict first: the second object asked for AES256 and the bucket default says
  aws:kms. Which one does the object report? Per-object SSE headers win over the
  bucket default, so it should report AES256 and no key id. That is also why
  "the bucket is encrypted" is not a per-object guarantee.
GUIDE

# --------------------------------------------------------- 5. the secret stores
echo
echo "== 5. SSM Parameter Store: metadata without the value =="
aws ssm describe-parameters --parameter-filters "Key=Name,Option=BeginsWith,Values=${PREFIX}" \
  --query 'Parameters[].{Name:Name,Type:Type,KeyId:KeyId,Tier:Tier,Version:Version,LastModifiedDate:LastModifiedDate}' \
  --output table

echo
echo "retrieving the SecureString WITHOUT --with-decryption (expected to fail):"
set +e
aws ssm get-parameter --name "$PARAM_NAME" --output text 2>&1 | head -3
set -e

echo
echo "retrieving the SecureString WITH --with-decryption (value length only):"
VALUE="$(aws ssm get-parameter --name "$PARAM_NAME" --with-decryption \
  --query 'Parameter.Value' --output text)"
echo "  ${#VALUE} characters returned; not printed by this script"

echo
echo "the unencrypted String parameter needs no --with-decryption:"
PLAIN="$(aws ssm get-parameter --name "$PLAIN_PARAM_NAME" --query 'Parameter.Value' --output text)"
echo "  ${#PLAIN} characters returned; not printed by this script"

echo
echo "Secrets Manager describe (metadata, no value):"
aws secretsmanager describe-secret --secret-id "$SECRET_NAME" \
  --query '{Name:Name,KmsKeyId:KmsKeyId,RotationEnabled:RotationEnabled,RotationLambdaARN:RotationLambdaARN,CreatedDate:CreatedDate,LastChangedDate:LastChangedDate,LastAccessedDate:LastAccessedDate,VersionIdsToStages:VersionIdsToStages}' \
  --output json 2>/dev/null | jq .

# ------------------------------------------- 6. resource-level encryption survey
echo
echo "== 6. Read-only survey of encryption elsewhere in this account/region =="
echo "account-level EBS encryption by default:"
aws ec2 get-ebs-encryption-by-default --output json 2>/dev/null || echo "  (call unavailable or denied)"

echo "existing volumes (read-only, nothing is modified):"
aws ec2 describe-volumes --filters Name=status,Values=available,in-use \
  --query 'Volumes[].{Id:VolumeId,State:State,Encrypted:Encrypted,KmsKeyId:KmsKeyId}' \
  --output table 2>/dev/null || echo "  (call unavailable or denied)"

# ---------------------------------------------- 7. encryption vs authorization
echo
echo "== 7. Authorization for decrypt, simulated for your own principal =="
aws iam simulate-principal-policy \
  --policy-source-arn "$CALLER_ARN" \
  --action-names s3:GetObject kms:Decrypt \
  --query 'EvaluationResults[].{Action:EvalActionName,Decision:EvalDecision,Matched:MatchedStatements[].SourcePolicyId}' \
  --output json 2>/dev/null || echo "  (simulator unavailable or denied)"

cat <<'GUIDE'
  Two different permissions, checked at two different places:
    s3:GetObject   checked by S3 against the bucket policy and your IAM policy
    kms:Decrypt    checked by KMS against the key policy and your IAM policy
  Both are needed to read an SSE-KMS object. An AES256 object only needs the
  first, because the AWS-managed S3 key is not yours to authorize.

  The simulator takes the boundary but not the key policy, so a kms:Decrypt
  decision from it is incomplete by construction. That is the same limitation
  Lab 03 Step 4 relies on, and the reason the real key policy above matters.
GUIDE