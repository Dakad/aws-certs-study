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

## Phase summary

| Phase | Focus / domain | Depends on | Window | Exit gate (summary) | Status |
|---|---|---|---|---|---|
| 0 | Foundation and baseline — all domains | — | Sep 28–30 | Objectives, lab guardrails, identity/region habits, and diagnostic baseline recorded. | ☐ pending |
| 1 | Monitoring and investigation — [Domain 1](aws-cloudops/domains/01-monitoring-logging-analysis-remediation-performance-optimization/README.md) | 0 | Oct 1–4 | Independently explain an alarm evaluation and diagnose a fresh symptom from evidence. | ☐ pending |
| 2 | Reliability and recovery — [Domain 2](aws-cloudops/domains/02-reliability-business-continuity/README.md) | 0 | Oct 5–7 | Choose a recovery design for explicit RTO/RPO needs and explain restore verification. | ☐ pending |
| 3 | Deployment and automation — [Domain 3](aws-cloudops/domains/03-deployment-provisioning-automation/README.md) | 0; Phase 1 pattern is useful | Oct 8–10 | Complete a scoped CLI → Console → OpenTofu loop and explain plan, state, and cleanup. | ☐ pending |
| 4 | Networking and content delivery — [Domain 5](aws-cloudops/domains/05-networking-content-delivery/README.md) | 0; Phase 1 evidence skills | Oct 11–14; reinforce Oct 22–25 | Trace a fresh connectivity incident and complete a safe isolated network exercise. | ☐ pending |
| 5 | Security and compliance — [Domain 4](aws-cloudops/domains/04-security-compliance/README.md) | 0 | Oct 11–14; reinforce Oct 22–25 | Explain an effective access decision, least-privilege correction, and verification. | ☐ null |
| 6 | Cross-domain review and exam readiness — all domains | 1–5 studied | Oct 16–30 | Record and review at least two timed mixed sets, then assess readiness from the evidence. | ☐ null |

Status key: `☐ pending` = started, exit gate not met; `☐ null` = not started; `☑ done` = exit gate met and evidence recorded. This overview mirrors the detailed evidence in [PROGRESS.md](PROGRESS.md); update the status only from that evidence.

## Phases and completion criteria

The phases provide a sequence and clear exit evidence. The security and networking phases intentionally share a time window; their order can flex around the lab schedule. Dependencies identify learning prerequisites, not a requirement to finish every subtopic before previewing another domain. The status column above mirrors the phase state recorded in [PROGRESS.md](PROGRESS.md), which holds the detailed evidence.

### Phase 0 — Foundation and baseline

- **Window:** Sep 28–30
- **Scope:** Read the exam guide; map all five domains; confirm account/profile and region habits; set lab cost, scope, and cleanup guardrails; take a mixed-domain diagnostic.
- **Domains / references:** All domains; [official SOA-C03 guide](assets/docs/soa-c03-exam-guide.pdf), this roadmap, and each domain README under `aws-cloudops/domains/`.
- **Depends on:** None.
- **Done when:** Exam objectives and weights are understood, the learner can identify the authorized CLI identity/region without sharing credentials, lab boundaries are agreed, and a dated diagnostic baseline is recorded. Reconnaissance alone does not complete this phase.

### Phase 1 — Monitoring and investigation (Domain 1)

- **Window:** Oct 1–4
- **Scope:** Metrics, alarms and M-of-N evaluation; logs/events; symptom-led investigation; performance signals and proportionate remediation.
- **Domains / references:** Domain 1; [Domain 1 notes](aws-cloudops/domains/01-monitoring-logging-analysis-remediation-performance-optimization/README.md).
- **Depends on:** Phase 0.
- **Done when:** The learner independently explains a fresh alarm evaluation and diagnoses a new operational symptom from relevant evidence, distinguishing what metrics, logs, Flow Logs, and HTTP responses can and cannot establish. Any hands-on change uses a separate disposable target, never the existing workload alarm.

### Phase 2 — Reliability and recovery (Domain 2)

- **Window:** Oct 5–7
- **Scope:** Scalability/elasticity, AZ resilience, load balancing, backup versus replication, restore, RTO/RPO, and recovery strategies/cost.
- **Domains / references:** Domain 2; [Domain 2 notes](aws-cloudops/domains/02-reliability-business-continuity/README.md).
- **Depends on:** Phase 0.
- **Done when:** Given a new scenario, the learner chooses a recovery/availability design from explicit RTO and RPO requirements, distinguishes a backup from a replica, and explains how recovery would be verified.

### Phase 3 — Deployment and automation (Domain 3)

- **Window:** Oct 8–10
- **Scope:** Provisioning/deployment patterns, Terraform and OpenTofu configuration/provider/resource graph, state and locking, reviewed plans, and Terragrunt's role in composing reusable modules into environment stacks.
- **Domains / references:** Domain 3; [Domain 3 notes](aws-cloudops/domains/03-deployment-provisioning-automation/README.md), plus the existing OpenTofu/AWS lab guidance.
- **Depends on:** Phase 0; use Phase 1's observe → configure → verify pattern where helpful.
- **Done when:** The learner can explain configuration versus state and a plan's proposed changes, then complete a small isolated CLI → Console → OpenTofu exercise with an understood plan and verified cleanup. Do not apply IaC to the existing alarm.

