# Lab 06 — IaC Plan, State, and Drift

**Exam domain:** [3. Deployment and automation](../../../domains/03-deployment-provisioning-automation/README.md) (22%)  
**Task guides:** [3.1 Provision and maintain](../../../domains/03-deployment-provisioning-automation/01-task-3-1-provision-maintain.md), [3.2 Automation and deployment failures](../../../domains/03-deployment-provisioning-automation/02-task-3-2-automation.md)  
**Status:** Not yet run

## Why this lab exists

Domain 3 is not "write Terraform." It is "read a plan, understand state, detect drift, and decide what to do about it." The exam presents scenarios — a plan output, a drifted resource, a lock contention — and asks you to choose the correct response. This lab puts you through each scenario with real AWS resources so the output is not hypothetical.

The lab uses a minimal notification stack (one SNS topic, one CloudWatch alarm) because the Domain 3 skills are about the *mechanics* of plan/state/import/drift/lock, not about infrastructure complexity. The same module is composed twice via Terragrunt (dev/prod) to exercise multi-environment state isolation.

## Objective

By the end you can:

1. Read a `terragrunt plan` and name every planned operation (create/update/replace/no-op) with the attribute-level reason.
2. Explain how OpenTofu knows what exists (state file, backend, lock) and why applying against pre-existing resources is a *decision* (import vs recreate).
3. Detect drift from a plan, distinguish in-place update from replacement, and choose between accepting drift, reverting drift, or removing from management — with justification.
4. Demonstrate Terragrunt multi-stack workflows: `run-all plan`, `run-all apply`, per-stack outputs, state listing, and lock contention.
5. Explain why the backend bucket and lock table are created *outside* OpenTofu (`disable_init = true`) and what `generate` blocks do.

## Safety, scope, and cost

| Item | Note |
|---|---|
| Scope | Authorized playground (`sso-apptweakplayground-admin`) or personal account. Never shared/production. |
| Identity | Confirm with `aws sts get-caller-identity` before first mutation; re-confirm if session fails. |
| Resources | 2 SNS topics, 2 CloudWatch alarms, 1 S3 bucket (versioned, encrypted), 1 DynamoDB table (on-demand). |
| CloudWatch/SNS | No charge. No metric data published; alarms never breach. |
| S3 bucket | A few KB of state objects. Versioning + 7-day noncurrent expiry = effectively $0. |
| DynamoDB | On-demand, handful of requests = effectively $0. |
| Expected total | Under $0.10/month. Delete when finished. |
| Blast radius | Two isolated stacks (dev/prod) in one bucket with distinct keys. All tagged `soa-c03-lab06=true`. |

Every resource carries the tag `soa-c03-lab06=true` so teardown can be verified by tag.

## Pedagogical flow: CLI first, then IaC

This lab follows a deliberate sequence that mirrors real incidents:

| Phase | Tool | Purpose |
|---|---|---|
| 0 | AWS CLI | Create backend (bucket + lock table) — infrastructure the IaC tool must not own |
| 1 | AWS CLI | Create the *target* resources (topic + alarm) out of band — simulates "someone already made this" |
| 2 | AWS CLI | Introduce drift (change threshold, add tag) — simulates "someone changed it behind your back" |
| 3 | AWS CLI | Plant a state lock — simulates "another pipeline is running" |
| 4 | Terragrunt | Plan review — what does the plan *actually* propose? |
| 5 | Terragrunt | Apply + import — how to adopt existing resources safely |
| 6 | Terragrunt | Drift resolution — three paths, pick one deliberately |
| 7 | Terragrunt | Multi-stack workflow, lock contention, force-unlock |

Do not skip ahead. Each step creates the preconditions for the next.

## Sequence

### Prerequisites

- `tofu` (OpenTofu) >= 1.7
- `terragrunt` >= 0.60
- `aws` CLI v2, `jq`
- `AWS_PROFILE` set to authorized profile

### Step 0 — Verify identity and region

```bash
aws sts get-caller-identity
aws configure get region
```

Read aloud: which account (last 4 only), which identity ARN, which region. Do not write the account ID into any file in this repository.

