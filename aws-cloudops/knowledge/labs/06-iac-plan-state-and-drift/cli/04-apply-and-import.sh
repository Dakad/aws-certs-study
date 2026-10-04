#!/usr/bin/env bash
# Lab 06, Step 4 — Apply + import vs recreate.
#
# For the dev stack: applies the configuration (creates topic + alarm), then
# demonstrates importing the CLI-created resources from Step 2 into the same
# state. For the prod stack: same workflow (different names, no collision).
#
# Required environment:
#   AWS_PROFILE        authorized playground or personal-account profile
#   LAB_STATE_BUCKET   printed by cli/01
#   LAB_LOCK_TABLE     printed by cli/01
# Optional environment:
#   AWS_REGION         default us-east-1
#   RUN_LIVE           set to "1" to actually run commands; default is dry-run docs
#
# Tags any created resources with soa-c03-lab06=true.
set -euo pipefail

AWS_REGION="${AWS_REGION:-us-east-1}"
TAG_KEY="soa-c03-lab06"
TAG_VALUE="true"
RUN_LIVE="${RUN_LIVE:-0}"

if [[ -z "${AWS_PROFILE:-}" ]]; then
  echo "ERROR: set AWS_PROFILE to the authorized profile before running." >&2
  exit 1
fi
if [[ -z "${LAB_STATE_BUCKET:-}" || -z "${LAB_LOCK_TABLE:-}" ]]; then
  echo "ERROR: set LAB_STATE_BUCKET and LAB_LOCK_TABLE (cli/01 prints both)." >&2
  exit 1
fi

echo "== 0: identity and targets =="
aws sts get-caller-identity --output json \
  | jq -r '"  account: ...." + (.Account[-4:]) + "  (redacted)"'
echo "  region:         $AWS_REGION"
echo "  state bucket:   $LAB_STATE_BUCKET"
echo "  lock table:     $LAB_LOCK_TABLE"
echo

export AWS_PROFILE
export AWS_REGION
export LAB_STATE_BUCKET
export LAB_LOCK_TABLE

# CLI-created resource names from Step 2 (cli/02)
CLI_NAME_PREFIX="soa-c03-lab06"
CLI_TOPIC_NAME="${CLI_NAME_PREFIX}-alarms"
CLI_ALARM_NAME="${CLI_NAME_PREFIX}-cpu-synthetic"
CLI_LAB_ENV="study"

# Dev stack config
DEV_DIR="terragrunt/envs/dev"
DEV_NAME_PREFIX="soa-c03-lab06-tg-dev"
DEV_TOPIC_NAME="${DEV_NAME_PREFIX}-alarms"
DEV_ALARM_NAME="${DEV_NAME_PREFIX}-cpu-synthetic"
DEV_ENV="dev"
DEV_THRESHOLD=90

# Prod stack config
PROD_DIR="terragrunt/envs/prod"
PROD_NAME_PREFIX="soa-c03-lab06-tg-prod"
PROD_TOPIC_NAME="${PROD_NAME_PREFIX}-alarms"
PROD_ALARM_NAME="${PROD_NAME_PREFIX}-cpu-synthetic"
PROD_ENV="prod"
PROD_THRESHOLD=70

