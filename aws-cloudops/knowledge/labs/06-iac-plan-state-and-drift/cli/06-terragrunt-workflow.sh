#!/usr/bin/env bash
# Lab 06, Step 6 — Terragrunt-specific skills.
#
# Demonstrates:
#   - terragrunt run-all plan / apply
#   - terragrunt output (all stacks)
#   - terragrunt state list (per stack)
#   - State locking contention demo (with cli/04-hold-state-lock.sh)
#   - terragrunt force-unlock
#   - Why disable_init = true matters
#
# Required environment:
#   AWS_PROFILE        authorized playground or personal-account profile
#   LAB_STATE_BUCKET   printed by cli/01
#   LAB_LOCK_TABLE     printed by cli/01
# Optional environment:
#   AWS_REGION         default us-east-1
#   RUN_LIVE           set to "1" to actually run commands; default is dry-run docs
#
# Tags: none created.
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

TERRAGRUNT_ROOT="terragrunt"

echo "========================================================"
echo "== 1. terragrunt run-all plan ==="
echo "========================================================"
cat <<EOF
Runs plan for ALL stacks that include the root config (dev + prod).
This is the primary multi-environment workflow command.

Command:
  cd $TERRAGRUNT_ROOT
  terragrunt run-all plan

What happens:
  - Finds all terragrunt.hcl files under envs/ that include root.hcl
  - Runs 'terragrunt plan' in each stack's working directory
  - Aggregates output with stack prefixes

Expected output:
  dev:  Plan: 2 to add, 0 to change, 0 to destroy.
  prod: Plan: 2 to add, 0 to change, 0 to destroy.

  (Assuming neither stack has been applied yet. After apply, both show no-op.)

EOF

if [[ "$RUN_LIVE" == "1" ]]; then
  (
    cd "$TERRAGRUNT_ROOT"
    terragrunt run-all plan 2>&1 | tee /tmp/run-all-plan.log
  )
fi

echo
echo "========================================================"
echo "== 2. terragrunt run-all apply ==="
echo "========================================================"
cat <<EOF
Applies ALL stacks in one command. Use with -auto-approve for lab speed.

Command:
  cd $TERRAGRUNT_ROOT
  terragrunt run-all apply -auto-approve

What happens:
  - Runs apply in each stack sequentially (not parallel)
  - Each stack acquires its own state lock
  - Stops on first failure (unless you use --terragrunt-ignore-external-dependencies)

Note: For production, prefer run-all plan, review each, then run-all apply
WITHOUT -auto-approve, so you confirm each stack.

EOF

if [[ "$RUN_LIVE" == "1" ]]; then
  (
    cd "$TERRAGRUNT_ROOT"
    terragrunt run-all apply -auto-approve 2>&1 | tee /tmp/run-all-apply.log
  )
fi

echo
echo "========================================================"
echo "== 3. terragrunt output (all stacks) ==="
echo "========================================================"
cat <<EOF
Shows outputs from all stacks. Must run from each stack's directory
or use run-all with an output command.

Commands:
  cd $TERRAGRUNT_ROOT/envs/dev
  terragrunt output

  cd $TERRAGRUNT_ROOT/envs/prod
  terragrunt output

  # Or combined:
  cd $TERRAGRUNT_ROOT
  terragrunt run-all output

Expected outputs per stack:
  alarm_arn     = "arn:aws:cloudwatch:...:alarm:soa-c03-lab06-tg-<env>-cpu-synthetic"
  alarm_name    = "soa-c03-lab06-tg-<env>-cpu-synthetic"
  alarm_threshold = <90 for dev, 70 for prod>
  topic_arn     = "arn:aws:sns:...:soa-c03-lab06-tg-<env>-alarms"

EOF

if [[ "$RUN_LIVE" == "1" ]]; then
  (
    cd "$TERRAGRUNT_ROOT"
    terragrunt run-all output 2>&1 | tee /tmp/run-all-output.log
  )
fi

echo
echo "========================================================"
echo "== 4. terragrunt state list (per stack) ==="
echo "========================================================"
cat <<EOF
Lists resources in each stack's state file. Run from each stack dir.

Commands:
  cd $TERRAGRUNT_ROOT/envs/dev
  terragrunt state list

  cd $TERRAGRUNT_ROOT/envs/prod
  terragrunt state list

Expected (after apply):
  module.notification.aws_cloudwatch_metric_alarm.this
  module.notification.aws_sns_topic.this

Compare against tofu/outputs.tf expected_state_addresses.

EOF

if [[ "$RUN_LIVE" == "1" ]]; then
  for env in dev prod; do
    echo "--- $env stack ---"
    (
      cd "$TERRAGRUNT_ROOT/envs/$env"
      terragrunt state list 2>&1 | tee "/tmp/state-list-$env.log"
    )
    echo
  done
fi