### Step 1 — Create the remote-state backend (CLI)

```bash
AWS_PROFILE=your-profile ./cli/01-create-state-backend.sh
```

Creates:
- S3 bucket `soa-c03-lab06-tfstate-<acct4>-<region>` (versioned, AES256, private, 7-day noncurrent expiry)
- DynamoDB table `soa-c03-lab06-tfstate-locks` (on-demand, key `LockID`)

Outputs `LAB_STATE_BUCKET`, `LAB_STATE_KEY`, `LAB_LOCK_TABLE`. Export them:

```bash
export AWS_PROFILE=your-profile
export AWS_REGION=us-east-1
export LAB_STATE_BUCKET=...
export LAB_STATE_KEY=...
export LAB_LOCK_TABLE=...
```

### Step 2 — Create the target resources out of band (CLI)

```bash
AWS_PROFILE=your-profile ./cli/02-create-cli-managed-alarm.sh
```

Creates an SNS topic `soa-c03-lab06-alarms` and CloudWatch alarm `soa-c03-lab06-cpu-synthetic` with exact attributes matching `tofu/modules/notification`. These exist in AWS *before* OpenTofu knows anything.

### Step 3 — Plan review (Terragrunt)

```bash
RUN_LIVE=1 ./cli/03-plan-review.sh
```

Runs `terragrunt plan` on both dev and prod stacks. Capture output. Key questions:
- How many resources to create per stack?
- Why does the plan propose "create" when Step 2 already made resources?
- The CLI alarm used `name_prefix=soa-c03-lab06`, threshold=80, env=study.
- Dev stack uses `name_prefix=soa-c03-lab06-tg-dev`, threshold=90, env=dev.
- Prod stack uses `name_prefix=soa-c03-lab06-tg-prod`, threshold=70, env=prod.
- What does the name difference tell you about collision risk?

### Step 4 — Apply and import (Terragrunt)

```bash
RUN_LIVE=1 ./cli/04-apply-and-import.sh
```

For dev stack:
1. `terragrunt apply -auto-approve` — creates NEW resources (different names from Step 2).
2. Verify outputs match the created resources.
3. **Import exercise**: The Step 2 resources have DIFFERENT names, so import would target different AWS objects. This demonstrates the isolation strategy. If names matched, the workflow would be:
   - `terragrunt apply` → fails "already exists"
   - `terragrunt import module.notification.aws_sns_topic.this <topic-name>`
   - `terragrunt import module.notification.aws_cloudwatch_metric_alarm.this <alarm-name>`
   - `terragrunt plan` → expect no-op
4. Repeat for prod stack.

Key lesson: Import succeeds when names match; recreate fails with "already exists" errors.

### Step 5 — Drift detection and resolution (Terragrunt)

First, ensure the dev stack manages an alarm that has drift. Either:
- Run Step 2 with `NAME_PREFIX=soa-c03-lab06-tg-dev`, then import it in Step 4, then run Step 3 (drift) with same prefix.
- Or run this step conceptually.

```bash
RUN_LIVE=1 ./cli/05-drift-resolution.sh
```

Runs `terragrunt plan` on dev — shows drift (threshold 90→95, extra tag).
Demonstrates three resolution paths:
1. **Accept drift**: `terragrunt apply -refresh-only` (sync state to reality), update config threshold to 95, re-plan → no-op.
2. **Revert drift**: `terragrunt apply` with original config → reverts alarm to threshold 90, removes extra tag.
3. **Stop managing**: `terragrunt state rm ...` → next plan shows create.

Choose ONE deliberately and justify it in EVIDENCE.md.

### Step 6 — Terragrunt-specific skills (Terragrunt)

```bash
RUN_LIVE=1 ./cli/06-terragrunt-workflow.sh
```

Demonstrates:
- `terragrunt run-all plan` / `run-all apply` — both stacks in one command
- `terragrunt output` / `run-all output` — outputs from all stacks
- `terragrunt state list` — resources in each stack's state
- **Lock contention**: Terminal 1 runs `terragrunt apply`; Terminal 2 runs `cli/04-hold-state-lock.sh` then `terragrunt plan -lock-timeout=0s` → shows contention error
- `terragrunt force-unlock` — release planted lock (with caution)
- Why `disable_init = true` in `root.hcl` matters (lab owns backend, not Terragrunt)

