# AWS CloudOps Engineer Associate study journal

**Exam target:** AWS Certified CloudOps Engineer – Associate (SOA-C03), October 31, 2026  
**Study window:** September 28–October 30, 2026  
**AWS playground access ends:** October 15, 2026  
**Personal lab account:** Opened October 2, 2026; IAM users `dummy` (read-only) and `admin` (PowerUser); no access keys created. Available as an optional lab account after playground access ends.  
**Status:** Started — baseline account reconnaissance complete; no domain mastery has been assessed yet.

This is the durable progress record. Update it after each study session with evidence: what was attempted, what you got right, what needs work, and whether you can transfer the learning to a new scenario. Do not mark a topic mastered just because it was explained or a lab succeeded once.

## How to use this journal

For each topic, use these statuses:

- **Not started** — not yet studied.
- **Learning** — explanation or guided practice completed; still needs retrieval practice.
- **Practiced** — completed a hands-on exercise or several relevant questions.
- **Demonstrated** — independently explained the reasoning and solved a new scenario.

After each session, add a dated entry to the session log and update relevant domain rows. Track quiz scores only with their source, date, and whether the questions were timed. Record mistakes as learning signals, not as a judgment: capture the mistaken assumption, the evidence/rule that corrects it, and a fresh follow-up question. Record strengths with evidence too.

## Exam coverage tracker

Weights below are from the current AWS SOA-C03 exam guide. The schedule gives every domain planned time; networking/investigation gets a little extra targeted practice because it is your stated weak area, not because it outweighs the other domains.

| Exam domain | Weight | Status | Evidence / next action |
|---|---:|---|---|
| [1. Monitoring, Logging, Analysis, Remediation, and Performance Optimization](aws-cloudops/domain-1-monitoring.md) | 22% | Not started | Cover CloudWatch metrics/logs/alarms, agents, dashboards, investigation and performance signals. |
| [2. Reliability and Business Continuity](aws-cloudops/domain-2-reliability.md) | 22% | Not started | Cover scaling, high availability, backups, restore/DR and failure handling. |
| [3. Deployment, Provisioning, and Automation](aws-cloudops/domain-3-deployment.md) | 22% | Learning | Your CLI → Console inspection → OpenTofu rebuild approach is planned; execute and document a small isolated lab. |
| [4. Security and Compliance](aws-cloudops/domain-4-security.md) | 16% | Not started | Cover IAM/security controls, data protection, audit/configuration and compliance scenarios. |
| [5. Networking and Content Delivery](aws-cloudops/domain-5-networking.md) | 18% | Learning | Account reconnaissance completed; next, practice systematic reachability diagnosis and a safe isolated VPC lab. |

**Overall completion:** Baseline only. Domain mastery and exam readiness are not yet measured; no practice-exam baseline yet.

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

## Learning profile — initial hypotheses, not final ratings

### Likely strengths to validate

- **Production operations context:** you report senior platform engineering experience with AWS and Kubernetes. This should help connect exam scenarios to operational tradeoffs; validate with scenario questions.
- **Systems thinking across tools:** you proposed learning one architecture through AWS CLI creation, Console inspection, and IaC recreation. That is a strong way to compare desired state, observed state, and repeatability.
- **Operational caution:** you called out the playground access cutoff and explicitly want progress and cleanup tracked. This supports disciplined resource lifecycle and cost management.
- **Good learning calibration:** you identified networking/investigation as weaker while also insisting that preparation cover the whole exam. We should maintain balanced study rather than equate “weak area” with “only area.”

These are early signals from your background and study preferences, not demonstrated exam strengths yet. Upgrade them only when practice supplies evidence.

### Mistakes and corrections

No technical answer has been assessed yet, so there are **no learner mistakes recorded**. We will not invent mistakes from questions you asked or from a tutoring mismatch.

| Date | Topic | Initial assumption / miss | Correction and evidence | Follow-up result |
|---|---|---|---|---|
| — | — | None assessed yet | — | — |

### Tutor adjustment

On Sep 28, the tutor over-focused on networking because it was identified as a weak area. That was a study-planning mistake by the tutor, not a learner mistake. Keep all five domains represented according to exam weight, with networking receiving modest extra practice only.

## Lab ledger

| Date | Objective | Method | Result / evidence | Cleanup |
|---|---|---|---|---|
| Sep 28 | Map existing playground account before choosing labs | Read-only AWS CLI inspection | Confirmed account identity and reviewed regional compute, default VPC, S3/CloudFront, and selected security/operations services. No resources created or changed. This was reconnaissance, not a lab or domain assessment. | No lab resources created. |
| Sep 28 | Observe a CloudWatch alarm lifecycle | AWS CLI created `codex-study-cpu-high-ec2-lab` on an EC2 CPU metric; no actions enabled | Playground identity was re-verified. Alarm uses 5-minute average, 2 of 2 datapoints >=80%, missing data not breaching. It first showed `INSUFFICIENT_DATA` (“Initial alarm creation”) then `OK` after evaluation. No instance settings were changed. | Temporary alarm remains until Console/OpenTofu comparison; remove and verify after lab. |

