# Labs

Hands-on procedures and evidence for the SOA-C03 study plan. Each lab links to the
service, concept, relationship, scenario, and exam domain it practices, and each one
documents its objective, exact command or configuration, target, cost, risk,
verification, and cleanup **before** execution.

Use the learner's sequence: explain → show exact CLI command → run and interpret →
learner inspects the Console → compare → recreate with OpenTofu where it applies →
clean up and verify. Never store credentials, account IDs, ARNs, or sensitive account
output in this repository.

## Available labs

| Lab | Domains | Live AWS | Est. cost/day | Purpose |
|---|---|---|---:|---|
| [01 — Disposable instance, alarm, and the OpenTofu loop](01-disposable-alarm-and-iac/README.md) | [1](../../domains/01-monitoring-logging-analysis-remediation-performance-optimization/README.md), [3](../../domains/03-deployment-provisioning-automation/README.md) | yes | < $0.50 | A disposable alarm target to replace the read-only study alarm, and the Domain 3 plan/state exercise against the same small architecture |
| [02 — Isolated network reachability, ALB health, and Flow Logs](02-network-reachability/README.md) | [5](../../domains/05-networking-content-delivery/README.md), [2](../../domains/02-reliability-business-continuity/README.md) | yes | < $0.75 | Makes the source of an HTTP 503 deterministic, so "which component produced it" becomes answerable rather than guessable |
| [03 — IAM policy evaluation and the AccessDenied trace](03-iam-policy-evaluation/README.md) | [4](../../domains/04-security-compliance/README.md) | no | $0 | The reasoning skill behind `AccessDenied`, with no infrastructure at all |
| [04 — Recovery design and verified restore](04-recovery-design-and-verified-restore/README.md) | [2](../../domains/02-reliability-business-continuity/README.md) | yes | < $1.20 | RTO/RPO measurement: snapshot restore, point-in-time recovery, cross-Region replica lag under burst load — every step proves the claim with data |
| [05 — Encryption, secrets, audit, and compliance evidence](05-data-protection-and-audit/README.md) | [4](../../domains/04-security-compliance/README.md) | yes | < $0.35 | Covers the non-IAM half of Domain 4: prove encryption in effect, compare Secrets Manager with SSM SecureString, read audit evidence, and read a Config rule's compliance state |
| [06 — IaC plan, state, and drift](06-iac-plan-state-and-drift/README.md) | [3](../../domains/03-deployment-provisioning-automation/README.md) | yes | < $0.10 | Domain 3 mechanics: read a plan, detect drift, import vs recreate, state locking, Terragrunt multi-stack — with real AWS resources |

Labs 01, 02, 04, 05, and 06 require playground or personal-account access. **Lab 03 does not**, so it
remains runnable after playground access ends on 2026-10-15.

## Rules that apply to every lab

- Confirm `aws sts get-caller-identity` before the first mutation. Use the authorized
  playground profile; never a shared or production AppTweak account.
- Show the exact command or HCL and explain target, expected change, cost, and cleanup
  before running it. Do not ask for blanket permission to run a script.
- The existing CloudWatch alarm attached to a live EC2 workload is **not** a lab
  resource. Do not edit, import, apply IaC to, or delete it.
- Every teardown script ends by querying for leftovers and printing `clean` only when
  nothing remains. Confirm the same in the Console before calling a lab finished.
- A lab that provisions successfully is not evidence of mastery. Record only what the
  learner observed, predicted, and explained.

## Cost traps to avoid

- **NAT gateway** is roughly $0.045/hour plus $0.045/GB. No lab here needs one; Lab 02
  is built specifically so that outbound internet from a private subnet is unnecessary.
- **An application load balancer** is roughly $0.0225/hour and is the dominant cost in
  Lab 02. It is the first thing Lab 02's teardown deletes.
- **EC2 detailed monitoring** is a separate per-metric charge and is not enabled in
  Lab 01.
- **EBS and S3 snapshots** persist and bill by storage after a lab is otherwise done.
- **A KMS key** cannot be deleted immediately; `schedule-key-deletion` leaves it
  pending for at least 7 days.

## Budget & account strategy

| Account | Access window | Current / forecast | Credit | Use for |
|---------|---------------|-------------------|--------|---------|
| **AppTweak Playground** | Until **2026-10-15** | ~$5 now, ~$50/mo forecast | N/A (shared) | Primary live-AWS window (Oct 5–13). Run full lab suite once. |
| **Personal account** | Until **2027-04** (credit expiry) | $100 credit | $100 | Re-runs after Oct 15, cross-Region variations, extra iterations, post-exam retention. |

**Estimated one full pass (all 5 live labs, 9 days):** ~$3/day × 9 = **~$27** on playground, well under $50 forecast.

**Per-lab daily cost ceiling** (from the table above):
- Lab 01: < $0.50
- Lab 02: < $0.75
- Lab 04: < $1.20
- Lab 05: < $0.35
- Lab 06: < $0.10

If playground spend approaches the forecast, shift remaining runs to personal account. The credit covers months of extra practice.

## Adding a lab

1. Create a directory under this folder and a `README.md` with the objective, exam
   domain and task-guide links, safety and cost table, and the full sequence.
2. Put exact commands in `cli/`, IaC in `tofu/`, and never commit state, plans, or
   variable files — the repository `.gitignore` already excludes them.
3. End with `cli/99-teardown.sh` that verifies by tag or name prefix and exits non-zero
   when anything remains.
4. Add a `EVIDENCE.md` template with the fields to record, and leave it marked *not yet
   run* until the learner actually runs it.
5. Add a row to the table above and link it from the relevant domain page.

Progress and mastery are recorded in [PROGRESS.md](../../../PROGRESS.md) and the
relevant domain page, not here. See the
[OpenTofu/AWS lab skill](../../../.agents/skills/aws-opentofu-labs/SKILL.md) and the
[tutoring skill](../../../.agents/skills/aws-cloudops-tutoring/SKILL.md).
