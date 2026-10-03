# AWS CloudOps Engineer Associate roadmap

**Exam target:** AWS Certified CloudOps Engineer – Associate (SOA-C03), October 31, 2026  
**Study window:** September 28–October 30, 2026  
**AWS access:** AppTweak playground access ends October 15, 2026. A personal AWS account is available as an optional lab environment afterward. Do not assume a lab will run there; first confirm a secure authentication method, exact scope, cost, and cleanup.

This file holds the exam plan: scope, schedule, constraints, and intended evidence. Record completed work, learner strengths, corrections, and current status in [PROGRESS.md](PROGRESS.md); keep technical study notes in the relevant domain pages.

## Exam coverage

Weights below are from the AWS SOA-C03 exam guide. All five domains receive planned study time. Networking/investigation gets modest additional targeted practice because it is a stated weaker area, not at the expense of the other domains.

| Exam domain | Weight | Planned coverage |
|---|---:|---|
| [1. Monitoring, Logging, Analysis, Remediation, and Performance Optimization](aws-cloudops/domain-1-monitoring.md) | 22% | Metrics, alarms, logs/events, investigation, remediation, and performance optimization. |
| [2. Reliability and Business Continuity](aws-cloudops/domain-2-reliability.md) | 22% | Scaling, high availability, backups, restore/DR, RTO/RPO, and failure handling. |
| [3. Deployment, Provisioning, and Automation](aws-cloudops/domain-3-deployment.md) | 22% | Provisioning, change automation, deployment strategies, and infrastructure as code. |
| [4. Security and Compliance](aws-cloudops/domain-4-security.md) | 16% | IAM/security controls, data protection, audit/configuration, and compliance scenarios. |
| [5. Networking and Content Delivery](aws-cloudops/domain-5-networking.md) | 18% | Network paths, DNS/content delivery, connectivity investigation, and network cost. |

## Balanced schedule

| Dates | Focus | Planned evidence |
|---|---|---|
| Sep 28–30 | Baseline, exam objectives, account/service map, CLI profile and region habits | Account reconnaissance; first mixed diagnostic quiz; confirm lab safety/cost boundaries. |
| Oct 1–4 | Domain 1: monitoring and investigation | Read CloudWatch metrics/logs/alarms; diagnose a small symptom from evidence; Console and CLI observations. |
| Oct 5–7 | Domain 2: reliability and continuity | Compare scaling/HA/backup/restore choices; complete scenario questions and one safe hands-on exercise if useful. |
| Oct 8–10 | Domain 3: deployment and automation | CLI-create a small isolated lab, inspect it in Console, recreate it with OpenTofu, compare plan/state, clean up. |
| Oct 11–14 | Domain 5 and targeted networking investigation, plus Domain 4 security review | Trace packet/reachability path; investigate routing, SG/NACL, DNS and logs; review IAM/data protection. Verify lab cleanup by Oct 14. |
| Oct 15 | Playground access cutoff | Final read-only inventory and cleanup verification; retain notes, not credentials or sensitive account data. |
| Oct 16–21 | Domains 1–3 reinforcement, balanced | Timed mixed questions; revisit weakest subtopics; continue labs in the personal account if useful after confirming CLI authentication, scope, cost, and cleanup. |
| Oct 22–25 | Domains 4–5 reinforcement | Mixed security/networking scenarios; explain evidence and eliminate plausible distractors. |
| Oct 26–29 | Full mixed review | At least two timed practice sets; classify every miss by domain and misconception; target review from results. |
| Oct 30 | Light final review | Key notes, rest, logistics; no new large lab. |

This is a starting allocation, not a rigid syllabus. Adjust based on diagnostic and practice results while retaining coverage of all five domains.

## Study method

- Use AWS CLI to create or inspect an appropriately scoped example, then inspect the same resource in the AWS Console, and recreate it with OpenTofu where the lab warrants it. Compare observed state, configuration, plans, and cleanup rather than treating any one tool as the answer.
- Keep labs small and isolated. Before any AWS change, review the exact command/configuration, target, expected change, cost, impact, and cleanup. Do not use the existing workload alarm as a disposable lab; see [Domain 1 notes](aws-cloudops/domain-1-monitoring.md).
- Complete the entire CLI → Console → OpenTofu loop only when authentication, resource scope, plan, and teardown are clear. The detailed tutoring and lab workflows are in [the tutoring skill](.agents/skills/aws-cloudops-tutoring/SKILL.md) and [the OpenTofu/AWS lab skill](.agents/skills/aws-opentofu-labs/SKILL.md).
- Rebalance the schedule using practice results, while preserving weighted coverage of all five domains. Current learner evidence and readiness are tracked separately in [PROGRESS.md](PROGRESS.md).

## Official reference

- Local copy: [AWS Certified CloudOps Engineer – Associate (SOA-C03) exam guide](assets/docs/soa-c03-exam-guide.pdf) ([official AWS source](https://docs.aws.amazon.com/pdfs/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03.pdf); download details and SHA-256 in [assets/docs/README.md](assets/docs/README.md)).

## Updating the roadmap

Revise planned dates and evidence when access constraints or practice results change. After completing a planned item, record what actually happened in [PROGRESS.md](PROGRESS.md); do not turn plan rows into completion claims. The [official SOA-C03 exam guide](assets/docs/soa-c03-exam-guide.pdf) defines exam scope; check the [AWS-hosted guide](https://docs.aws.amazon.com/pdfs/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03.pdf) for updates.