## Session log

### 2026-09-28 — Baseline and plan

- **Completed:** Read-only account reconnaissance; discussed CLI/Console/IaC learning workflow and exam timeline.
- **Demonstrated:** Clear preference for triangulating the same infrastructure across CLI, Console, and IaC; requested balanced coverage and an external progress record.
- **Baseline started:** On a Domain 1 API-latency/5xx scenario, you proposed response inspection with `curl`, EC2 logs, VPC Flow Logs, and conditional DNS checking with `dig`. Strong evidence-gathering instincts; one prioritization point to practice is using Flow Logs only when network-path evidence is relevant, since they cannot show HTTP/application errors. Normal CPU does not rule out other bottlenecks. See [Domain 1 notes](aws-cloudops/domain-1-monitoring.md).
- **Also discussed:** You had not used an ALB before and asked how ALB/NLB map to OSI layers and protocols; this is newly introduced, not a mistake. In a reliability scenario, you considered AZ resilience, user geography/cost, and application state, but did not yet apply the stated <5-minute RPO. See [Domain 2 notes](aws-cloudops/domain-2-reliability.md) and [Domain 5 notes](aws-cloudops/domain-5-networking.md).
- **ALB health-check edge case:** You said the ALB might drop the request or send a 5xx/upstream-unavailable response. This was partly right: a 503 can occur when there are no registered/usable targets. The nuance is that if all registered targets are unhealthy, ALB fails open and still forwards traffic to them; a target could then return an error. The tutor initially framed your answer too bluntly. See [Domain 5 notes](aws-cloudops/domain-5-networking.md).
- **RPO exercise correction:** You answered “5 minutes” for the longest backup interval under an RPO strictly **less than** five minutes. The tutor incorrectly accepted this: five-minute backups only support an idealized `<=5-minute` age; a strict `<5-minute` target requires a shorter interval, with additional margin in real systems. This was the tutor's assessment error. See [Domain 2 notes](aws-cloudops/domain-2-reliability.md).
- **Replication-lag check:** Correctly identified that lag over five minutes means a <5-minute RPO is not met for that replica, assuming it is the recovery copy. Terminology refinement: replication copy is not the same thing as a backup. See [Domain 2 notes](aws-cloudops/domain-2-reliability.md).
- **Still unknown:** Overall SOA-C03 performance and independent technical reasoning across the remaining domains; this single item is not a score or mastery assessment.
- **Next:** Continue in the agreed order with the Domain 1 lab: Console inspection, then OpenTofu recreation and cleanup of the temporary alarm. The Domain 2 discussion was a detour. See [Domain 1 lab notes](aws-cloudops/domain-1-monitoring.md).

### 2026-10-02 — Resume Domain 1 alarm comparison

- **Resumed from:** The pending Console inspection of `codex-study-cpu-high-ec2-lab`; no domain change.
- **Read-only check:** The configured AWS SSO session had expired and could not refresh non-interactively, so caller identity and live alarm settings were not re-verified. No AWS changes were made.
- **Record correction:** The journal contains the alarm settings but not the literal original `put-metric-alarm` command. Do not present a reconstructed command as the original.
- **Progress:** No new learner answer or mastery evidence yet; Domain 1 remains Learning.
- **Next:** Inspect the alarm in the AWS Console and compare the displayed fields with the saved settings below. See [Domain 1 notes](aws-cloudops/domain-1-monitoring.md).

### 2026-10-03 — Personal AWS lab account

- **Update:** You opened a personal AWS account on October 2 so hands-on study can continue after playground access ends. It has IAM user `dummy` with read-only permissions and IAM user `admin` with PowerUser permissions; neither has access keys.
- **Plan:** Treat this as an optional future lab environment, not an instruction to create resources. Before using its CLI, confirm a secure authentication method; keep the normal scope, cost, and cleanup review. No credentials or account identifiers are recorded here.

### 2026-10-03 — Domain 1 Console check

- **Observed:** The alarm is `OK` in the Console. The screenshot confirms the saved metric, threshold, period, evaluation, and missing-data settings. “No actions” is a separate action-configuration label, not the state reason; the actual state reason still needs to be read from History.
- **Progress:** Console inspection completed; no AWS resource was changed. The screenshot's account and resource identifiers were not copied into this journal.
- **Next:** Check the latest state-update entry in the alarm's History tab. Detailed, redacted settings and the safe IaC boundary are in [Domain 1 notes](aws-cloudops/domain-1-monitoring.md).

## Readiness evidence

| Date | Source / set | Timed? | Overall | Domain breakdown | Main miss themes / next action |
|---|---|---|---:|---|---|
| — | No baseline yet | — | — | — | Establish with an initial mixed diagnostic. |

**Readiness rule:** Do not infer a pass from one quiz. Look for repeated, timed performance across the domains, explainable reasoning on missed questions, and no unresolved high-risk gaps. Use legitimate practice material and follow its licensing terms.

## Tutor session format

