#!/usr/bin/env bash
# Lab 06 teardown — remove every resource this lab created, then prove it.
#
# Order matters:
#   1. alarms, so nothing can fire while the topic disappears
#   2. topics
#   3. every object version in the state bucket, then the bucket
#   4. the DynamoDB lock table
#   5. verification
#
# ############################################################################
# #  WARNING — STEP 3 DESTROYS THE STATE FILE                                #
# #                                                                          #
# # Deleting the objects in the state bucket deletes OpenTofu's record of     #
# # what it manages. Every resource still listed in state becomes unmanaged    #
# # and untracked: the next plan will propose creating it again, and you have  #
# # lost the IDs needed to import or clean it up.                             #
# #                                                                          #
# # Run `tofu destroy` FIRST, and only run this script once it has finished   #
# # and you have confirmed there is nothing left worth importing. The script  #
# # asks for LAB06_DESTROY_STATE=yes to proceed past that point.              #
# ############################################################################
#
# The script prints "clean" only when every verification query comes back empty
# or not-found. Anything else exits non-zero.
#
# Requires LAB_STATE_BUCKET and LAB_STATE_KEY (cli/01 prints both).
#
set -euo pipefail

PREFIX="soa-c03-lab06"
TAG_KEY="soa-c03-lab06"
TAG_VALUE="true"

ACCOUNT_LAST4="unknown"
if [[ -n "${AWS_PROFILE:-}" ]]; then
  ACCOUNT_LAST4="$(aws sts get-caller-identity --query Account --output text | tail -c 4)"
fi
BUCKET="${LAB_STATE_BUCKET:-soa-c03-lab06-tfstate-${ACCOUNT_LAST4}-${AWS_REGION:-us-east-1}}"
TABLE="${LAB_LOCK_TABLE:-soa-c03-lab06-tfstate-locks}"
KEY="${LAB_STATE_KEY:-soa-c03-lab06/study/terraform.tfstate}"

echo "== 0: identity and targets =="
aws sts get-caller-identity --output json \
  | jq -r '"  account: ...." + (.Account[-4:]) + "  (redacted)"'
echo "  state bucket: $BUCKET"
echo "  state key:    $KEY"
echo "  lock table:   $TABLE"
echo

if [[ -z "${AWS_PROFILE:-}" ]]; then
  echo "ERROR: set AWS_PROFILE to the authorized profile before running." >&2
  exit 1
fi

echo "== 1. Deleting CloudWatch alarms =="
ALARMS="$(aws cloudwatch describe-alarms --alarm-name-prefix "$PREFIX" \
  --query 'MetricAlarms[].AlarmName' --output text)"
if [[ "$ALARMS" == "None" || -z "$ALARMS" ]]; then
  echo "  none found"
else
  for a in $ALARMS; do
    echo "  deleting $a"
    aws cloudwatch delete-alarms --alarm-names "$a"
  done
fi
echo

echo "== 2. Deleting SNS topics =="
TOPICS="$(aws sns list-topics \
  --query "Topics[?ends_with(TopicArn, '-${PREFIX}-alarms') || contains(TopicArn, '${PREFIX}-alarms')].TopicArn" \
  --output text)"
if [[ "$TOPICS" == "None" || -z "$TOPICS" ]]; then
  echo "  none found"
else
  for t in $TOPICS; do
    echo "  deleting $t"
    aws sns delete-topic --topic-arn "$t"
  done
fi
echo

