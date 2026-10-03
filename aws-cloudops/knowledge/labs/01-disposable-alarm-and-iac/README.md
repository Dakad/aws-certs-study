# Lab 01 — Disposable instance, CloudWatch alarm, and the OpenTofu loop

**Exam domains:** [1. Monitoring](../../domains/01-monitoring-logging-analysis-remediation-performance-optimization/README.md) (22%) and [3. Deployment and automation](../../domains/03-deployment-provisioning-automation/README.md) (22%)
**Task guides:** [1.1 Monitoring and logging](../../domains/01-monitoring-logging-analysis-remediation-performance-optimization/01-task-1-1-monitoring-logging.md), [1.2 Remediation](../../domains/01-monitoring-logging-analysis-remediation-performance-optimization/02-task-1-2-remediation.md), [3.1 Provision and maintain](../../domains/03-deployment-provisioning-automation/01-task-3-1-provision-maintain.md)
**Status:** Not yet run

## Why this lab exists

The existing workload alarm `codex-study-cpu-high-ec2-lab` is attached to a real EC2 instance and must stay read-only — see the [Domain 1 notes](../../domains/01-monitoring-logging-analysis-remediation-performance-optimization/README.md). Without a disposable instance there is nowhere to practise alarm changes, missing-data treatment, or an IaC apply, because every AWS-native tool mutates.

This lab creates one disposable instance and one alarm configured to mirror the existing alarm's shape, so the two can be compared directly. The same architecture is then recreated in OpenTofu, which makes it the Domain 3 exercise as well. Doing both against one small design is deliberate: the Domain 3 objective is about reading a plan and understanding state, not about IaC volume.

## Objective

By the end you can:

1. Explain what each alarm field establishes and what it cannot.
2. Reproduce the existing alarm's settings on a disposable target and change one field deliberately, predicting the state before the change lands.
3. Read an OpenTofu `plan`, name every planned operation, and state whether each is create/update/replace/no-op.
4. Explain how OpenTofu knows what already exists, and why applying this configuration against a CLI-created instance is a decision rather than a convenience.

## Safety, scope, and cost

| Item | Note |
|---|---|
| Scope | The authorized playground (`sso-apptweakplayground-admin`) or a personal account. Never a shared or production AppTweak account. |
| Identity | Confirm with `aws sts get-caller-identity` before the first mutation and re-confirm if the session fails mid-lab. |
| Instance | `t4g.micro`, Linux. On-demand in us-east-1 is roughly $0.0116/hour, so under $0.30/day. |
| Storage | `gp3`, 1 GiB, deleted with the instance. |
| CloudWatch alarm | No charge. Detailed monitoring is **not** enabled — it is a separate per-metric charge. |
| SNS topic | No charge. Notification delivery to email is free. |
| Expected total | Under $0.50 per day. Delete the instance when finished; do not leave it running overnight. |
| Blast radius | One instance, one alarm, one topic, all tagged `soa-c03-lab01`. Nothing shared. |

Every resource carries the tag `soa-c03-lab01=true` so teardown can be verified by tag rather than by remembering an ID.

## Sequence

The learner's sequence is CLI → Console → OpenTofu → compare → clean up. Do not skip ahead.

### Step 0 — Verify identity and region

```bash
aws sts get-caller-identity
aws configure get region
```

Read the output aloud: which account, which identity ARN, which region. Everything downstream uses that region. Do not write the account ID into any file in this repository.

### Step 1 — Create with the CLI

```bash
AWS_PROFILE=sso-apptweakplayground-admin ./cli/01-create.sh
```

Before running it, read it. It resolves the current Amazon Linux 2023 AMI through the SSM public parameter rather than hardcoding an AMI ID, so it does not silently rot. It creates the SSM instance role, the instance, the SNS topic, and the alarm.

Two things in this step are teaching material, not plumbing:

- The instance profile exists so you reach the box with SSM Session Manager and **no inbound security-group rule and no SSH key**. Session Manager over SSM is the AWS-native answer to "I need shell access without opening a port."
- The alarm is created with `treat_missing_data = notBreaching`, deliberately matching the existing alarm so the comparison is like-for-like. Change exactly one field at a time and predict the resulting state *before* you apply.

### Step 2 — Inspect in the Console

The learner navigates: EC2 instance → monitoring tab → CloudWatch alarm → alarm History → alarm graph → SNS topic. Screenshots may be shared for interpretation.

Record what the Console confirms and what it leaves ambiguous. "No actions" on the Details view is an action-configuration label; it is not the alarm's state reason — a point already established on the existing alarm.

### Step 3 — Recreate in OpenTofu

```bash
cd tofu
export AWS_PROFILE=sso-apptweakplayground-admin
tofu init
tofu plan -out=tfplan
```

Then **stop and read the plan before applying anything.** For each planned operation, be able to say: create, update, replace, or no-op, and why. `-out=tfplan` writes a plan file; it is gitignored and must never be committed.

Do not run `tofu apply` against resources the CLI already created. Pick one of these deliberately:

- **Recreate (recommended for learning).** `tofu destroy` the CLI resources, confirm with the Console that they are gone, then `tofu apply`. You learn that OpenTofu creates from scratch when state is empty. Cost is negligible; the lesson is clean.
- **Import.** `tofu import` each resource into state and then run `tofu plan` expecting no-op. You learn that state is OpenTofu's record of what it manages, and that an imported resource can drift from your configuration. Cost is zero but the lesson is harder to see.

Whichever you choose, say why before running it. Never let a tool build a second copy of something that already exists.

### Step 4 — Compare

Line up four views of the same architecture: the CLI output, the Console, the `tofu plan`, and the `tofu state list`. Where do they agree, and where does one of them show something the others cannot?

### Step 5 — Tear down and verify

```bash
./cli/99-teardown.sh
```

The script must end by querying for anything still tagged `soa-c03-lab01` and printing `clean` only when that query returns nothing. Verify the same query yourself in the Console before calling the lab finished.

## Evidence to record

Copy into [EVIDENCE.md](EVIDENCE.md) after the run. Redact account IDs to the last four characters; never record ARNs, keys, or session tokens.

- Chosen path from Step 3 (recreate or import) and the reasoning.
- The `tofu plan` summary line and your explanation of each operation.
- The alarm state you predicted, and what actually happened.
- One field you changed deliberately and the alarm behaviour difference it caused.
- Teardown output showing the tag query returned nothing.
- Anything that surprised you — those are the study items.

## Cleanup risk if interrupted

If the run stops midway, the tag query is the recovery path:

```bash
aws ec2 describe-instances \
  --filters "Name=tag:soa-c03-lab01,Values=true" \
  --query 'Reservations[].Instances[].{Id:InstanceId,State:State.Name}' --output table
```

Deleting the instance removes its EBS volumes and non-preserved root devices. Delete the SNS topic by hand if the script did not reach it.
