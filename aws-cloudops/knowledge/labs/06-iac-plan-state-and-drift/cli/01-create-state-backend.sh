#!/usr/bin/env bash
# Lab 06, Step 1 — create the remote-state backend with the AWS CLI.
#
# Creates: one versioned, encrypted, private S3 bucket for OpenTofu state, and
#          one on-demand DynamoDB table for the legacy DynamoDB lock method.
#
# Cost: effectively $0. A few KB of S3 objects and a handful of DynamoDB
# requests. Nothing here runs compute. That is deliberate: this lab is about
# plan and state mechanics, which need no instance.
#
# This script does NOT create anything OpenTofu manages. The bucket and the
# table are deliberately OUTSIDE the lab configuration's `tofu/` directory, so
# `tofu destroy` can never delete the state it is reading from. This is the
# same separation of concerns the S3 backend documentation describes: the tool
# that stores state should not itself be managed by the tool whose state it
# stores.
#
# Required environment:
#   AWS_PROFILE     authorized playground or personal-account profile
# Optional environment:
#   AWS_REGION      default us-east-1
#   LAB_ENV         value for the alarm's Environment dimension, default study
#
set -euo pipefail

AWS_REGION="${AWS_REGION:-us-east-1}"
LAB_ENV="${LAB_ENV:-study}"
TAG_KEY="soa-c03-lab06"
TAG_VALUE="true"

if [[ -z "${AWS_PROFILE:-}" ]]; then
  echo "ERROR: set AWS_PROFILE to the authorized profile before running." >&2
  exit 1
fi

echo "== Step 0: identity and region =="
IDENTITY="$(aws sts get-caller-identity --output json)"
ACCOUNT_ID="$(printf '%s' "$IDENTITY" | jq -r '.Account')"
ACCOUNT_LAST4="$(printf '%s' "$ACCOUNT_ID" | tail -c 4)"
echo "  account: ....$ACCOUNT_LAST4  (redacted; never write the full ID into this repo)"
echo "  region:  $AWS_REGION"
echo

# Bucket names are globally unique, so the name has to be derived at run time
# rather than committed. It is derived from the account ID and region, both
# resolved above.
BUCKET="soa-c03-lab06-tfstate-${ACCOUNT_LAST4}-${AWS_REGION}"
TABLE="soa-c03-lab06-tfstate-locks"
KEY="soa-c03-lab06/study/terraform.tfstate"

echo "== Resolved identifiers (redacted) =="
printf '  state bucket : %s\n' "$(printf '%s' "$BUCKET" | sed -E 's/-[0-9]{4}-/-....-/')"
printf '  lock table   : %s\n' "$TABLE"
printf '  state key    : %s\n' "$KEY"
echo

# ------------------------------------------------------------------- bucket
echo "== 1. S3 state bucket =="
if aws s3api head-bucket --bucket "$BUCKET" >/dev/null 2>&1; then
  echo "  bucket already exists, leaving it alone"
else
  # us-east-1 is the global endpoint and rejects an explicit
  # LocationConstraint; every other region requires one.
  if [[ "$AWS_REGION" == "us-east-1" ]]; then
    aws s3api create-bucket --bucket "$BUCKET" >/dev/null
  else
    aws s3api create-bucket --bucket "$BUCKET" \
      --create-bucket-configuration "LocationConstraint=$AWS_REGION" >/dev/null
  fi
  echo "  created"
fi

# Versioning is not optional for a state bucket: it is the only thing that makes
# an accidental state deletion recoverable, because deleting the current state
# object without versioning destroys the record of what you manage.
echo "== 2. Bucket versioning, encryption, public access block =="
aws s3api put-bucket-versioning --bucket "$BUCKET" \
  --versioning-configuration Status=Enabled >/dev/null
echo "  versioning enabled"

aws s3api put-bucket-encryption --bucket "$BUCKET" \
  --server-side-encryption-configuration \
  '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}' >/dev/null
echo "  server-side encryption AES256"

aws s3api put-public-access-block --bucket "$BUCKET" \
  --public-access-block-configuration \
  BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true \
  >/dev/null
echo "  all four public access blocks enabled"

# Versioning without a lifecycle rule means every state write leaves a
# noncurrent version behind forever. Seven days is plenty to notice a bad apply
# and long enough that it costs nothing measurable.
aws s3api put-bucket-lifecycle-configuration --bucket "$BUCKET" \
  --lifecycle-configuration \
  '{"Rules":[{"ID":"lab06-expire-noncurrent","Status":"Enabled","Filter":{"Prefix":""},"NoncurrentVersionExpiration":{"NoncurrentDays":7}}]}' \
  >/dev/null
echo "  noncurrent versions expire after 7 days"

aws s3api put-bucket-tagging --bucket "$BUCKET" \
  --tagging "TagSet=[{Key=$TAG_KEY,Value=$TAG_VALUE}]" >/dev/null
echo "  tagged $TAG_KEY=$TAG_VALUE"
echo

# -------------------------------------------------------------- lock table
# Partition key must be a String named LockID. That exact name is not a
# convention: it is the key the backend reads, so a table with any other key
# schema silently disables locking.
echo "== 3. DynamoDB lock table =="
if aws dynamodb describe-table --table-name "$TABLE" >/dev/null 2>&1; then
  echo "  table already exists, leaving it alone"
else
  aws dynamodb create-table \
    --table-name "$TABLE" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --tags "Key=$TAG_KEY,Value=$TAG_VALUE" >/dev/null
  echo "  created on-demand (no provisioned capacity to be billed for)"
fi

echo "  waiting for ACTIVE..."
aws dynamodb wait table-exists --table-name "$TABLE"
echo "  active"
echo

cat <<EOF
== Backend ready. Copy-paste this into your shell. ==
== It contains a real bucket name; do not paste it into this repository. ==

export AWS_PROFILE="$AWS_PROFILE"
export AWS_REGION="$AWS_REGION"
export LAB_STATE_BUCKET="$BUCKET"
export LAB_STATE_KEY="$KEY"
export LAB_LOCK_TABLE="$TABLE"

cd tofu
tofu init -reconfigure \\
  -backend-config="bucket=$BUCKET" \\
  -backend-config="key=$KEY" \\
  -backend-config="region=$AWS_REGION" \\
  -backend-config="use_lockfile=true"

Notes on that command:
  use_lockfile=true   S3-native locking via conditional writes (If-None-Match).
                      This is the mechanism the OpenTofu documentation prefers.
  -reconfigure        Required whenever the backend block or its configuration
                      changes. Without it init may reuse the previous backend
                      settings from .terraform/ and silently keep talking to the
                      old location.
  dynamodb_table      Not passed yet. Step 8 adds it to compare the two locking
                      mechanisms and to walk the documented migration path.

Environment: LAB_ENV=$LAB_ENV  (carried into cli/02 so the alarm's Environment
dimension matches terraform.tfvars)
EOF
