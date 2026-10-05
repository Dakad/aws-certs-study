# AWS CloudOps study progress

**Last updated:** 2026-10-04  
**Current Lab 03 profile:** `personal-cloudops-lab`, region `eu-north-1`; personal-account setup explicitly authorized and verified on 2026-10-04. Use this profile for Lab 03 only; account identifiers and authentication details are not retained.
**Current playground study profile:** `sso-apptweakplayground-apptweakadmin` — `ApptweakAdmin`, region `eu-west-1`. The learner verified SSO login and caller identity on 2026-10-04. Use this profile for playground study commands; keep mutations scoped to the agreed lab.
**Overall:** Phase 0 diagnostic complete (23/25); Phase 5 access-control exit gate met on 2026-10-04 with an independent diagnosis/correction and explicit verification plan. No timed practice-exam baseline or whole-domain mastery has been established.

This file is the current source of truth for learner progress. Record only phase-gate evidence, material lab/resource state, and substantial independent transfer. Do not add question-by-question transcripts or routine guided exchanges.

The exam schedule and planned evidence live in [`ROADMAP.md`](ROADMAP.md). Keep actual learner evidence here and in the relevant domain page; do not duplicate the schedule in this file.

## Domain status

| SOA-C03 domain | Status | Evidence so far | Next evidence needed |
|---|---|---|---|
| 1. Monitoring, Logging, Analysis, Remediation, and Performance Optimization (22%) | Learning | Inspected a CloudWatch CPU alarm's settings, history, and graph. After correction of the 84%/78% case, correctly identified 84%/81% as `ALARM` because both datapoints breach and M=2 is met. | Continue with metrics-versus-logs signal selection; later revisit missing-data treatment independently, then continue remaining monitoring and investigation objectives. |
| 2. Reliability and Business Continuity (22%) | Learning | Discussed AZ resilience, geographic placement, cost, and application state. Correctly connected replication lag over five minutes to missing a strict `<5-minute` RPO for that recovery copy. Independently distinguished RTO from RPO: ruled out the data-loss and backup-frequency readings, and judged a 100-minute restoration against a 1-hour RTO as missed because it bounds the user's wait rather than the start time. | Choose a recovery design from explicit RTO *and* RPO requirements; retrieve the `<5` versus `<=5` backup-interval boundary. |
| 3. Deployment, Provisioning, and Automation (22%) | Learning | Selected a CLI → Console → OpenTofu learning approach; no end-to-end IaC lab has been completed. | Complete a small isolated lab, explain the plan/state, and verify cleanup. |
| 4. Security and Compliance (16%) | Practiced | Five original access-control scenarios reviewed; Lab 03 IAM-only evaluation, Console inspection and cleanup verified. Final endpoint-migration exit check correctly identifies the scoped correction and supplies five role-specific positive, negative and regression tests with explicit expected outcomes. | Phase 5 exit gate met; retain balanced Domain 4 reinforcement and broader coverage. IaC recreation and KMS lab work were not performed; the final exit check was a paper scenario. |
| 5. Networking and Content Delivery (18%) | Learning | Completed read-only account reconnaissance; discussed load-balancer layers/protocols and AZ, state, and traffic-cost considerations. No troubleshooting lab or independent assessment yet. | Diagnose a fresh reachability incident from evidence, then perform a safe isolated networking lab. |

Status meanings: **Not started** = not yet studied; **Learning** = explanation or guided practice completed; **Practiced** = hands-on exercise or several relevant questions completed; **Demonstrated** = independently solved a new scenario and explained the reasoning.

## Phase tracker

| Phase | State | Evidence so far | Remaining gate / next action |
|---|---|---|---|
| 0. Foundation and baseline | `done` | Exam scope, lab boundaries, and 23/25 mixed-domain diagnostic baseline completed. The learner independently verified the authorized playground identity and configured region without recording account identifiers. | Exit gate met. Verify identity and region before a future lab mutation. |
| 1. Monitoring and investigation (D1) | `pending` | Alarm settings, History, and graph inspected; after correction, correctly applied 2-of-2 to 84%/81%. | Independently diagnose a fresh symptom from relevant evidence; later distinguish `OK` from `INSUFFICIENT_DATA`; keep the existing-workload alarm read-only. |
| 2. Reliability and recovery (D2) | `pending` | Discussed AZ resilience, geography/cost, application state, RPO, and replication lag. RTO now independently recalled and correctly applied to a restoration-duration case. | Choose a recovery design from explicit RTO and RPO requirements, stating which requirement drives the backup interval and which drives the restore path. |
| 3. Deployment and automation (D3) | `pending` | CLI → Console → OpenTofu approach selected; no isolated IaC exercise completed. | Complete a scoped lab, explain configuration/state/plan, compare tools, and verify cleanup; include Terragrunt composition when appropriate. |
| 4. Networking and content delivery (D5) | `pending` | Read-only account reconnaissance and introductory load-balancer discussion completed. | Trace a fresh reachability incident systematically and complete a safe isolated networking exercise. |
| 5. Security and compliance (D4) | `done` | IAM-only lab evaluation, Console inspection, and cleanup verified. In the final endpoint-migration paper scenario, learner selected the bucket-policy correction without broader KMS grants and supplied positive, negative, and regression tests with expected outcomes. | Exit gate met on 2026-10-04. Reinforce Domain 4 during October 22–25; IaC recreation and KMS lab work remain unperformed. |
| 6. Cross-domain review and exam readiness | `null` | No timed practice baseline yet. | Begin after studying the domain phases; complete and review at least two timed mixed practice sets. |

## Hands-on evidence

| Date | Exercise | Evidence and limits | Resource state |
|---|---|---|---|
| 2026-10-04 | Lab 03 IAM-only lifecycle | IAM policy evaluation, learner Console inspection, and authorized cleanup complete. IaC recreation and KMS exercise not performed. | Lab role, instance profile, and both custom policies deleted; exact readbacks returned `NoSuchEntity`. No compute, buckets, KMS keys, or Organizations controls changed. |
| 2026-09-28 | Read-only playground reconnaissance | Confirmed caller identity and surveyed selected account services. | No resources created or changed. |
| 2026-09-28–2026-10-03 | CloudWatch CPU alarm observation | Existing workload alarm inspected in the Console; it transitioned from `INSUFFICIENT_DATA` to `OK` with continuous low CPU data. | Existing alarm is not a disposable lab resource. Do not edit, import, apply IaC to, or delete it. |

## Readiness

No timed practice-exam baseline exists. Establish readiness using repeated timed mixed-domain performance, explanations for missed questions, and closure of high-risk gaps.