1. State the objective and how it maps to an exam domain.
2. Ask for a prediction or initial diagnosis before revealing the answer when useful.
3. Run or inspect the relevant evidence using CLI, Console, or OpenTofu as appropriate.
4. Explain what the evidence establishes and what it does not establish.
5. Ask you to apply the idea to a fresh scenario or reproduce it in another tool.
6. Record demonstrated strengths, mistakes/corrections, and the next action here.

### Conversation pacing preference

- **Required tutoring turn loop:** (1) give brief feedback on the learner's answer, (2) explain/correct the concept with a concrete reason or example, (3) record demonstrated understanding or the misconception in the relevant domain page, and (4) include the next specific exercise/question in the same reply.
- A teaching reply in an active lesson must not end with only a recap, status update, or promise to continue. It must contain an actionable exercise for the learner unless they explicitly ask to pause or stop.
- Do not make the learner choose the next topic or prompt continuation. Follow the balanced study sequence and present one exercise at a time.
- When the learner says “I don't know,” explain and provide a scaffolded example, then continue with a simpler check. Record “not yet learned,” not a mistake.
- When the learner says “ok,” treat it as acknowledgement, not a request to stop; continue with the next planned exercise.
- Assess partial answers precisely. Preserve valid alternatives and distinguish them from the exact scenario's correct behavior; correct the tutor's own imprecise framing when needed.
- Questions should test something just taught or introduce the next small step. Avoid meta-questions such as “would you like to continue?”
- **Tutor quality incident (2026-09-28):** Despite this preference, the tutor repeatedly ended active teaching turns without an exercise, then accepted “5 minutes” for a strict `<5-minute` RPO. Treat this as a concrete failure to follow the protocol. After each learner response, check correctness and boundary conditions, record the result, and immediately provide the next small exercise in that same reply.

### AWS lab change protocol

- Before any AWS mutation, explain the learning objective, show the exact command/configuration that will be used, describe the precise resource and expected change, mention possible charges and cleanup, and state whether it can affect an existing workload.
- Do not use an existing operational workload as a lab target when a disposable resource is practical. Prefer a dedicated, clearly named lab resource. If the only practical target is a real workload, stop and present that choice before changing anything.
- Keep the learning sequence explicit: teach command/options → run the shown command → inspect CLI output → learner inspects the AWS Console and shares a screenshot if desired → explain what the console confirms → only then create IaC for the same resource → compare → clean up and verify.
- Never request AWS credentials or control the learner's laptop. Use only an already-authenticated CLI profile for authorized commands; Console access/inspection is performed by the learner unless they explicitly choose another supported method.
- **Tutor quality incident (2026-09-28):** The CPU alarm was created before the exact command was shown and targeted an existing EC2 workload that had not been selected as a disposable lab target. Do not repeat this sequencing or target-selection error. Leave the current alarm unchanged until the learner has inspected it and the next action is clear.

You can ask for **“show/update my study journal”** at any point. Keep this file free of credentials, secrets, and sensitive account outputs.

## Official reference

- [AWS Certified CloudOps Engineer – Associate (SOA-C03) exam guide](https://docs.aws.amazon.com/pdfs/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03.pdf)

## Handoff — 2026-10-02

### Where we are

- Study started with the account reconnaissance and a small Domain 1 CloudWatch alarm lab. The agreed overall coverage remains balanced across all five exam domains; Domain 2/RPO and ALB discussions were detours, not a change to the sequence.
- This journal and its supporting study files live in this repository.
- Domain 1 Console inspection completed on 2026-10-03; the alarm showed `OK`. “No actions” is not the state reason. Current study status and the next History-tab exercise are in [Domain 1 notes](aws-cloudops/domain-1-monitoring.md). **Do not change or delete this existing-resource alarm for the lab.**
- No AWS credentials were requested. Do not control or attempt to access the learner's laptop/Console. The learner will inspect the Console and may paste a screenshot for explanation.

### Next session — resume Domain 1 in order

1. Continue with the **History** tab exercise in [Domain 1 notes](aws-cloudops/domain-1-monitoring.md) to find the actual state reason.
2. Do not manage the existing alarm as a lab resource; use a separate disposable target for any future end-to-end IaC exercise.
3. Continue remaining Domain 1 monitoring/logging objectives before moving on to the scheduled next exam domain.

### Tutor behavior — important

- Show exact AWS commands/config before a mutation; explain objective, target/scope, potential cost, and cleanup. Prefer disposable resources over existing operational workloads. The alarm target choice was a tutor mistake.
- Use the sequence: explain → show command → run → interpret output → learner checks Console → interpret screenshot → IaC recreation → compare → cleanup/verify.
- After each learner response, provide precise feedback, distinguish partial correctness, update progress, and include the next concrete exercise in the same reply. Do not end an active lesson with a recap alone or make the learner ask what is next. Keep questions purposeful and limited; when the learner says “I don't know,” teach and scaffold rather than mark wrong.
- The learner is done for the evening and is going to bed. Do not continue prompting or schedule a reminder. Resume when they return.