echo
echo "========================================================"
echo "== 5. State locking contention demo ==="
echo "========================================================"
cat <<EOF
This demonstrates what happens when two processes try to hold the state lock.

TERMINAL 1 (run this and leave it waiting):
  cd $TERRAGRUNT_ROOT/envs/dev
  terragrunt apply -auto-approve
  # This acquires the lock and holds it during the apply

TERMINAL 2 (run while Terminal 1 is applying):
  # Plant a competing lock (S3 lockfile mode)
  LAB_LOCK_MODE=s3 ./cli/04-hold-state-lock.sh

  # Then try to plan (will fail immediately with -lock-timeout=0s)
  cd $TERRAGRUNT_ROOT/envs/dev
  terragrunt plan -lock-timeout=0s

Expected error from Terminal 2:
  Error acquiring the state lock
  ConditionalCheckFailedException: Lock ID: <planted-lock-id>
  
  OR (if using DynamoDB lock):
  Error acquiring the state lock
  ConditionalCheckFailedException: LockID already exists

This is the CORRECT behavior: the backend refuses to proceed because it
cannot prove exclusive access. The lock protects against concurrent writes
corrupting the state file.

EOF

if [[ "$RUN_LIVE" == "1" ]]; then
  cat <<EOF
  NOTE: For the live demo, you need TWO terminals.
  This script cannot simulate both simultaneously.
  Run the commands above in two separate terminals.
EOF
fi

echo
echo "========================================================"
echo "== 6. terragrunt force-unlock ==="
echo "========================================================"
cat <<EOF
Releases a stuck lock. USE WITH EXTREME CAUTION.

Command:
  cd $TERRAGRUNT_ROOT/envs/dev
  terragrunt force-unlock -force <LOCK_ID>

Where <LOCK_ID> is the ID shown in the contention error (planted by cli/04).

When to use:
  - A previous run CRASHED while holding the lock (process died, network
    partition, power loss). The lock was never released.
  - You have CONFIRMED no other process is currently writing to this state.

When NOT to use:
  - Another terminal/session is actively running apply/plan.
  - You are trying to "steal" a lock from a colleague's live run.
  - You don't know why the lock exists.

The -force flag acknowledges you understand the risk: two writers = corrupted
state = unrecoverable infrastructure drift.

Alternative for S3 lockfile: delete the .tflock object directly:
  aws s3api delete-object --bucket \$LAB_STATE_BUCKET --key <state-key>.tflock

Alternative for DynamoDB: delete the lock item:
  aws dynamodb delete-item --table-name \$LAB_LOCK_TABLE --key '{"LockID":{"S":"<bucket>/<key>"}}'

EOF

echo
echo "========================================================"
echo "== 7. Why disable_init = true in root.hcl matters ==="
echo "========================================================"
cat <<EOF
In terragrunt/root.hcl:

  remote_state {
    backend     = "s3"
    disable_init = true
    ...
  }

Without disable_init = true:
  - Terragrunt would try to CREATE the S3 bucket and DynamoDB table
    if they don't exist during 'terragrunt init'.
  - This lab creates them explicitly with cli/01 so the learner sees
    every setting (versioning, encryption, lifecycle, tags, billing mode).
  - If Terragrunt also created them, teardown (cli/99) wouldn't know
    which resources it owns vs. Terragrunt owns.
  - The lab's pedagogical point: the backend is INFRASTRUCTURE, not
    something your IaC tool should implicitly provision.

With disable_init = true:
  - Terragrunt assumes the backend exists and is configured correctly.
  - cli/01 is the single source of truth for backend creation.
  - The generate blocks still write backend.tf and provider.tf so
    OpenTofu knows how to connect.

This mirrors production practice: the state backend is managed by a
separate, more privileged pipeline (or manually), not by every stack.

EOF

echo
echo "========================================================"
echo "== 8. root.hcl vs terragrunt.hcl naming ==="
echo "========================================================"
cat <<EOF
The root config is named root.hcl (not terragrunt.hcl) because:

  - Terragrunt's default search looks for terragrunt.hcl in parent
    directories. If the root AND the stack were both named
    terragrunt.hcl, the stack would include itself.
  - Explicit naming (root.hcl) + find_in_parent_folders("root.hcl")
    in the stack makes the relationship unambiguous.
  - This is a documented Terragrunt best practice for multi-stack
    configurations.

EOF

echo
echo "== Terragrunt workflow complete =="
echo
echo "Key observations to record in EVIDENCE.md:"
echo "  - run-all plan/apply output summary"
echo "  - Output values from both stacks (redacted)"
echo "  - State list comparison with expected_state_addresses"
echo "  - Lock contention error message (from Terminal 2)"
echo "  - force-unlock command used (if needed)"
echo "  - Why disable_init = true is a deliberate choice"
echo
echo "Lab 06 complete. Run cli/99-teardown.sh to clean up."