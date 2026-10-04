#!/usr/bin/env bash
# Lab 06, Step 3 — Plan review exercise.
#
# Runs `terragrunt plan` against both the dev and prod stacks and captures the
# output for analysis. This is a read-only operation; no resources are created or
# modified.
#
# Required environment:
#   AWS_PROFILE        authorized playground or personal-account profile
#   LAB_STATE_BUCKET   printed by cli/01
#   LAB_LOCK_TABLE     printed by cli/01
# Optional environment:
#   AWS_REGION         default us-east-1
#   RUN_LIVE           set to "1" to actually run plans; default is dry-run docs
#
# Tags any created resources with soa-c03-lab06=true (none for this step).
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

# Export variables for terragrunt
export AWS_PROFILE
export AWS_REGION
export LAB_STATE_BUCKET
export LAB_LOCK_TABLE

# Helper function to run plan for a stack
run_plan() {
  local stack_dir="$1"
  local stack_name="$2"
  local plan_file="${stack_name}.tfplan"

  echo "== ${stack_name} stack: terragrunt plan =="
  echo "  working directory: ${stack_dir}"

  if [[ "$RUN_LIVE" == "1" ]]; then
    (
      cd "$stack_dir"
      terragrunt plan -out="$plan_file" 2>&1 | tee "/tmp/${plan_file}.log"
      echo
      echo "  Plan saved to ${stack_dir}/${plan_file}"
      echo
      echo "  Summary (resource changes):"
      terragrunt show -json "$plan_file" 2>/dev/null | jq -r '
        .resource_changes[]? |
        select(.change.actions != ["no-op"]) |
        "\(.address)\t\(.change.actions | join(","))"
      ' || echo "  (no changes or jq unavailable)"
    )
  else
    cat <<EOF
  DRY RUN (set RUN_LIVE=1 to execute). The command would be:

    cd ${stack_dir}
    terragrunt plan -out=${plan_file}

  Expected output structure:
    - Resources to add (create): SNS topic, CloudWatch alarm
    - Resources to change: none (empty state vs fresh config)
    - Resources to destroy: none
    - Warnings: possibly about lock table not configured (only S3 lockfile)

  Learner exercise for ${stack_name}:
    Compare the alarm_threshold in the plan output against the CLI-created
    alarm from Step 2 (cli/02-create-cli-managed-alarm.sh).
    The CLI alarm used: NAME_PREFIX=soa-c03-lab06, threshold=80, env=study
    This ${stack_name} stack uses: name_prefix=soa-c03-lab06-tg-${stack_name}, threshold=$( [[ "$stack_name" == "dev" ]] && echo 90 || echo 70 ), env=${stack_name}

    What does the plan tell you about name collision risk?
    What does the plan tell you about threshold vs the pre-existing CLI alarm?
EOF
  fi
  echo
}

# Dev stack
run_plan "terragrunt/envs/dev" "dev"

# Prod stack
run_plan "terragrunt/envs/prod" "prod"

cat <<EOF
== Plan review complete ==

Key observations to record in EVIDENCE.md:
  - For each stack: number of resources planned to create
  - Whether any warnings appeared (e.g., missing dynamodb_table in backend)
  - The name_prefix difference between stacks and the CLI-created resources
  - Why the plan proposes "create" even though Step 2 created resources

Next step: cli/04-apply-and-import.sh — apply dev stack and demonstrate import.
EOF