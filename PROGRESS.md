# AWS CloudOps study progress

**Last updated:** 2026-10-03  
**Overall:** Study started; no practice-exam baseline and no domain mastery has been established.

This file is the current source of truth for learner progress. Update it after each session with observed evidence: what you attempted, what you explained correctly, what needs work, and whether you transferred the idea to a new scenario. A topic is not mastered because it was explained or a lab succeeded once.

The exam schedule and planned evidence live in [`ROADMAP.md`](ROADMAP.md). Keep actual learner evidence here and in the relevant domain page; do not duplicate the schedule in this file.

## Domain status

| SOA-C03 domain | Status | Evidence so far | Next evidence needed |
|---|---|---|---|
| 1. Monitoring, Logging, Analysis, Remediation, and Performance Optimization (22%) | Learning | Inspected a CloudWatch CPU alarm's settings, history, and graph. After correction of the 84%/78% case, correctly identified 84%/81% as `ALARM` because both datapoints breach and M=2 is met. | Continue with metrics-versus-logs signal selection; later revisit missing-data treatment independently, then continue remaining monitoring and investigation objectives. |
| 2. Reliability and Business Continuity (22%) | Learning | Discussed AZ resilience, geographic placement, cost, and application state. Correctly connected replication lag over five minutes to missing a strict `<5-minute` RPO for that recovery copy. Independently distinguished RTO from RPO: ruled out the data-loss and backup-frequency readings, and judged a 100-minute restoration against a 1-hour RTO as missed because it bounds the user's wait rather than the start time. | Choose a recovery design from explicit RTO *and* RPO requirements; retrieve the `<5` versus `<=5` backup-interval boundary. |
| 3. Deployment, Provisioning, and Automation (22%) | Learning | Selected a CLI → Console → OpenTofu learning approach; no end-to-end IaC lab has been completed. | Complete a small isolated lab, explain the plan/state, and verify cleanup. |
| 4. Security and Compliance (16%) | Not started | No learner performance assessed yet. | Explain policy evaluation layers and investigate one `AccessDenied` scenario. |
| 5. Networking and Content Delivery (18%) | Learning | Completed read-only account reconnaissance; discussed load-balancer layers/protocols and AZ, state, and traffic-cost considerations. No troubleshooting lab or independent assessment yet. | Diagnose a fresh reachability incident from evidence, then perform a safe isolated networking lab. |

Status meanings: **Not started** = not yet studied; **Learning** = explanation or guided practice completed; **Practiced** = hands-on exercise or several relevant questions completed; **Demonstrated** = independently solved a new scenario and explained the reasoning.

## Phase tracker

Phase state measures whether a phase's completion criteria in [ROADMAP.md](ROADMAP.md) have been met; it is not the same as the domain learning status above. Use `null` for not started, `pending` for started but exit criteria not yet met, and `done` only when evidence for the exit criteria is recorded.

| Phase | State | Evidence so far | Remaining gate / next action |
|---|---|---|---|
| 0. Foundation and baseline | `pending` | Exam scope and account/service reconnaissance discussed; lab boundaries established. | Record a mixed-domain diagnostic baseline and confirm CLI identity/region habits for the chosen lab account. |
| 1. Monitoring and investigation (D1) | `pending` | Alarm settings, History, and graph inspected; after correction, correctly applied 2-of-2 to 84%/81%. The earlier confusion between a valid non-breaching datapoint and insufficient data remains a follow-up. | Continue Domain 1 signal selection; later independently distinguish `OK` from `INSUFFICIENT_DATA`; keep the existing-workload alarm read-only. |
| 2. Reliability and recovery (D2) | `pending` | Discussed AZ resilience, geography/cost, application state, RPO, and replication lag. RTO now independently recalled and correctly applied to a restoration-duration case. | Choose a recovery design from explicit RTO and RPO requirements, stating which requirement drives the backup interval and which drives the restore path. |
| 3. Deployment and automation (D3) | `pending` | CLI → Console → OpenTofu approach selected; no isolated IaC exercise completed. | Complete a scoped lab, explain configuration/state/plan, compare tools, and verify cleanup; include Terragrunt composition when appropriate. |
| 4. Networking and content delivery (D5) | `pending` | Read-only account reconnaissance and introductory load-balancer discussion completed. | Trace a fresh reachability incident systematically and complete a safe isolated networking exercise. |
| 5. Security and compliance (D4) | `null` | No learner study or assessment recorded yet. | Start with policy evaluation layers and an `AccessDenied` scenario. |
| 6. Cross-domain review and exam readiness | `null` | No timed practice baseline yet. | Begin after studying the domain phases; complete and review at least two timed mixed practice sets. |

## Demonstrated strengths