### Phase 4 — Networking and content delivery (Domain 5)

- **Window:** Oct 11–14, then targeted reinforcement Oct 22–25
- **Scope:** IP/CIDR and addressing; VPC/subnets/routes; security groups versus NACLs; DNS; ALB/NLB and target groups; endpoints/private connectivity; hybrid paths; Flow Logs and reachability investigation; CloudFront/edge and network cost.
- **Domains / references:** Domain 5; [Domain 5 notes](aws-cloudops/domains/05-networking-content-delivery/README.md), [IP-addressing concepts](aws-cloudops/knowledge/concepts/01-networking/01-ip-addressing/README.md), and the load-balancing/observability material used in Domains 1–2.
- **Depends on:** Phase 0; Phase 1 concepts support evidence-led troubleshooting.
- **Done when:** The learner traces a fresh connectivity incident hop-by-hop, chooses tests that discriminate between DNS, routing, filtering, listener/target, and return-path causes, and explains the remaining uncertainty. Any network lab is isolated and has a cost/cleanup check.

### Phase 5 — Security and compliance (Domain 4)

- **Window:** Oct 11–14, then targeted reinforcement Oct 22–25
- **Scope:** IAM identity/resource policies, roles and STS, least privilege, permissions boundaries/SCPs, data protection, secrets/certificates, audit, and configuration/compliance evidence.
- **Domains / references:** Domain 4; [Domain 4 notes](aws-cloudops/domains/04-security-compliance/README.md) and [IAM study notes](aws-cloudops/knowledge/services/13-security-identity-compliance/01-iam/README.md).
- **Depends on:** Phase 0; revisit Phase 4 network controls when a scenario crosses IAM and connectivity boundaries.
- **Done when:** The learner independently traces an `AccessDenied` scenario through the applicable policy layers, identifies the effective allow/deny and a least-privilege correction, then names evidence to verify the change. Reading imported notes alone does not complete this phase.

### Phase 6 — Cross-domain review and exam readiness

- **Window:** Oct 16–30; exam target Oct 31
- **Scope:** Balanced mixed-domain retrieval, timed practice, review of every miss, targeted reinforcement, final logistics and rest.
- **Domains / references:** All five domains; [PROGRESS.md](PROGRESS.md), domain notes, and legitimate practice material.
- **Depends on:** Phases 1–5 have been studied; unresolved gaps may be carried forward explicitly rather than hidden.
- **Done when:** At least two timed mixed practice sets are recorded, every miss has a domain/misconception and follow-up action, high-risk gaps have been revisited, and readiness is assessed from repeated evidence—not inferred from one score. Oct 30 is light review only; avoid starting a large lab.

Phase windows are a starting allocation, not a rigid syllabus. Adjust them from diagnostic and practice results while retaining coverage of all five weighted exam domains.

## Study method

- Use AWS CLI to create or inspect an appropriately scoped example, then inspect the same resource in the AWS Console, and recreate it with OpenTofu where the lab warrants it. Compare observed state, configuration, plans, and cleanup rather than treating any one tool as the answer.
- Keep labs small and isolated. Before any AWS change, review the exact command/configuration, target, expected change, cost, impact, and cleanup. Do not use the existing workload alarm as a disposable lab; see [Domain 1 notes](aws-cloudops/domains/01-monitoring-logging-analysis-remediation-performance-optimization/README.md).
- Complete the entire CLI → Console → OpenTofu loop only when authentication, resource scope, plan, and teardown are clear. The detailed tutoring and lab workflows are in [the tutoring skill](.agents/skills/aws-cloudops-tutoring/SKILL.md) and [the OpenTofu/AWS lab skill](.agents/skills/aws-opentofu-labs/SKILL.md).
- Rebalance the schedule using practice results, while preserving weighted coverage of all five domains. Current learner evidence and readiness are tracked separately in [PROGRESS.md](PROGRESS.md).

## Official reference

- Local copy: [AWS Certified CloudOps Engineer – Associate (SOA-C03) exam guide](assets/docs/soa-c03-exam-guide.pdf) ([official AWS source](https://docs.aws.amazon.com/pdfs/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03.pdf); download details and SHA-256 in [assets/docs/README.md](assets/docs/README.md)).

## Updating the roadmap

Revise planned dates and evidence when access constraints or practice results change. After completing a planned item, record what actually happened in [PROGRESS.md](PROGRESS.md); do not turn plan rows into completion claims. The [official SOA-C03 exam guide](assets/docs/soa-c03-exam-guide.pdf) defines exam scope; check the [AWS-hosted guide](https://docs.aws.amazon.com/pdfs/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03.pdf) for updates.
