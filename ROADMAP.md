# AWS CloudOps Engineer Associate roadmap

**Exam target:** AWS Certified CloudOps Engineer – Associate (SOA-C03), October 31, 2026  
**Study window:** September 28–October 30, 2026  
**AWS access:** AppTweak playground access ends October 15, 2026. A personal AWS account is available as an optional lab environment afterward. Do not assume a lab will run there; first confirm a secure authentication method, exact scope, cost, and cleanup.

This file holds the exam plan: scope, schedule, constraints, and intended evidence. Record completed work, learner strengths, corrections, and current status in [PROGRESS.md](PROGRESS.md); use the [domain task guides](aws-cloudops/domains/README.md) for structured practice and the original domain notes for learner-specific study records.

## Exam coverage

Weights below are from the AWS SOA-C03 exam guide. All five domains receive planned study time. Networking/investigation gets modest additional targeted practice because it is a stated weaker area, not at the expense of the other domains.

| Exam domain | Weight | Planned coverage |
|---|---:|---|
| [1. Monitoring, Logging, Analysis, Remediation, and Performance Optimization](aws-cloudops/domains/01-monitoring-logging-analysis-remediation-performance-optimization/README.md) | 22% | Metrics, alarms, logs/events, investigation, remediation, and performance optimization. |
| [2. Reliability and Business Continuity](aws-cloudops/domains/02-reliability-business-continuity/README.md) | 22% | Scaling, high availability, backups, restore/DR, RTO/RPO, and failure handling. |
| [3. Deployment, Provisioning, and Automation](aws-cloudops/domains/03-deployment-provisioning-automation/README.md) | 22% | Provisioning, change automation, deployment strategies, and infrastructure as code. |
| [4. Security and Compliance](aws-cloudops/domains/04-security-compliance/README.md) | 16% | IAM/security controls, data protection, audit/configuration, and compliance scenarios. |
| [5. Networking and Content Delivery](aws-cloudops/domains/05-networking-content-delivery/README.md) | 18% | Network paths, DNS/content delivery, connectivity investigation, and network cost. |

## Scheduling constraints

These are calendar facts, not judgement calls. They drive the phase windows below and override any earlier allocation.

1. **Phase 0 was not completed on Sep 30.** The mixed-domain diagnostic is the only input that lets the schedule be corrected by evidence rather than assumption, so it moves to **Oct 3** and becomes the first task of the remaining window. Rebalancing before the diagnostic exists is guesswork.
2. **Playground access ends Oct 15.** Three phases need live AWS: Phase 1 and Phase 3 share [Lab 01](aws-cloudops/knowledge/labs/01-disposable-alarm-and-iac/README.md), and Phase 4 runs [Lab 02](aws-cloudops/knowledge/labs/02-network-reachability/README.md). All of them must complete **before Oct 15**. Phase 5 needs none — [Lab 03](aws-cloudops/knowledge/labs/03-iam-policy-evaluation/README.md) is IAM-only and stays runnable afterwards. A personal account is not a substitute for the playground unless its access method, scope, cost, and cleanup are confirmed first.
3. **Every live-AWS phase needs slack, not just a slot.** Scheduling a lab on Oct 14 leaves no recovery day if it overruns. Phases 1, 3, and 4 therefore finish by Oct 13, and Oct 14–15 are slack plus teardown verification.
4. **Two domains must not share one window.** The earlier Oct 11–14 pairing of Domain 5 and Domain 4 put 34% of the exam weight plus two labs into four days ending at the sandbox cutoff. Every phase now has a distinct window.
5. **Phase 1 precedes Phase 3.** Phase 3 reuses Phase 1's observe → configure → verify pattern, and both run against the same Lab 01 resources, which must exist before the OpenTofu comparison can replace them. Reversing the two would invert that dependency.
6. **Domain 4 (16%) started last and was still `null` on Oct 3** while Domain 1 alarm evaluation consumed three sessions. Domain 4 needs no sandbox, so it opens the post-diagnostic window as the cheapest available coverage.
7. **Practice-question volume must be scheduled, not assumed.** Phase 6 previously required "at least two timed mixed sets" with no question count or dates. It now carries explicit dates and a per-domain target.

## Phase summary

Rows are ordered by window, not by phase number; phase numbers stay stable so the evidence in [PROGRESS.md](PROGRESS.md) remains traceable.

