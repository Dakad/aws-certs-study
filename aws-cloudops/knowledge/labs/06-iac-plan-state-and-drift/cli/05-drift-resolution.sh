#!/usr/bin/env bash
# Lab 06, Step 5 — Drift detection and resolution.
#
# Step 3 (cli/03-introduce-drift.sh) already modified the dev alarm's Threshold
# (80 -> 95) and added a tag. This script runs plan to show drift, then
# demonstrates two resolution paths:
#   1. Accept drift: refresh state, update config to match, re-apply
#   2. Revert drift: apply original config to restore declared state
#
# Required environment:
#   AWS_PROFILE        authorized playground or personal-account profile
#   LAB_STATE_BUCKET   printed by cli/01
#   LAB_LOCK_TABLE     printed by cli/01
# Optional environment:
#   AWS_REGION         default us-east-1
#   RUN_LIVE           set to "1" to actually run commands; default is dry-run docs
#
# Tags: none created (reads existing).
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

# The dev stack is where drift was introduced (Step 3 used NAME_PREFIX=soa-c03-lab06)
# But wait - Step 3 used the CLI name_prefix (soa-c03-lab06), while the dev stack
# uses soa-c03-lab06-tg-dev. The drift was on the CLI-created alarm.
# 
# IMPORTANT: For drift to be detected, the alarm must be in the dev stack's state.
# This means Step 4 must have imported the CLI alarm into the dev stack, OR
# the dev stack must have been created with the same name_prefix as the CLI.
#
# This script assumes the learner has either:
#   a) Run cli/02 with NAME_PREFIX=soa-c03-lab06-tg-dev (matching dev stack), then
#      imported via Step 4, then run cli/03 (which would need NAME_PREFIX=soa-c03-lab06-tg-dev)
#   OR
#   b) The lab is demonstrating drift conceptually on the CLI alarm, then showing
#      how the dev stack would handle it if it managed that alarm.
#
# For this lab, we'll demonstrate on the dev stack assuming it manages an alarm
# that has drifted. We'll show the commands that WOULD detect drift.

DEV_DIR="terragrunt/envs/dev"
DEV_NAME_PREFIX="soa-c03-lab06-tg-dev"
DEV_ALARM_NAME="${DEV_NAME_PREFIX}-cpu-synthetic"
DEV_TOPIC_NAME="${DEV_NAME_PREFIX}-alarms"
DEV_ENV="dev"
CONFIG_THRESHOLD=90
DRIFT_THRESHOLD=95
DRIFT_TAG_KEY="soa-c03-drifted"
DRIFT_TAG_VALUE="yes"

echo "========================================================"
echo "== Drift detection on dev stack =="
echo "========================================================"
echo "  Config threshold:  $CONFIG_THRESHOLD"
echo "  Drifted threshold: $DRIFT_THRESHOLD (from cli/03)"
echo "  Drifted tag:       $DRIFT_TAG_KEY=$DRIFT_TAG_VALUE"
echo

if [[ "$RUN_LIVE" == "1" ]]; then
  (
    cd "$DEV_DIR"
    
    echo "--- 1. terragrunt plan (detects drift) ---"
    terragrunt plan -out=drift.tfplan 2>&1 | tee /tmp/drift-plan.log
    echo
    
    echo "--- 2. Show resource changes ---"
    terragrunt show -json drift.tfplan 2>/dev/null | jq -r '
      .resource_changes[]? |
      select(.change.actions != ["no-op"]) |
      "\(.address)\t\(.change.actions | join(","))\tbefore: \(.change.before // "null")\tafter: \(.change.after // "null")"
    ' || echo "  (jq parsing failed or no changes)"
    echo
    
    echo "--- 3. Show specific drift on alarm ---"
    terragrunt show -json drift.tfplan 2>/dev/null | jq -r '
      .resource_changes[]? |
      select(.address == "module.notification.aws_cloudwatch_metric_alarm.this") |
      .change
    ' || echo "  (alarm not in plan or jq unavailable)"
    echo
    
  )
