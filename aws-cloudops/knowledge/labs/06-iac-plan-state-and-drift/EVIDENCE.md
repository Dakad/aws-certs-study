# Lab 06 evidence — not yet run

Status: **not yet run**. Replace this line as evidence is recorded.

Redact account IDs to the last four characters. Never record ARNs, access keys,
session tokens, or resource IDs that you would not want published.

## Session

- Date:
- AWS profile used:
- Region:
- Account ID (last 4 only): `....`

## Step 3 — Plan review (cli/03-plan-review.sh)

### Dev stack plan summary

`terragrunt plan` summary line:

| Resource | Planned operation | Why |
|---|---|---|
|  |  |  |
|  |  |  |

What the plan tells you about the CLI-created alarm (threshold=80, name=soa-c03-lab06-cpu-synthetic) vs the dev stack (threshold=90, name=soa-c03-lab06-tg-dev-cpu-synthetic):

### Prod stack plan summary

`terragrunt plan` summary line:

| Resource | Planned operation | Why |
|---|---|---|
|  |  |  |
|  |  |  |

Warnings (if any):

## Step 4 — Apply and import (cli/04-apply-and-import.sh)

### Dev stack apply

Resources created:

Outputs (redacted):

`terragrunt state list`:

### Import exercise

The CLI-created resources (Step 2) have different names from the dev stack, so import would target different AWS resources. This is the isolation strategy.

If names matched, the import commands would be:

```bash
terragrunt import module.notification.aws_sns_topic.this <topic-name>
terragrunt import module.notification.aws_cloudwatch_metric_alarm.this <alarm-name>
```

Post-import `terragrunt plan` result (expected no-op):

Import vs recreate comparison:

| Aspect | Import | Recreate (apply without import) |
|---|---|---|
| Outcome |  |  |
| Downtime |  |  |
| ARN stability |  |  |
| When to choose |  |  |

### Prod stack apply

Resources created:

Outputs (redacted):

`terragrunt state list`:

## Step 5 — Drift resolution (cli/05-drift-resolution.sh)

### Drift detection

`terragrunt plan` output showing drift:

| Resource | Action | Attribute | Before (config/state) | After (live) |
|---|---|---|---|---|
|  |  |  |  |  |
|  |  |  |  |  |

### Resolution path chosen

- [ ] **Path 1: Accept drift** (reality wins)
  - `terragrunt apply -refresh-only`
  - Update config threshold to 95
  - Re-plan → no-op

- [ ] **Path 2: Revert drift** (configuration wins)
  - `terragrunt apply` with original config
  - Re-plan → no-op

- [ ] **Path 3: Stop managing**
  - `terragrunt state rm module.notification.aws_cloudwatch_metric_alarm.this`
  - Re-plan → shows create

Reasoning, written **before** running the chosen path:

Commands executed:

Post-resolution `terragrunt plan` result:

## Step 6 — Terragrunt workflow (cli/06-terragrunt-workflow.sh)

### run-all plan

Summary:

### run-all apply

Summary:

### Outputs (both stacks)

Dev:
- alarm_name:
- alarm_threshold:
- topic_arn (redacted):

Prod:
- alarm_name:
- alarm_threshold:
- topic_arn (redacted):

### State list (both stacks)

Dev:
```
```

Prod:
```
```

Match `tofu/outputs.tf` expected_state_addresses? [ ] Yes [ ] No

### Lock contention demo

Terminal 1 command (held lock):

Terminal 2 commands:

Error message from Terminal 2:

Lock ID shown in error:

### force-unlock

Command used (if needed):

Why it was safe to force-unlock in this case:

### disable_init = true

Why this matters for this lab (in your words):

## Teardown

Paste the final verification block from `cli/99-teardown.sh`. It must print `clean`.

## Surprises

Anything unexpected is a study item. Write it here and raise it in the next session.