- **Operational evidence gathering:** For an HTTP 500 symptom, proposed checking the response with `curl`, application/EC2 logs, and using `dig` when name resolution is suspect. This shows a useful symptom-first approach; choosing Flow Logs should follow evidence that network-path investigation is relevant.
- **Systems tradeoff awareness:** In a reliability discussion, considered AZ resilience, the audience's geography, inter-region traffic cost, and whether application state can be separated.
- **Cross-tool learning design:** Proposed creating with AWS CLI, inspecting in the Console, and recreating with Terraform/OpenTofu. This makes observed state, configuration, and repeatability comparable.
- **RTO/RPO discrimination:** Correctly separated recovery-time objectives from recovery-point objectives unprompted, and rejected the "recovery must begin within the RTO" reading in favour of the restoration-time reading.
- **Alarm threshold application:** After correction, identified that two 5-minute average datapoints of 83% and 85% both satisfy the `>=80%` threshold. This is one exchange, not yet independent mastery of M-of-N evaluation.

These are evidence-backed early strengths, not final ratings or predictions of exam performance.

## Misconceptions and corrections

| Date | Topic | Initial understanding | Correction / current evidence | Follow-up |
|---|---|---|---|---|
| 2026-10-03 | CloudWatch 2-of-2 alarm | Initially unclear on “2-of-2” and predicted that an 85% datapoint followed by 15% would trigger the alarm. | Both datapoints in the evaluation window must meet the `>=80%` threshold. After explanation, correctly answered that 83% and 85% would trigger it. | Retrieve the M-of-N rule again with a new pair of values, including one breaching and one non-breaching datapoint. |
| 2026-10-03 | Present non-breaching datapoint vs. missing data | For present readings of 84% and 78% in a 2-of-2 `>=80%` alarm, correctly observed that 78% was below threshold but answered `INSUFFICIENT_DATA`. | With both readings present, only one breaches, so the 2-of-2 condition is false and the state is `OK`; a valid non-breaching datapoint is not missing data. Immediate retest: correctly answered `ALARM` for 84%/81%, explaining both breach and M=2 is met. | Continue Domain 1 signal selection; revisit missing-data treatment later with an explicit missing point. |
| 2026-09-28 | Strict RPO `<5 minutes` | Answered “5 minutes” for the maximum backup interval. | Five-minute intervals only support an idealized `<=5-minute` age; a strict `<5-minute` target needs a shorter interval and operational margin. The tutor initially accepted the answer incorrectly. | Revisit with a recovery-point age and replication-lag example. |
| 2026-09-28 | ALB unhealthy targets | Suggested dropping a request or returning 5xx / “upstream not available.” | A 503 can occur when there are no usable registered targets. If all registered targets are unhealthy, ALB fails open and still routes to them; a target may then return an error. | Continue learning target groups and health-check behavior in an isolated example. |

No other learner mistakes are recorded. Questions and “I don't know” responses are not mistakes by themselves.

## Hands-on evidence

| Date | Exercise | Evidence and limits | Resource state |
|---|---|---|---|
| 2026-09-28 | Read-only playground reconnaissance | Confirmed caller identity and surveyed selected account services. This was reconnaissance, not a lab or domain assessment. | No resources created or changed. |
| 2026-09-28–2026-10-03 | CloudWatch CPU alarm observation | An alarm was created on an existing EC2 workload before the exact command was shown. The original command was not saved. On 2026-10-03, the learner inspected its Console settings, history, and graph; history showed `INSUFFICIENT_DATA` → `OK`, while the reviewed CPU graph remained below 2% with no gaps. No new AWS change was made during the Console review. | Existing alarm is not a disposable lab resource. Do not edit, import, apply IaC to, or delete it. Use a separate disposable target for any future end-to-end IaC exercise. |

## Session log

### 2026-10-03 — Domain 1 CloudWatch Console review

- **Completed:** Compared the alarm's threshold/settings with its History and graph. The graph's continuous sub-2% CPU data explains why the alarm evaluated `OK`; “No actions” describes notification/action configuration, not the alarm state reason.
- **Learner evidence:** Initially did not know what 2-of-2 meant and predicted that 85% then 15% would trigger it. After the rule was explained, applied the `>=80%` threshold to 83%/85%. On 84%/78%, recognized 78% as non-breaching but called the state `INSUFFICIENT_DATA`; after correction, correctly answered `ALARM` for 84%/81% because both breach and M=2 is met.
- **Assessment:** Correctly applied the count on an immediate retest. Distinguishing a present non-breaching datapoint from missing data still needs later retrieval; this is not yet durable mastery.
- **Safety:** No AWS mutation occurred in this Console review. Keep the existing-workload alarm read-only; no original CLI command was recorded.
- **Next exercise:** An application has a rising HTTP 5xx rate while CPU remains low. Which signal would quantify the error rate over time, and which would reveal details for one failing request ID? State what each can establish.
- **Guided signal selection:** Given rising `HTTPCode_Target_5XX_Count` and zero `HTTPCode_ELB_5XX_Count`, selected application/target logs as the next evidence. Correctly reasoned that the ALB did not generate the 5xx and that investigation should continue at the target/application layer. Refinement: this identifies the response origin, not a blanket absence of network faults; the target can be EC2, ECS, EKS, Lambda, or another target type, and downstream dependencies may be the cause.
- **Next exercise:** Learn the three alarm states (`OK`, `ALARM`, `INSUFFICIENT_DATA`) as evaluation outcomes, then apply the same service/metric/log map to a guided case with an ALB-generated 5xx.