| Phase | Focus / domain | Depends on | Window | Exit gate (summary) | Status |
|---|---|---|---|---|---|
| 0 | Foundation and baseline — all domains | — | Oct 3 | Objectives, lab guardrails, identity/region habits, and diagnostic baseline recorded. | ☑ done |
| 5 | Security and compliance — [Domain 4](aws-cloudops/domains/04-security-compliance/README.md) | 0 | Oct 4; reinforce Oct 22–25 | Explain an effective access decision, least-privilege correction, and verification. | ☐ pending |
| 1 | Monitoring and investigation — [Domain 1](aws-cloudops/domains/01-monitoring-logging-analysis-remediation-performance-optimization/README.md) | 0 | Oct 5–6, live AWS; reinforce Oct 16–18 | Independently explain an alarm evaluation and diagnose a fresh symptom from evidence. | ☐ pending |
| 3 | Deployment and automation — [Domain 3](aws-cloudops/domains/03-deployment-provisioning-automation/README.md) | 0; Phase 1 pattern is useful | Oct 7–8, live AWS | Complete a scoped CLI → Console → OpenTofu loop and explain plan, state, and cleanup. | ☐ pending |
| 2 | Reliability and recovery — [Domain 2](aws-cloudops/domains/02-reliability-business-continuity/README.md) | 0 | Oct 9–10; reinforce Oct 16–18 | Choose a recovery design for explicit RTO/RPO needs and explain restore verification. | ☐ pending |
| 4 | Networking and content delivery — [Domain 5](aws-cloudops/domains/05-networking-content-delivery/README.md) | 0; Phase 1 evidence skills | Oct 11–13, live AWS | Trace a fresh connectivity incident and complete a safe isolated network exercise. | ☐ pending |
| 6 | Cross-domain review and exam readiness — all domains | 1–5 studied | Oct 16–30 | Record and review at least two timed mixed sets, then assess readiness from the evidence. | ☐ null |

**Oct 14–15 — slack and sandbox wind-down.** Phases 1, 3, and 4 finish by Oct 13 so that two days remain for overruns. Use Oct 14 for overrun and Oct 15 to verify every resource from [Lab 01](aws-cloudops/knowledge/labs/01-disposable-alarm-and-iac/README.md) and [Lab 02](aws-cloudops/knowledge/labs/02-network-reachability/README.md) is deleted, confirm cost has stopped accruing, and record the teardown evidence in [PROGRESS.md](PROGRESS.md). Any unused time carries into Phase 6.

Status key: `☐ pending` = started, exit gate not met; `☐ null` = not started; `☑ done` = exit gate met and evidence recorded. This overview mirrors the detailed evidence in [PROGRESS.md](PROGRESS.md); update the status only from that evidence.

## Phases and completion criteria

The phases provide a sequence and clear exit evidence. Dependencies identify learning prerequisites, not a requirement to finish every subtopic before previewing another domain. Phases 1 and 3 share one lab and one set of AWS resources, so they run back to back; the networking and security reinforcement blocks overlap later by design. The status column above mirrors the phase state recorded in [PROGRESS.md](PROGRESS.md), which holds the detailed evidence.

### Phase 0 — Foundation and baseline

- **Window:** Oct 3 (slipped from Sep 28–30; this is the first task of the remaining window)
- **Scope:** Read the exam guide; map all five domains; confirm account/profile and region habits; set lab cost, scope, and cleanup guardrails; take a mixed-domain diagnostic.
- **Diagnostic design:** 25 questions, timed, drawn from all five weighted domains with roughly the exam's own distribution (D1 5, D2 5, D3 5, D4 4, D5 4, then 2 mixed). Cover the full depth of each domain rather than drilling one topic: an alarm-evaluation question, an RTO/RPO question, a plan-versus-state question, an `AccessDenied` question, and a reachability question. Do not review notes first — the point is to measure recall, not recognition.
- **Domains / references:** All domains; [official SOA-C03 guide](assets/docs/soa-c03-exam-guide.pdf), this roadmap, and each domain README under `aws-cloudops/domains/`.
- **Depends on:** None.
- **Done when:** Exam objectives and weights are understood, the learner can identify the authorized CLI identity/region without sharing credentials, lab boundaries are agreed, and a dated diagnostic baseline is recorded per domain in [PROGRESS.md](PROGRESS.md). Reconnaissance alone does not complete this phase, and neither does reading.

### Phase 1 — Monitoring and investigation (Domain 1)

- **Window:** Oct 5–6, live AWS required, then reinforce Oct 16–18 (was Oct 1–4)
- **Scope:** Metrics, alarms and M-of-N evaluation; logs/events; symptom-led investigation; performance signals and proportionate remediation.
- **Domains / references:** Domain 1; [Domain 1 notes](aws-cloudops/domains/01-monitoring-logging-analysis-remediation-performance-optimization/README.md); [Lab 01](aws-cloudops/knowledge/labs/01-disposable-alarm-and-iac/README.md).
- **Depends on:** Phase 0.
- **Note on pacing:** Phase 1 consumed Oct 1–3 on alarm M-of-N evaluation alone, so the remaining Domain 1 objectives — signal selection between metrics and logs, Flow Logs versus HTTP response evidence, missing-data treatment, and performance signals — are still unassessed. Lab 01 supplies the disposable alarm target that the existing workload alarm cannot, which is why this phase needs live AWS and sits before the cutoff.
- **Done when:** The learner independently explains a fresh alarm evaluation and diagnoses a new operational symptom from relevant evidence, distinguishing what metrics, logs, Flow Logs, and HTTP responses can and cannot establish. Any hands-on change uses the Lab 01 disposable target, never the existing workload alarm.