### Step 7 — Tear down and verify

```bash
# First, destroy IaC-managed resources
cd terragrunt/envs/dev && terragrunt destroy -auto-approve
cd terragrunt/envs/prod && terragrunt destroy -auto-approve
cd ../../tofu && tofu destroy -auto-approve  # if you used root tofu dir

# Then remove backend (asks for confirmation)
LAB06_DESTROY_STATE=yes ./cli/99-teardown.sh
```

The script verifies: no alarms, no topics, no bucket, no lock table. Must print `clean`.

## Key Terragrunt concepts exercised

### `disable_init = true` in `root.hcl`

```hcl
remote_state {
  backend     = "s3"
  disable_init = true
  ...
}
```

Without it, Terragrunt would create the S3 bucket and DynamoDB table on first `init`. This lab creates them explicitly via CLI so:
- Every setting is visible (versioning, encryption, lifecycle, tags, billing mode).
- Teardown knows exactly what to clean up.
- The backend is treated as *infrastructure* managed by a separate process — production pattern.

### `generate` blocks

```hcl
generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    terraform { backend "s3" {} }
  EOF
}
```

Writes a minimal backend block into each stack's working directory before OpenTofu runs. The module itself has NO backend block (correct: reusable modules don't decide where state lives). The `generate` block is the single place to change backend type/config.

```hcl
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    provider "aws" { region = "us-east-1" }
  EOF
}
```

Same for provider: one definition in root, generated into every stack.

### `run-all`

`terragrunt run-all plan` finds all child stacks (directories with `terragrunt.hcl` including the root) and runs the command in each. Output is prefixed with the stack path. This is the multi-environment equivalent of `tofu plan` in a single directory.

### State locking

Two mechanisms, both demonstrated:
- **S3 lockfile** (`use_lockfile = true`): Conditional write (`If-None-Match: *`) on `<key>.tflock`. Preferred by OpenTofu.
- **DynamoDB** (`dynamodb_table = ...`): Conditional `PutItem` on `LockID`. Legacy but still used.

`cli/04-hold-state-lock.sh` plants a lock via either mechanism. `terragrunt plan -lock-timeout=0s` fails immediately rather than waiting. `force-unlock` releases a stuck lock (crash recovery only).

### `root.hcl` rename rationale

The root config is `root.hcl`, not `terragrunt.hcl`, because Terragrunt's default parent search finds `terragrunt.hcl`. If both root and stack used that name, the stack would include itself. Explicit `find_in_parent_folders("root.hcl")` makes the relationship unambiguous.

## Step reference table

| Step | Script | Purpose | Target | Cost | Risk | Verification | Cleanup |
|---|---|---|---|---|---|---|---|
| 0 | `cli/01-create-state-backend.sh` | Create S3 bucket + DynamoDB lock table | Backend infra | ~$0 | Low | Bucket exists, versioned, encrypted; table ACTIVE | `cli/99-teardown.sh` (with `LAB06_DESTROY_STATE=yes`) |
| 1 | `cli/02-create-cli-managed-alarm.sh` | Create SNS topic + CloudWatch alarm out of band | `soa-c03-lab06-alarms`, `soa-c03-lab06-cpu-synthetic` | $0 | Low | `aws cloudwatch describe-alarms`, `aws sns get-topic-attributes` | `cli/99-teardown.sh` |
| 2 | `cli/03-introduce-drift.sh` | Modify alarm threshold + add tag out of band | Same alarm | $0 | Low | Threshold=95, tag `soa-c03-drifted=yes` in AWS | Reverted by Step 5 or `cli/99-teardown.sh` |
| 3 | `cli/04-hold-state-lock.sh` | Plant state lock (S3 and/or DynamoDB) | State lock | $0 | Low | Lock object/item exists | `tofu force-unlock` or `cli/99-teardown.sh` |
| 4 | `cli/03-plan-review.sh` | Plan review for dev + prod stacks | Read-only | $0 | None | Plan output captured | N/A |
| 5 | `cli/04-apply-and-import.sh` | Apply dev/prod; demonstrate import vs recreate | Dev/prod stacks | $0 | Medium (creates resources) | Outputs match; state list shows 2 resources/stack | `terragrunt destroy` per stack |
| 6 | `cli/05-drift-resolution.sh` | Detect drift; show 3 resolution paths | Dev stack alarm | $0 | Low (read + optional apply) | Plan shows drift; post-resolution no-op | Included in stack destroy |
| 7 | `cli/06-terragrunt-workflow.sh` | run-all, output, state list, lock demo, force-unlock | Both stacks | $0 | Low | Commands execute; lock error shown | N/A |
| 8 | `cli/99-teardown.sh` | Delete all lab resources, verify clean | Everything | $0 | High (destroys state) | Prints `clean` | N/A |

