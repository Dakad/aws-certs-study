#!/usr/bin/env bash
# Lab 06, Step 7 — introduce drift out of band.
#
# Creates: nothing. Deletes: nothing. Changes exactly two attributes of the
#          lab alarm, directly in AWS, behind OpenTofu's back.
#
# The two changes are chosen to teach two different things:
#
#   1. threshold 80 -> 95   An in-place attribute change. The plan will propose
#                           `update`, which is cheap and reversible.
#   2. an extra tag         Tag drift. Tags are part of the desired state like
#                           any other attribute, so a tag added in the Console
#                           and never removed is drift. This is the one people
#                           forget, and it is why "the plan was empty" is not
#                           the same as "nothing changed".
#
# put-metric-alarm replaces the whole alarm definition, so every field has to be
# passed again. Omitting a field is not "leave it alone" — it resets it. That is
# itself a small lesson: an imperative API call has no notion of a partial
# desired state.
#
# Required environment:
#   AWS_PROFILE   authorized playground or personal-account profile
# Optional environment:
#   AWS_REGION      default us-east-1
#   NAME_PREFIX     default soa-c03-lab06
#   LAB_ENV         default study
#   DRIFT_THRESHOLD default 95
#
set -euo pipefail

AWS_REGION="${AWS_REGION:-us-east-1}"
NAME_PREFIX="${NAME_PREFIX:-soa-c03-lab06}"
LAB_ENV="${LAB_ENV:-study}"
DRIFT_THRESHOLD="${DRIFT_THRESHOLD:-95}"
DRIFT_TAG_KEY="soa-c03-drifted"
DRIFT_TAG_VALUE="yes"

# Must match the post-import state that Step 5 established.
ALARM_NAME="${NAME_PREFIX}-cpu-synthetic"
TOPIC_NAME="${NAME_PREFIX}-alarms"
NAMESPACE="SOA-C03/Lab06"
METRIC_NAME="SyntheticLoad"
ALARM_DESCRIPTION="SOA-C03 lab 06 plan/state/drift target"
PERIOD=300
EVAL_PERIODS=2

if [[ -z "${AWS_PROFILE:-}" ]]; then
  echo "ERROR: set AWS_PROFILE to the authorized profile before running." >&2
  exit 1
fi

echo "== 0. Confirm the alarm exists before changing it =="
CURRENT="$(aws cloudwatch describe-alarms --alarm-names "$ALARM_NAME" \
  --query 'MetricAlarms[0].Threshold' --output text 2>/dev/null || true)"
if [[ -z "$CURRENT" || "$CURRENT" == "None" ]]; then
  echo "ERROR: alarm $ALARM_NAME not found. Run Step 2 first." >&2
  exit 1
fi
echo "  current threshold in AWS: $CURRENT"
echo

TOPIC_ARN="arn:aws:sns:${AWS_REGION}:$(aws sts get-caller-identity --query Account --output text):${TOPIC_NAME}"

echo "== 1. Change the threshold out of band =="
aws cloudwatch put-metric-alarm \
  --alarm-name "$ALARM_NAME" \
  --alarm-description "$ALARM_DESCRIPTION" \
  --namespace "$NAMESPACE" \
  --metric-name "$METRIC_NAME" \
  --dimensions "Name=Environment,Value=$LAB_ENV" \
  --statistic Average \
  --period "$PERIOD" \
  --evaluation-periods "$EVAL_PERIODS" \
  --threshold "$DRIFT_THRESHOLD" \
  --comparison-operator GreaterThanOrEqualToThreshold \
  --treat-missing-data notBreaching \
  --alarm-actions "$TOPIC_ARN" \
  --ok-actions "$TOPIC_ARN" >/dev/null
echo "  threshold is now $DRIFT_THRESHOLD in AWS; configuration still says 80"
echo

echo "== 2. Add a tag that configuration does not declare =="
ALARM_ARN="$(aws cloudwatch describe-alarms --alarm-names "$ALARM_NAME" \
  --query 'MetricAlarms[0].AlarmArn' --output text)"
aws cloudwatch tag-resource --resource-arn "$ALARM_ARN" \
  --tags "Key=$DRIFT_TAG_KEY,Value=$DRIFT_TAG_VALUE" >/dev/null
echo "  added $DRIFT_TAG_KEY=$DRIFT_TAG_VALUE"
echo

echo "== 3. Live state, for comparison with the plan =="
aws cloudwatch describe-alarms --alarm-names "$ALARM_NAME" \
  --query 'MetricAlarms[0].{Threshold:Threshold,Tags:Tags}' --output json

cat <<EOF

== Drift is now in place. OpenTofu has not been told. ==

From ../tofu:

  tofu plan -out=drift.tfplan
  tofu show -json drift.tfplan | jq -r '.resource_changes[]? | "\(.address)\t\(.change.actions | join(","))"'

Then choose ONE, deliberately, and write down why before you run it:

  (a) tofu apply drift.tfplan
      Configuration wins. The out-of-band change is reverted. Correct when the
      live change was a mistake, an experiment, or someone acting without
      review.

  (b) Edit the threshold in terraform.tfvars (or pass -var alarm_threshold=$DRIFT_THRESHOLD),
      re-plan, and expect a no-op.
      Reality wins. Correct when the live change was an intentional, reviewed
      decision that simply has not been written down yet. Adopting a change
      nobody reviewed is how an accident becomes the standard.

  (c) tofu state rm module.notification.aws_cloudwatch_metric_alarm.this
      then re-import it.
      Stop pretending to manage it. Correct only when the alarm should leave
      OpenTofu's management entirely. Note that after the rm the next plan shows
      a create again, which is Step 6's lesson repeating itself.

Do not run all three. The skill being assessed is choosing from the plan and
justifying the choice, not collecting all the options.
EOF
