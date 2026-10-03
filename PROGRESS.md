# AWS CloudOps study progress

**Last updated:** 2026-10-03  
**Overall:** Study started; no practice-exam baseline and no domain mastery has been established.

This file is the current source of truth for learner progress. Update it after each session with observed evidence: what you attempted, what you explained correctly, what needs work, and whether you transferred the idea to a new scenario. A topic is not mastered because it was explained or a lab succeeded once.

The existing `AWS-CLOUDOPS-STUDY.md` is retained unchanged for now while its schedule and historical notes are considered for a separate `ROADMAP.md`. Do not add new progress entries there; keep new learner evidence here and in the relevant domain page.

## Domain status

| SOA-C03 domain | Status | Evidence so far | Next evidence needed |
|---|---|---|---|
| 1. Monitoring, Logging, Analysis, Remediation, and Performance Optimization (22%) | Learning | Inspected a CloudWatch CPU alarm's settings, history, and graph. Correctly applied the `>=80%` threshold to an 83%/85% pair after learning that 2-of-2 requires both datapoints to breach. | Independently solve a fresh M-of-N scenario; continue the remaining monitoring and investigation objectives. |
| 2. Reliability and Business Continuity (22%) | Learning | Discussed AZ resilience, geographic placement, cost, and application state. Correctly connected replication lag over five minutes to missing a strict `<5-minute` RPO for that recovery copy. | Distinguish RPO from RTO in a new scenario and practice recovery-design tradeoffs. |
| 3. Deployment, Provisioning, and Automation (22%) | Learning | Selected a CLI → Console → OpenTofu learning approach; no end-to-end IaC lab has been completed. | Complete a small isolated lab, explain the plan/state, and verify cleanup. |
| 4. Security and Compliance (16%) | Not started | No learner performance assessed yet. | Explain policy evaluation layers and investigate one `AccessDenied` scenario. |
| 5. Networking and Content Delivery (18%) | Learning | Completed read-only account reconnaissance; discussed load-balancer layers/protocols and AZ, state, and traffic-cost considerations. No troubleshooting lab or independent assessment yet. | Diagnose a fresh reachability incident from evidence, then perform a safe isolated networking lab. |

Status meanings: **Not started** = not yet studied; **Learning** = explanation or guided practice completed; **Practiced** = hands-on exercise or several relevant questions completed; **Demonstrated** = independently solved a new scenario and explained the reasoning.

## Demonstrated strengths

- **Operational evidence gathering:** For an HTTP 500 symptom, proposed checking the response with `curl`, application/EC2 logs, and using `dig` when name resolution is suspect. This shows a useful symptom-first approach; choosing Flow Logs should follow evidence that network-path investigation is relevant.
- **Systems tradeoff awareness:** In a reliability discussion, considered AZ resilience, the audience's geography, inter-region traffic cost, and whether application state can be separated.
- **Cross-tool learning design:** Proposed creating with AWS CLI, inspecting in the Console, and recreating with Terraform/OpenTofu. This makes observed state, configuration, and repeatability comparable.
- **Alarm threshold application:** After correction, identified that two 5-minute average datapoints of 83% and 85% both satisfy the `>=80%` threshold. This is one exchange, not yet independent mastery of M-of-N evaluation.

These are evidence-backed early strengths, not final ratings or predictions of exam performance.

## Misconceptions and corrections

| Date | Topic | Initial understanding | Correction / current evidence | Follow-up |
|---|---|---|---|---|
| 2026-10-03 | CloudWatch 2-of-2 alarm | Initially unclear on “2-of-2” and predicted that an 85% datapoint followed by 15% would trigger the alarm. | Both datapoints in the evaluation window must meet the `>=80%` threshold. After explanation, correctly answered that 83% and 85% would trigger it. | Retrieve the M-of-N rule again with a new pair of values, including one breaching and one non-breaching datapoint. |
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
- **Learner evidence:** Initially did not know what 2-of-2 meant and predicted that 85% then 15% would trigger it. After the rule was explained, correctly applied the `>=80%` threshold to 83% and 85%.
- **Assessment:** Some threshold application demonstrated; independent explanation of the datapoint count and transfer to a fresh example remain untested.
- **Safety:** No AWS mutation occurred in this Console review. Keep the existing-workload alarm read-only; no original CLI command was recorded.
- **Next exercise:** Given a 2-of-2 alarm with a 5-minute period and datapoints of 86% then 74%, state whether it enters alarm and explain both the threshold and datapoint-count requirements.

### Earlier sessions

Earlier reconnaissance and discussions are summarized above. The learner proposed HTTP response, application-log, and conditional DNS checks; discussed load-balancer choice and availability tradeoffs; and correctly interpreted replication lag against an RPO target. See the domain pages for topic-specific evidence and next exercises.

## Readiness

No timed practice-exam baseline exists. Do not infer readiness from the current conversations or one quiz. Establish readiness using repeated timed mixed-domain performance, explanations for missed questions, and closure of high-risk gaps.
