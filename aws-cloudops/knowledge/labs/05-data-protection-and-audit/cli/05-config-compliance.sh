#!/usr/bin/env bash
# Lab 05, Step 5 (optional) - AWS Config compliance evidence.
#
# This is the only step in this lab that can produce an unexpected charge, so it
# is optional and separately costed. Read the cost table in the README first.
#
# It creates exactly one AWS Config managed rule, scoped to AWS::S3::Bucket and
# limited to one evaluation per hour, then reads back its compliance state.
# It never creates or deletes a configuration recorder or a delivery channel:
# those are account-level and may be shared with other work.
#
# Override the managed rule identifier if the default is not available:
#   CONFIG_RULE_ID=ACM_CERTIFICATE_EXPIRY_CHECK ./cli/05-config-compliance.sh
#
set -euo pipefail

PREFIX="soa-c03-lab05"
REGION="${AWS_REGION:-${AWS_DEFAULT_REGION:-us-east-1}}"
CONFIG_RULE_NAME="${PREFIX}-${CONFIG_RULE_ID:-S3_BUCKET_SSL_REQUESTS_ONLY}"
CONFIG_RULE_ID="${CONFIG_RULE_ID:-S3_BUCKET_SSL_REQUESTS_ONLY}"

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

# --------------------------------------------------- 1. is a recorder running?
echo "== 1. Is an AWS Config recorder running in ${REGION}? =="
RECORDERS="$(aws configservice describe-configuration-recorders \
  --configuration-recorder-names default --output json 2>/dev/null || echo '{}')"
RECORDING="$(printf '%s' "$RECORDERS" \
  | jq -r '(.ConfigurationRecorders // []) | if length == 0 then "absent" else (.[0].recording // false | tostring) end')"
echo "recorder 'default' recording: ${RECORDING}"

if [[ "$RECORDING" != "true" ]]; then
  cat <<'GUIDE'
  No recorder is running, so a Config rule cannot produce compliance results
  here. This script will not create one: a recorder plus a delivery channel are
  account-level resources that cost money while they exist and that other work in
  this account may already depend on.

  What you can still establish without one, read-only:
    - the rule identifier exists, so you know what you would deploy
    - "no compliance evidence" is a finding about evidence, not about compliance

  To run this step for real, an authorized person creates the recorder and the
  S3 delivery channel, and this step becomes meaningful. Record that you stopped
  here rather than treating an empty result as a compliant account.
GUIDE
  echo
  echo "managed rule identifier this step would use: ${CONFIG_RULE_ID}"
  echo "rule name it would create:                 ${CONFIG_RULE_NAME}"
  echo
  echo "clean - no AWS Config resource was created."
  exit 0
fi

# ------------------------------------------------------------ 2. create the rule
echo
echo "== 2. One managed rule, scoped to S3 buckets, one evaluation per hour =="
RULE_JSON="$(jq -cn --arg name "$CONFIG_RULE_NAME" --arg id "$CONFIG_RULE_ID" '{
  ConfigRuleName: $name,
  Description: ("SOA-C03 lab 05 disposable rule for " + $id),
  Scope: { ComplianceResourceTypes: ["AWS::S3::Bucket"] },
  Source: { Owner: "AWS", SourceIdentifier: $id },
  MaximumExecutionFrequency: "One_Hour"
}')"
printf '%s\n' "$RULE_JSON" | jq .

set +e
aws configservice put-config-rule --config-rule "$RULE_JSON" \
  --tags "Key=${PREFIX},Value=true" >/dev/null 2>&1
RC=$?
set -e
if [[ "$RC" -ne 0 ]]; then
  echo
  echo "put-config-rule failed. Re-run it by hand to read the message:"
  echo "  aws configservice put-config-rule --config-rule '$RULE_JSON'"
  echo
  echo "The usual cause is a managed-rule identifier that does not exist or is"
  echo "not enabled in this region. Pick one from the official managed-rules list"
  echo "and re-run with CONFIG_RULE_ID=<identifier>."
  exit "$RC"
fi
echo "created: ${CONFIG_RULE_NAME} (source ${CONFIG_RULE_ID})"

# --------------------------------------------- 3. rule state vs compliance state
echo
echo "== 3. Rule state (is it running?) =="
aws configservice describe-config-rules --config-rule-names "$CONFIG_RULE_NAME" \
  --query 'ConfigRules[].{Name:ConfigRuleName,State:ConfigRuleState,SourceIdentifier:Source.SourceIdentifier,Frequency:MaximumExecutionFrequency,ScopeTypes:Scope.ComplianceResourceTypes}' \
  --output json 2>/dev/null | jq .

echo
echo "== 4. Compliance state (what did it find?) =="
aws configservice describe-compliance-by-config-rule \
  --config-rule-names "$CONFIG_RULE_NAME" --output json 2>/dev/null \
  | jq '.ComplianceByConfigRules[]?
         | {ConfigRuleName: .ConfigRuleName,
            ComplianceType: .Compliance.ComplianceType,
            ContributorCount: .Compliance.ComplianceContributorCount.CappedCount}' \
  || echo "(no compliance summary yet)"

echo
echo "== 5. Per-resource detail, including this lab's own bucket =="
aws configservice get-compliance-details-by-config-rule \
  --config-rule-name "$CONFIG_RULE_NAME" --output json 2>/dev/null \
  | jq -r --arg b "$BUCKET" '
      if (.EvaluationResults // []) | length == 0 then
        "   NO EVALUATION RESULTS YET for this rule"
      else
        ( "   " + ((.EvaluationResults | length) | tostring) + " evaluation result(s)" ),
        ( .EvaluationResults[]
          | "     resource=\(.EvaluationResultIdentifier.EvaluationResultQualifier.ResourceId) state=\(.ComplianceType) recorded=\(.ResultRecordedTime) invoked=\(.ConfigRuleInvokedTime)"
        ),
        ( "   our bucket is in the list: " +
          (if ([.EvaluationResults[].EvaluationResultIdentifier.EvaluationResultQualifier.ResourceId]
               | index($b)) != null then "YES" else "NO" end)
        )
      end' || echo "(detail lookup failed)"

cat <<'GUIDE'
  Three different states, and mixing them up is the mistake this step is for:
    ConfigRuleState        ACTIVE / DELETING / EVALUATING. Whether the rule runs.
    ComplianceType         COMPLIANT / NON_COMPLIANT / NOT_APPLICABLE /
                           INSUFFICIENT_DATA. What it concluded about a resource.
    EvaluationResults[]    one entry per resource, with the time it was recorded.

  A brand-new rule usually has no results for a while: evaluations are driven by
  configuration-item changes, by the delivery channel, or by an explicit
  start-config-rule-evaluation call, not by creating the rule. If step 5 is
  empty, check that reason before concluding the bucket is compliant.

  This lab's bucket is in scope, so if the rule produces any result at all you
  should be able to find it. Confirm whether it does, and record that.

  Cleanup: ./cli/99-teardown.sh deletes only this rule. It never touches the
  recorder or the delivery channel.
GUIDE