### Phase 2 — Reliability and recovery (Domain 2)

- **Window:** Oct 9–10, then reinforce Oct 16–18 (was Oct 5–7)
- **Scope:** Scalability/elasticity, AZ resilience, load balancing, backup versus replication, restore, RTO/RPO, and recovery strategies/cost.
- **Domains / references:** Domain 2; [Domain 2 notes](aws-cloudops/domains/02-reliability-business-continuity/README.md).
- **Depends on:** Phase 0.
- **No live AWS required.** The RTO/RPO and backup-versus-replica reasoning can be assessed without resources, which is why this phase can absorb an overrun from Phases 1, 3, or 4 and still finish inside the study window.
- **Done when:** Given a new scenario, the learner chooses a recovery/availability design from explicit RTO and RPO requirements, distinguishes a backup from a replica, and explains how recovery would be verified.

### Phase 3 — Deployment and automation (Domain 3)

- **Window:** Oct 7–8, live AWS required (was Oct 8–10)
- **Scope:** Provisioning/deployment patterns, Terraform and OpenTofu configuration/provider/resource graph, state and locking, reviewed plans, and Terragrunt's role in composing reusable modules into environment stacks.
- **Domains / references:** Domain 3; [Domain 3 notes](aws-cloudops/domains/03-deployment-provisioning-automation/README.md); [Lab 01](aws-cloudops/knowledge/labs/01-disposable-alarm-and-iac/README.md); plus the existing OpenTofu/AWS lab guidance.
- **Depends on:** Phase 0; use Phase 1's observe → configure → verify pattern where helpful.
- **Runs immediately after Phase 1 on purpose.** Both use Lab 01's resources, so the CLI-created instance and alarm must still exist when the OpenTofu comparison begins — that comparison is the exercise. Placing this after the networking content would also have left only four days before playground access ends, with no recovery day.
- **Done when:** The learner can explain configuration versus state and a plan's proposed changes, then complete the CLI → Console → OpenTofu loop with an understood plan and verified cleanup. Do not apply IaC to the existing alarm, and never build a second copy of a CLI-created resource without choosing recreate or import deliberately.

### Phase 4 — Networking and content delivery (Domain 5)

- **Window:** Oct 11–13, live AWS required, then targeted reinforcement Oct 22–25 (was Oct 11–14; reinforce Oct 22–25)
- **Scope:** IP/CIDR and addressing; VPC/subnets/routes; security groups versus NACLs; DNS; ALB/NLB and target groups; endpoints/private connectivity; hybrid paths; Flow Logs and reachability investigation; CloudFront/edge and network cost.
- **Domains / references:** Domain 5; [Domain 5 notes](aws-cloudops/domains/05-networking-content-delivery/README.md), [Lab 02](aws-cloudops/knowledge/labs/02-network-reachability/README.md), [IP-addressing concepts](aws-cloudops/knowledge/concepts/01-networking/01-ip-addressing/README.md), and the load-balancing/observability material used in Domains 1–2.
- **Depends on:** Phase 0; Phase 1 concepts support evidence-led troubleshooting.
- **Split:** Oct 11–12 covers addressing, routing, filtering, and DNS. Oct 13 is the [Lab 02](aws-cloudops/knowledge/labs/02-network-reachability/README.md) reachability and Flow Logs exercise, which must finish before access ends. Networking is a stated weaker area, so the Oct 22–25 reinforcement block is protected rather than traded for other domains.
- **Done when:** The learner traces a fresh connectivity incident hop-by-hop, chooses tests that discriminate between DNS, routing, filtering, listener/target, and return-path causes, and explains the remaining uncertainty. Any network lab is isolated and has a cost/cleanup check.

### Phase 5 — Security and compliance (Domain 4)