### 2026-09-28 — Baseline, account reconnaissance, and initial scenarios

- **Completed:** Read-only AWS account reconnaissance and discussion of the exam timeline and CLI → Console → IaC learning approach. Reconnaissance was not a hands-on lab or domain assessment.
- **Domain 1 evidence:** For an HTTP 500/API-latency symptom, proposed checking response headers/body with `curl`, EC2/application logs, VPC Flow Logs, and using `dig` if hostname resolution is suspect. This is good symptom-first evidence gathering. Follow-up: use Flow Logs when the network path is implicated; they do not explain an application-level HTTP response. Normal CPU does not rule out other bottlenecks. See [Domain 1 notes](aws-cloudops/domains/01-monitoring-logging-analysis-remediation-performance-optimization/README.md).
- **Load balancers:** Had not used an ALB before and asked how ALB, NLB, and Gateway Load Balancer differ. This was a newly introduced topic, not a mistake. Health-check behavior remains a follow-up topic; see [Domain 5 notes](aws-cloudops/domains/05-networking-content-delivery/README.md).
- **Reliability evidence:** Considered AZ resilience, audience geography, inter-region traffic costs, and whether application state can be separated in an availability discussion. Correctly recognized later that replication lag over five minutes does not meet a strict `<5-minute` RPO for that recovery copy. Clarify replica/recovery copy versus backup; see [Domain 2 notes](aws-cloudops/domains/02-reliability-business-continuity/README.md).
- **Tutor correction:** The tutor initially accepted “5 minutes” as a backup interval for a strict `<5-minute` RPO. That was incorrect: the interval must be shorter, with operational margin. This was a tutor assessment error and is recorded as such above.
- **Next evidence:** Continue Domain 1 objectives before changing domains; obtain independent answers on alarm evaluation and monitoring/investigation.

### 2026-10-02 — Resume the CloudWatch alarm comparison

- **Read-only check:** AWS SSO had expired and could not refresh non-interactively, so caller identity and live alarm settings were not re-verified. No AWS changes were made.
- **Record-quality correction:** The original `put-metric-alarm` command was not saved. Do not reconstruct it and present it as the literal original command.
- **Progress:** No new learner answer or mastery evidence was gathered in this session. Domain 1 remained Learning.
- **Next step at that time:** Inspect the alarm in the Console and compare its visible fields with the recorded settings. See [Domain 1 notes](aws-cloudops/domains/01-monitoring-logging-analysis-remediation-performance-optimization/README.md).

### 2026-10-03 — Tutor process correction: teach the service/signal map first

- **Learner feedback:** The learner was asked to choose CloudWatch/AWS services and signals for a 5xx investigation before being taught how to identify the request path, which service emits which signal, or what an alarm state means. The question depended on knowledge not yet introduced.
- **Tutor correction:** Do not treat unfamiliar service names, metric namespaces, or alarm states as a learner knowledge gap before teaching them. Introduce the service map and signal purpose, demonstrate a worked example, then use scaffolded practice before independent recall. Ask fewer, purposeful questions; do not make the learner select the next topic.
- **Next step:** Resume the learner's manually updated M-of-N exercise as written. Before introducing a new signal-selection exercise, teach the request-path-to-service/metric/log map and work through an example first.

### 2026-10-03 — Phase 0 diagnostic baseline: Domain 1 block

- **Result:** 4/5 on the first five monitoring/investigation questions. Correctly selected target/application logs for target-generated ALB 5xx errors, metrics versus logs by purpose, CloudTrail for IAM/security-group API changes, and the limited conclusion from low CPU.
- **Correction:** For a 2-of-3 alarm at `>=80%`, readings of 84%, 78%, and 82% enter `ALARM`: two present datapoints breach, so M=2 is met. The 78% reading is non-breaching, not a reason to remain `OK`.
- **Evidence limit:** This is an initial baseline block, not durable Phase 1 mastery. Continue the timed mixed-domain diagnostic.

## Readiness

No timed practice-exam baseline exists. Do not infer readiness from the current conversations or one quiz. Establish readiness using repeated timed mixed-domain performance, explanations for missed questions, and closure of high-risk gaps.
