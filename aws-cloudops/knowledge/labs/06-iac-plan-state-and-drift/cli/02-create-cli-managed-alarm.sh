#!/usr/bin/env bash
# Lab 06, Step 2 — create the OpenTofu target OUT OF BAND with the AWS CLI.
#
# Creates: one SNS topic and one CloudWatch alarm, using exactly the names and
#          attribute values that ../tofu/modules/notification declares.
#
# Cost: $0. CloudWatch alarms and SNS topics are not charged. No metric data is
# ever published to the lab namespace, so the alarm never leaves a
# non-breaching state and no notification is delivered.
#
# This step exists to set up a trap on purpose. These two resources already
# exist in AWS before OpenTofu has ever heard of them. Step 3 plans against an
# empty state and the plan looks perfectly reasonable. The trap is that the
# plan is computed from configuration and state, and state knows nothing about
# resources that were never imported.
#
# Required environment:
#   AWS_PROFILE     authorized playground or personal-account profile
# Optional environment:
#   AWS_REGION      default us-east-1
#   NAME_PREFIX     default soa-c03-lab06   (must match tofu/terraform.tfvars)
#   LAB_ENV         default study           (must match tofu/terraform.tfvars)
#
set -euo pipefail

AWS_REGION="${AWS_REGION:-us-east-1}"
NAME_PREFIX="${NAME_PREFIX:-soa-c03-lab06}"
LAB_ENV="${LAB_ENV:-study}"
TAG_KEY="soa-c03-lab06"
TAG_VALUE="true"

# These must match tofu/modules/notification/main.tf locals exactly.
TOPIC_NAME="${NAME_PREFIX}-alarms"
ALARM_NAME="${NAME_PREFIX}-cpu-synthetic"
NAMESPACE="SOA-C03/Lab06"
METRIC_NAME="SyntheticLoad"
ALARM_DESCRIPTION="SOA-C03 lab 06 plan/state/drift target"
THRESHOLD=80
PERIOD=300
EVAL_PERIODS=2

if [[ -z "${AWS_PROFILE:-}" ]]; then
  echo "ERROR: set AWS_PROFILE to the authorized profile before running." >&2
  exit 1
fi

echo "== Step 0: identity =="
aws sts get-caller-identity --output json \
  | jq -r '"  account: ...." + (.Account[-4:]) + "  (redacted)"'
echo "  region:  $AWS_REGION"
echo

echo "== 1. SNS topic =="
TOPIC_ARN="$(aws sns create-topic --name "$TOPIC_NAME" \
  --tags "Key=$TAG_KEY,Value=$TAG_VALUE" \
  --query 'TopicArn' --output text)"
echo "  topic: $TOPIC_NAME"

cat <<'EOF'

  Note: aws sns create-topic is idempotent by name. If a topic with this name
  already exists, AWS returns the existing ARN instead of failing. That makes
  this particular half of the trap quieter than it looks — a "create" in the
  plan succeeded without creating anything. Treat a successful create as
  evidence of nothing until you have read the resulting state.

EOF

echo "== 2. CloudWatch alarm =="
aws cloudwatch put-metric-alarm \
  --alarm-name "$ALARM_NAME" \
  --alarm-description "$ALARM_DESCRIPTION" \
  --namespace "$NAMESPACE" \
  --metric-name "$METRIC_NAME" \
  --dimensions "Name=Environment,Value=$LAB_ENV" \
  --statistic Average \
  --period "$PERIOD" \
  --evaluation-periods "$EVAL_PERIODS" \
  --threshold "$THRESHOLD" \
  --comparison-operator GreaterThanOrEqualToThreshold \
  --treat-missing-data notBreaching \
  --alarm-actions "$TOPIC_ARN" \
  --ok-actions "$TOPIC_ARN" \
  --tags "Key=$TAG_KEY,Value=$TAG_VALUE" >/dev/null
echo "  alarm: $ALARM_NAME  (threshold $THRESHOLD, dimension Environment=$LAB_ENV)"

# Read the alarm back so the learner sees the same shape the Console shows.
echo
echo "== 3. Read back =="
aws cloudwatch describe-alarms --alarm-names "$ALARM_NAME" \
  --query 'MetricAlarms[0].{Name:AlarmName,State:StateValue,Threshold:Threshold,Period:Period,EvaluationPeriods:EvaluationPeriods,TreatMissingData:TreatMissingData,Dimensions:Dimensions,AlarmActions:AlarmActions,OKActions:OKActions,Tags:Tags}' \
  --output json

cat <<EOF

== Created out of band. Nothing knows about these yet. ==

Both resources exist in AWS. OpenTofu's state is empty or does not exist.
Step 3 runs \`tofu plan\` and you should read what it proposes and what it
cannot possibly know.

Import commands for Step 5, printed for you. The topic goes first: the alarm's
alarm_actions references the topic's ARN, so the topic has to be in state before
the alarm can be compared against it.

  cd tofu
  tofu import module.notification.aws_sns_topic.this            $TOPIC_NAME
  tofu import module.notification.aws_cloudwatch_metric_alarm.this $ALARM_NAME

After both imports, \`tofu plan\` must report no changes. If it does not, do not
apply. Find the attribute that disagrees, fix your understanding, and re-plan.
EOF