# ---------------------------------------------------------------- 3. bucket
echo "== 3. S3 state bucket (this destroys the state file) =="
if aws s3api head-bucket --bucket "$BUCKET" >/dev/null 2>&1; then
  if [[ "${LAB06_DESTROY_STATE:-}" != "yes" ]]; then
    echo "  bucket $BUCKET exists."
    echo "  Refusing to delete its objects without LAB06_DESTROY_STATE=yes."
    echo
    echo "  Before you set it, make sure you have already run, from ../tofu:"
    echo "    tofu plan -destroy -out=destroy.tfplan   # read it"
    echo "    tofu destroy destroy.tfplan"
    echo "    tofu state list                          # should be empty"
    echo
    echo "  Still set it if the state is genuinely disposable, e.g. after a"
    echo "  crashed run whose resources you have already deleted by hand."
    exit 2
  fi

  # Versioning is enabled on this bucket, so a plain delete leaves delete
  # markers and old versions behind and the bucket will not empty. Every
  # version and every delete marker has to go explicitly.
  echo "  listing object versions under ${PREFIX}/ ..."
  PAYLOADS="$(mktemp -t lab06-delete)"
  ONE="$(mktemp -t lab06-delete-one)"
  trap 'rm -f "$PAYLOADS" "$ONE"' EXIT

  # delete-objects takes at most 1000 keys per request, and needs Key plus
  # VersionId to remove a specific version rather than adding another marker.
  # jq builds the request bodies so nothing is hand-formatted.
  aws s3api list-object-versions --bucket "$BUCKET" --prefix "${PREFIX}/" --output json \
    | jq -c '[.Versions[]?, .DeleteMarkers[]? | {Key: .Key, VersionId: .VersionId}] as $all
             | [range(0; $all | length; 1000) as $i | {Objects: $all[$i:($i + 1000)]}][]' \
    > "$PAYLOADS"

  COUNT="$(wc -l < "$PAYLOADS" | tr -d ' ')"
  echo "  $COUNT delete request(s) to send"

  while IFS= read -r payload; do
    [[ -z "$payload" ]] && continue
    printf '%s' "$payload" > "$ONE"
    aws s3api delete-objects --bucket "$BUCKET" --delete "@$ONE" >/dev/null
  done < "$PAYLOADS"

  rm -f "$PAYLOADS" "$ONE"
  trap - EXIT

  # Anything outside the lab prefix would not have been caught above, and this
  # bucket is state storage that other work may share. Refuse to guess.
  STRAY="$(aws s3api list-object-versions --bucket "$BUCKET" --output json \
    | jq --arg p "${PREFIX}/" \
        '[.Versions[]?, .DeleteMarkers[]? | select(.Key | startswith($p) | not)] | length')"
  if [[ "$STRAY" != "0" ]]; then
    echo "  REFUSING to delete the bucket: $STRAY object(s) outside the ${PREFIX}/ prefix remain."
    echo "  List them with:"
    echo "    aws s3api list-object-versions --bucket $BUCKET --output json \\"
    echo "      | jq -r '.Versions[]?.Key, .DeleteMarkers[]?.Key'"
    echo "  Shared state storage is not this script's to delete."
    exit 2
  fi

  echo "  deleting bucket"
  aws s3api delete-bucket --bucket "$BUCKET"
else
  echo "  bucket already gone"
fi
echo

echo "== 4. Deleting DynamoDB lock table =="
if aws dynamodb describe-table --table-name "$TABLE" >/dev/null 2>&1; then
  echo "  deleting $TABLE"
  aws dynamodb delete-table --table-name "$TABLE" >/dev/null
  echo "  waiting for deletion (can take a minute)..."
  aws dynamodb wait table-not-exists --table-name "$TABLE"
else
  echo "  already gone"
fi
echo

# ------------------------------------------------------------ 5. verification
echo "== 5. Verification =="
FAILED=0

check_empty() {
  local label="$1" result="$2"
  if [[ "$result" == "None" || -z "$result" ]]; then
    printf '  %-20s empty        OK\n' "$label"
  else
    printf '  %-20s %s  STILL PRESENT\n' "$label" "$result"
    FAILED=1
  fi
}

check_gone() {
  local label="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    printf '  %-20s still exists  STILL PRESENT\n' "$label"
    FAILED=1
  else
    printf '  %-20s not found    OK\n' "$label"
  fi
}

check_empty "alarms" "$(aws cloudwatch describe-alarms --alarm-name-prefix "$PREFIX" \
  --query 'MetricAlarms[].AlarmName' --output text)"

check_empty "topics" "$(aws sns list-topics \
  --query "Topics[?contains(TopicArn, '${PREFIX}-alarms')].TopicArn" --output text)"

check_gone "state bucket" aws s3api head-bucket --bucket "$BUCKET"

check_gone "lock table" aws dynamodb describe-table --table-name "$TABLE"

echo
if [[ "$FAILED" -eq 0 ]]; then
  echo "clean — no soa-c03-lab06 resources remain."
  echo "Confirm the same four queries in the Console before calling the lab done,"
  echo "then paste this block into EVIDENCE.md."
else
  echo "INCOMPLETE — see the STILL PRESENT lines above."
  echo "Resolve them before calling the lab finished."
fi
exit "$FAILED"