## Evidence to record

Copy into [EVIDENCE.md](EVIDENCE.md) after the run. Redact account IDs to last four characters; never record ARNs, keys, or session tokens.

- Step 3: Plan summary for dev and prod; your explanation of each operation.
- Step 4: Apply output; import commands you would run (or did run); why import vs recreate.
- Step 5: Drift plan output; which resolution path you chose and why; post-resolution plan.
- Step 6: `run-all` output summary; lock contention error message; `force-unlock` command if used.
- Teardown: Final verification block showing `clean`.
- Surprises: Anything unexpected — those are study items.

## Cleanup risk if interrupted

If the run stops midway:

1. Run `terragrunt destroy` in each stack directory that was applied.
2. Run `tofu destroy` in `tofu/` if you initialized it.
3. Run `LAB06_DESTROY_STATE=yes ./cli/99-teardown.sh` to remove backend.
4. Verify in Console: no alarms/topics tagged `soa-c03-lab06`, no bucket, no lock table.

The tag query is the recovery path:

```bash
aws cloudwatch describe-alarms --alarm-name-prefix soa-c03-lab06 \
  --query 'MetricAlarms[].AlarmName' --output text
aws sns list-topics --query "Topics[?contains(TopicArn, 'soa-c03-lab06')].TopicArn" --output text
aws s3api list-object-versions --bucket <bucket> --prefix soa-c03-lab06/ --output json
aws dynamodb describe-table --table-name soa-c03-lab06-tfstate-locks
```

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| `terragrunt plan` fails with backend error | `LAB_STATE_BUCKET` not exported | Export all three vars from Step 1 output |
| `terragrunt apply` fails "already exists" | Step 2 resources have same name as stack | Use import workflow (Step 4) or different `name_prefix` |
| Plan shows drift on tags after import | CLI tags != config tags | Ensure `tags = { soa-c03-lab06 = "true" }` in config |
| Lock contention error on first run | Previous crashed run left lock | `tofu force-unlock <LOCK_ID>` from error message |
| `run-all` only runs one stack | Stack `terragrunt.hcl` doesn't include root | Check `include "root" { path = find_in_parent_folders("root.hcl") }` |

## Files in this lab

```
06-iac-plan-state-and-drift/
├── cli/
│   ├── 01-create-state-backend.sh
│   ├── 02-create-cli-managed-alarm.sh
│   ├── 03-introduce-drift.sh
│   ├── 04-hold-state-lock.sh
│   ├── 03-plan-review.sh           # NEW
│   ├── 04-apply-and-import.sh      # NEW
│   ├── 05-drift-resolution.sh      # NEW
│   ├── 06-terragrunt-workflow.sh   # NEW
│   └── 99-teardown.sh
├── tofu/
│   ├── main.tf
│   ├── modules/notification/main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── versions.tf
│   └── terraform.tfvars.example
├── terragrunt/
│   ├── root.hcl
│   └── envs/
│       ├── dev/terragrunt.hcl
│       └── prod/terragrunt.hcl
├── README.md
└── EVIDENCE.md
```

## Next steps

After this lab, you have exercised every Domain 3 plan/state/drift/lock skill with real AWS resources. The next labs apply these mechanics to larger architectures (ASG, networking, IAM). Keep the mental model: **plan → decide → act → verify**, never "apply and hope."