# Helper to run commands for a stack
run_stack_workflow() {
  local stack_dir="$1"
  local stack_name="$2"
  local name_prefix="$3"
  local topic_name="$4"
  local alarm_name="$5"
  local environment="$6"
  local threshold="$7"

  echo "========================================================"
  echo "== ${stack_name} stack: apply and import workflow =="
  echo "========================================================"
  echo "  name_prefix: $name_prefix"
  echo "  topic:       $topic_name"
  echo "  alarm:       $alarm_name"
  echo "  env:         $environment"
  echo "  threshold:   $threshold"
  echo

  if [[ "$RUN_LIVE" == "1" ]]; then
    (
      cd "$stack_dir"
      
      echo "--- 1. terragrunt apply (creates new resources) ---"
      terragrunt apply -auto-approve
      echo
      
      echo "--- 2. Verify outputs match expected names ---"
      terragrunt output
      echo
      
      echo "--- 3. Check state list ---"
      terragrunt state list
      echo
      
      echo "--- 4. Now demonstrate IMPORT of CLI-created resources ---"
      echo "    The CLI-created resources from Step 2 have different names:"
      echo "      Topic: $CLI_TOPIC_NAME"
      echo "      Alarm: $CLI_ALARM_NAME (env=$CLI_LAB_ENV, threshold=80)"
      echo "    These are DIFFERENT from this stack's resources, so import would"
      echo "    target different AWS resources. Import is demonstrated conceptually."
      echo
      
      echo "    If you wanted to import the CLI-created alarm into THIS stack's state:"
      echo "    (This would fail because names don't match — demonstrating the point)"
      echo "      terragrunt import module.notification.aws_sns_topic.this $CLI_TOPIC_NAME"
      echo "      terragrunt import module.notification.aws_cloudwatch_metric_alarm.this $CLI_ALARM_NAME"
      echo
      
      echo "    The correct workflow when names DO match (same name_prefix as CLI):"
      echo "      1. terragrunt apply  # would fail: 'already exists'"
      echo "      2. terragrunt import module.notification.aws_sns_topic.this $topic_name"
      echo "      3. terragrunt import module.notification.aws_cloudwatch_metric_alarm.this $alarm_name"
      echo "      4. terragrunt plan   # should be no-op"
      echo
      
    )
  else
    cat <<EOF
  DRY RUN (set RUN_LIVE=1 to execute). The workflow would be:

  --- 1. Apply (creates new resources) ---
    cd ${stack_dir}
    terragrunt apply -auto-approve

    Expected: Creates SNS topic "$topic_name" and CloudWatch alarm "$alarm_name"
    with threshold=$threshold, environment=$environment.
    These are NEW resources (different names from Step 2 CLI resources).

  --- 2. Verify outputs ---
    terragrunt output
    Should show: topic_arn, alarm_arn, alarm_name, alarm_threshold=$threshold

  --- 3. State list ---
    terragrunt state list
    Should show:
      module.notification.aws_sns_topic.this
      module.notification.aws_cloudwatch_metric_alarm.this

  --- 4. Import demonstration (for when names match) ---
    The CLI-created resources from Step 2 use:
      Topic: $CLI_TOPIC_NAME
      Alarm: $CLI_ALARM_NAME (threshold=80, env=$CLI_LAB_ENV)

    This stack's resources use:
      Topic: $topic_name
      Alarm: $alarm_name (threshold=$threshold, env=$environment)

    Since names differ, import would target DIFFERENT AWS resources.
    This is by design: dev/prod stacks have unique names to avoid collision.

    If you ran cli/02 with NAME_PREFIX=$name_prefix instead, then:
      terragrunt import module.notification.aws_sns_topic.this $topic_name
      terragrunt import module.notification.aws_cloudwatch_metric_alarm.this $alarm_name
      terragrunt plan  # Expect no-op

    IMPORT vs RECREATE comparison:
      Import:
        - Preserves existing resource (no downtime, keeps ARN history)
        - Requires exact attribute match for no-op plan
        - State now manages what CLI created
      
      Recreate (apply without import):
        - Fails on SNS topic: "InvalidParameter: Topic name already exists"
        - Fails on CloudWatch alarm: "AlarmAlreadyExists"
        - Would require manual deletion first (data loss, ARN change)

EOF
  fi
  echo
}

# Run for dev stack
run_stack_workflow "$DEV_DIR" "dev" "$DEV_NAME_PREFIX" "$DEV_TOPIC_NAME" "$DEV_ALARM_NAME" "$DEV_ENV" "$DEV_THRESHOLD"

# Run for prod stack
run_stack_workflow "$PROD_DIR" "prod" "$PROD_NAME_PREFIX" "$PROD_TOPIC_NAME" "$PROD_ALARM_NAME" "$PROD_ENV" "$PROD_THRESHOLD"

cat <<EOF
== Apply and import workflow complete ==

Key observations to record in EVIDENCE.md:
  - For each stack: apply output showing resources created
  - The name_prefix isolation strategy (dev vs prod vs CLI)
  - Why import would fail if names matched but attributes differed
  - The "create vs import" decision matrix

Next step: cli/05-drift-resolution.sh — detect and resolve drift on dev alarm.
EOF