- **Window:** Oct 4, then targeted reinforcement Oct 22–25 (was Oct 11–14; reinforce Oct 22–25)
- **Scope:** IAM identity/resource policies, roles and STS, least privilege, permissions boundaries/SCPs, data protection, secrets/certificates, audit, and configuration/compliance evidence.
- **Domains / references:** Domain 4; [Domain 4 notes](aws-cloudops/domains/04-security-compliance/README.md), [Lab 03](aws-cloudops/knowledge/labs/03-iam-policy-evaluation/README.md), and [IAM study notes](aws-cloudops/knowledge/services/13-security-identity-compliance/01-iam/README.md).
- **Depends on:** Phase 0; revisit Phase 4 network controls when a scenario crosses IAM and connectivity boundaries.
- **Moved to open the post-diagnostic window, and it needs no sandbox.** Domain 4 was the only domain still `null` on Oct 3 and carries 16% of the exam. Lab 03 is IAM-only and costs nothing, so this is the highest coverage-per-hour work available and it does not compete for the days before access ends. It is also the only phase that remains fully runnable after Oct 15. Network controls are revisited during the Oct 11–13 networking work rather than deferred to a shared window.
- **Done when:** The learner independently traces an `AccessDenied` scenario through the applicable policy layers, identifies the effective allow/deny and a least-privilege correction, then names evidence to verify the change. Reading imported notes alone does not complete this phase.

### Phase 6 — Cross-domain review and exam readiness

- **Window:** Oct 16–30; exam target Oct 31
- **Scope:** Balanced mixed-domain retrieval, timed practice, review of every miss, targeted reinforcement, final logistics and rest.
- **Domains / references:** All five domains; [PROGRESS.md](PROGRESS.md), domain notes, and legitimate practice material.
- **Depends on:** Phases 1–5 have been studied; unresolved gaps may be carried forward explicitly rather than hidden.
- **Sub-windows:**

| Dates | Focus |
|---|---|
| Oct 16–18 | Repair Phase 1 and Phase 2 gaps the diagnostic exposed; cover remaining Domain 1 and Domain 2 objectives. |
| Oct 19–21 | Repair Phase 3 and Phase 5 gaps; second timed set. |
| Oct 22–25 | Targeted reinforcement on the two weakest domains by diagnostic and timed-set evidence. Protected; networking and security content belongs here. |
| Oct 26–29 | Final timed mixed practice. Every miss logged with domain, misconception, and follow-up action. |
| Oct 30 | Light review and logistics only. Do not start a large lab. |

- **Question volume:** The exam is 65 questions. Target roughly 13 questions per domain across the timed blocks — about 130 total — because a single pass understates the weakest areas and volume is what converts recognition into recall. A domain scoring well on three questions has not been shown to hold under a full mixed set.
- **Done when:** At least two timed mixed practice sets are recorded, every miss has a domain/misconception and follow-up action, high-risk gaps have been revisited, and readiness is assessed from repeated evidence—not inferred from one score.

Phase windows are a starting allocation, not a rigid syllabus. Adjust emphasis inside them using the Phase 0 diagnostic and timed-set results, while retaining coverage of all five weighted domains. Two things are not adjustable by preference: the Oct 15 playground cutoff, and the fact that Phases 1, 3, and 4 need live AWS. If those lab phases are at risk on Oct 13, they take priority over the remaining content study, and the deferred content moves into the Oct 16–25 blocks. Phase 2 is the designated absorber for a Phase 1 or 3 overrun because it needs no AWS.

## Study method

- Use AWS CLI to create or inspect an appropriately scoped example, then inspect the same resource in the AWS Console, and recreate it with OpenTofu where the lab warrants it. Compare observed state, configuration, plans, and cleanup rather than treating any one tool as the answer.
- Keep labs small and isolated. Before any AWS change, review the exact command/configuration, target, expected change, cost, impact, and cleanup. Do not use the existing workload alarm as a disposable lab; see [Domain 1 notes](aws-cloudops/domains/01-monitoring-logging-analysis-remediation-performance-optimization/README.md).
- Complete the entire CLI → Console → OpenTofu loop only when authentication, resource scope, plan, and teardown are clear. The detailed tutoring and lab workflows are in [the tutoring skill](.agents/skills/aws-cloudops-tutoring/SKILL.md) and [the OpenTofu/AWS lab skill](.agents/skills/aws-opentofu-labs/SKILL.md).
- Rebalance the schedule using practice results, while preserving weighted coverage of all five domains. Current learner evidence and readiness are tracked separately in [PROGRESS.md](PROGRESS.md).

## Official reference

- Local copy: [AWS Certified CloudOps Engineer – Associate (SOA-C03) exam guide](assets/docs/soa-c03-exam-guide.pdf) ([official AWS source](https://docs.aws.amazon.com/pdfs/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03.pdf); download details and SHA-256 in [assets/docs/README.md](assets/docs/README.md)).

## Updating the roadmap

Revise planned dates and evidence when access constraints or practice results change. After completing a planned item, record what actually happened in [PROGRESS.md](PROGRESS.md); do not turn plan rows into completion claims. The [official SOA-C03 exam guide](assets/docs/soa-c03-exam-guide.pdf) defines exam scope; check the [AWS-hosted guide](https://docs.aws.amazon.com/pdfs/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03.pdf) for updates.