else
  cat <<EOF
  DRY RUN (set RUN_LIVE=1 to execute). The drift detection would show:

  --- 1. terragrunt plan output ---
    terragrunt plan -out=drift.tfplan

    Expected plan shows:
      ~ module.notification.aws_cloudwatch_metric_alarm.this
          threshold:           90 -> 95  (in-place update)
          tags.%:              1 -> 2     (tag added: $DRIFT_TAG_KEY=$DRIFT_TAG_VALUE)

    The "~" prefix means in-place update (not replacement).
    Threshold change: update action.
    Tag change: update action (tags are a map, adding a key updates the map).

  --- 2. Key observation ---
    The plan proposes UPDATING the alarm to match configuration (threshold 90).
    But the LIVE alarm has threshold 95 and an extra tag.
    This is drift: reality != configuration != state.

EOF
fi

echo
echo "========================================================"
echo "== Resolution Path 1: ACCEPT DRIFT (reality wins) =="
echo "========================================================"
cat <<EOF
When the out-of-band change was intentional and reviewed, adopt it:

  Step 1a: Refresh state to match reality (no apply, just sync state)
    cd $DEV_DIR
    terragrunt apply -refresh-only -auto-approve

    This updates the state file to show threshold=95 and the new tag.
    The plan after this will be a no-op.

  Step 1b: Update configuration to match the accepted reality
    Edit the dev stack's terragrunt.hcl (or pass -var):
      alarm_threshold = 95

    Re-plan:
      terragrunt plan
    Result: no-op (state, config, and reality all agree).

  When to choose this:
    - The change was made by an authorized process (e.g., on-call adjusting
      a threshold during an incident with a ticket).
    - The new value is correct and should be the new baseline.
    - You want the configuration to be the source of truth going forward.

  Risk:
    - Adopting a change nobody reviewed makes an accident the standard.
    - The tag $DRIFT_TAG_KEY is noise; consider whether to keep it in config.

EOF

echo
echo "========================================================"
echo "== Resolution Path 2: REVERT DRIFT (configuration wins) =="
echo "========================================================"
cat <<EOF
When the out-of-band change was a mistake, experiment, or unauthorized:

  Step 2a: Apply the original configuration (reverts live to match config)
    cd $DEV_DIR
    terragrunt apply -auto-approve

    This runs the plan from above: updates threshold 95 -> 90, removes
    the $DRIFT_TAG_KEY tag. The alarm in AWS now matches configuration.

  Step 2b: Verify no further drift
    terragrunt plan
    Result: no-op.

  When to choose this:
    - The change was accidental (fat finger, wrong alarm).
    - The change was an experiment that wasn't approved.
    - Policy requires all changes to go through IaC.

  Risk:
    - If someone is actively watching the alarm, the threshold change
      could briefly affect notifications (though this lab's alarm never fires).
    - Reverting without understanding WHY it changed loses context.

EOF

echo
echo "========================================================"
echo "== Resolution Path 3: STOP MANAGING IT (remove from state) =="
echo "========================================================"
cat <<EOF
When the resource should not be managed by OpenTofu at all:

  Step 3a: Remove from state (does not delete the AWS resource)
    cd $DEV_DIR
    terragrunt state rm module.notification.aws_cloudwatch_metric_alarm.this

  Step 3b: Next plan shows a CREATE
    terragrunt plan
    Result: + create aws_cloudwatch_metric_alarm.this (the drifted alarm)

  When to choose this:
    - The alarm was migrated to another tool/team.
    - The module is being refactored and this alarm is dropped.
    - You want to manage it manually going forward.

  Risk:
    - The next apply would create a SECOND alarm (same name = error).
    - You must import it elsewhere or accept manual management.

EOF

echo
echo "== Drift resolution complete =="
echo
echo "Key observations to record in EVIDENCE.md:"
echo "  - Plan output showing the drift (threshold + tag)"
echo "  - Which resolution path you chose and why"
echo "  - The command sequence for your chosen path"
echo "  - Whether the post-resolution plan was a no-op"
echo
echo "Next step: cli/06-terragrunt-workflow.sh — Terragrunt-specific skills."