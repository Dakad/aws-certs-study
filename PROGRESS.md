# AWS CloudOps study progress

**Last updated:** 2026-10-04  
**Current Lab 03 profile:** `personal-cloudops-lab`, region `eu-north-1`; personal-account setup explicitly authorized and verified on 2026-10-04. Use this profile for Lab 03 only; account identifiers and authentication details are not retained.
**Current playground study profile:** `sso-apptweakplayground-apptweakadmin` — `ApptweakAdmin`, region `eu-west-1`. The learner verified SSO login and caller identity on 2026-10-04. Use this profile for playground study commands; keep mutations scoped to the agreed lab.
**Overall:** Phase 0 diagnostic complete (23/25); Phase 5 access-control exit gate met on 2026-10-04 with an independent diagnosis/correction and explicit verification plan. No timed practice-exam baseline or whole-domain mastery has been established.

This file is the current source of truth for learner progress. Update it after each session with observed evidence: what you attempted, what you explained correctly, what needs work, and whether you transferred the idea to a new scenario. A topic is not mastered because it was explained or a lab succeeded once.

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

Phase state measures whether a phase's completion criteria in [ROADMAP.md](ROADMAP.md) have been met; it is not the same as the domain learning status above. Use `null` for not started, `pending` for started but exit criteria not yet met, and `done` only when evidence for the exit criteria is recorded.

| Phase | State | Evidence so far | Remaining gate / next action |
|---|---|---|---|
| 0. Foundation and baseline | `done` | Exam scope and account/service reconnaissance discussed; lab boundaries established; 23/25 mixed-domain diagnostic baseline completed. The learner independently verified the authorized read-only playground identity and configured region (`eu-west-1`) without recording account identifiers. | Exit gate met. Use the same identity/region check before a future lab mutation, then continue the scheduled domain phases. |
| 1. Monitoring and investigation (D1) | `pending` | Alarm settings, History, and graph inspected; after correction, correctly applied 2-of-2 to 84%/81%. The earlier confusion between a valid non-breaching datapoint and insufficient data remains a follow-up. | Continue Domain 1 signal selection; later independently distinguish `OK` from `INSUFFICIENT_DATA`; keep the existing-workload alarm read-only. |
| 2. Reliability and recovery (D2) | `pending` | Discussed AZ resilience, geography/cost, application state, RPO, and replication lag. RTO now independently recalled and correctly applied to a restoration-duration case. | Choose a recovery design from explicit RTO and RPO requirements, stating which requirement drives the backup interval and which drives the restore path. |
| 3. Deployment and automation (D3) | `pending` | CLI → Console → OpenTofu approach selected; no isolated IaC exercise completed. | Complete a scoped lab, explain configuration/state/plan, compare tools, and verify cleanup; include Terragrunt composition when appropriate. |
| 4. Networking and content delivery (D5) | `pending` | Read-only account reconnaissance and introductory load-balancer discussion completed. | Trace a fresh reachability incident systematically and complete a safe isolated networking exercise. |
| 5. Security and compliance (D4) | `done` | Five original scenarios reviewed; IAM-only lab evaluation, Console inspection and cleanup verified. In the final endpoint-migration paper scenario, learner correctly selected the bucket-policy correction without broader KMS grants, then supplied five role-specific tests with correct positive, negative and regression expectations and explained the intended direct-decrypt denial. | Exit gate met on 2026-10-04; today's work complete. Next scheduled session: Phase 1 / Domain 1 signal selection on October 5. Domain 4 reinforcement remains October 22–25; no whole-domain mastery claim. Original denied-baseline principal simulation, IaC recreation and KMS lab remain unperformed, not retroactively claimed. |
| 6. Cross-domain review and exam readiness | `null` | No timed practice baseline yet. | Begin after studying the domain phases; complete and review at least two timed mixed practice sets. |

## Demonstrated strengths

- **Operational evidence gathering:** For an HTTP 500 symptom, proposed checking the response with `curl`, application/EC2 logs, and using `dig` when name resolution is suspect. This shows a useful symptom-first approach; choosing Flow Logs should follow evidence that network-path investigation is relevant.
- **Systems tradeoff awareness:** In a reliability discussion, considered AZ resilience, the audience's geography, inter-region traffic cost, and whether application state can be separated.
- **Cross-tool learning design:** Proposed creating with AWS CLI, inspecting in the Console, and recreating with Terraform/OpenTofu. This makes observed state, configuration, and repeatability comparable.
- **RTO/RPO discrimination:** Correctly separated recovery-time objectives from recovery-point objectives unprompted, and rejected the "recovery must begin within the RTO" reading in favour of the restoration-time reading.
- **Alarm threshold application:** After correction, identified that two 5-minute average datapoints of 83% and 85% both satisfy the `>=80%` threshold. This is one exchange, not yet independent mastery of M-of-N evaluation.
- **Combined access-control diagnosis (2026-10-04):** In the final independent case, separated the HTTP bucket-policy restriction from missing K2 coverage in the permissions boundary, proposed HTTPS and a targeted boundary update, and selected useful HTTPS, HTTP, and KMS encryption tests. Expected test outcomes still needed tutor completion.
- **Verification-plan transfer (2026-10-04):** In a subsequent endpoint-migration case, independently stated `ReportsRole`, request path/action, expected result and interpretation for restored V2/K2 access, denied HTTP, denied direct KMS decrypt/encrypt, and preserved V1/K1 access. Correctly distinguished intended direct-decrypt denial from the S3 production failure. This closes the verification-expectations gap for the Phase 5 exit gate, not whole-domain mastery or actual execution of these hypothetical tests.

These are evidence-backed early strengths, not final ratings or predictions of exam performance.

## Misconceptions and corrections

| Date | Topic | Initial understanding | Correction / current evidence | Follow-up |
|---|---|---|---|---|
| 2026-10-04 | Lab 03 boundary versus inline allow | Initially predicted account bucket listing would succeed after detaching only the S3 deny, correctly citing `allow-s3-list`. | After explanation, correctly answered that the unchanged boundary denies any action on any resource, so the request remains denied. Earlier supplied-document simulation returned `explicitDeny`, boundary allow `false`; no real policy was detached. Learner also correctly challenged the tutor's inconsistent claim of an unclear policy reference: the question had explicitly named the policy. | Starting from the original configuration, predict removal of only the boundary while retaining the S3 explicit deny; later distinguish simulation from real-role evidence. |
| 2026-10-04 | Cross-account KMS correction scope | Correctly proposed adding `kms:Decrypt` to the caller's IAM policy, but also proposed a key-policy addition despite the scenario already establishing that permission. | Keep the already-sufficient key policy unchanged; scope the missing IAM allow to K3's full key ARN. Inspection is valid, but the stated evidence does not justify changing both policies. | Distinguish a policy worth inspecting from a policy that needs modification. |
| 2026-10-04 | Verification completeness | Proposed relevant tests, but sometimes omitted positive/negative checks or described the outcome as “see what happens.” | Earlier expectations needed tutor completion. Subsequent independent endpoint-migration response correctly specifies five role-specific positive, negative and regression tests with expected outcomes and interpretations, including the intended direct-decrypt denial. | Phase 5 gap closed by observed transfer; revisit across later domains. Tutor supplied an additional unapproved-endpoint negative check; do not attribute that sixth check to the learner or equate plans with executed tests. |
| 2026-10-03 | CloudWatch 2-of-2 alarm | Initially unclear on “2-of-2” and predicted that an 85% datapoint followed by 15% would trigger the alarm. | Both datapoints in the evaluation window must meet the `>=80%` threshold. After explanation, correctly answered that 83% and 85% would trigger it. | Retrieve the M-of-N rule again with a new pair of values, including one breaching and one non-breaching datapoint. |
| 2026-10-03 | Present non-breaching datapoint vs. missing data | For present readings of 84% and 78% in a 2-of-2 `>=80%` alarm, correctly observed that 78% was below threshold but answered `INSUFFICIENT_DATA`. | With both readings present, only one breaches, so the 2-of-2 condition is false and the state is `OK`; a valid non-breaching datapoint is not missing data. Immediate retest: correctly answered `ALARM` for 84%/81%, explaining both breach and M=2 is met. | Continue Domain 1 signal selection; revisit missing-data treatment later with an explicit missing point. |
| 2026-09-28 | Strict RPO `<5 minutes` | Answered “5 minutes” for the maximum backup interval. | Five-minute intervals only support an idealized `<=5-minute` age; a strict `<5-minute` target needs a shorter interval and operational margin. The tutor initially accepted the answer incorrectly. | Revisit with a recovery-point age and replication-lag example. |
| 2026-09-28 | ALB unhealthy targets | Suggested dropping a request or returning 5xx / “upstream not available.” | A 503 can occur when there are no usable registered targets. If all registered targets are unhealthy, ALB fails open and still routes to them; a target may then return an error. | Continue learning target groups and health-check behavior in an isolated example. |

Questions and “I don't know” responses are not mistakes by themselves. Verification omissions above are evidence gaps, not proof that the learner misunderstood every underlying rule.

## Hands-on evidence

| Date | Exercise | Evidence and limits | Resource state |
|---|---|---|---|
| 2026-10-04 | Lab 03 IAM-only lifecycle | Setup, policy evaluation and learner Console inspection recorded below. Assistant completed authorized exact-target cleanup after checking lab tags, dependencies, policy usage and zero EC2 profile usage in `eu-north-1`. Cross-region EC2 inspection was blocked by an Organizations deny; no global absence claim. IaC recreation and KMS exercise not performed. | Role, instance profile and both custom policies deleted; exact readbacks each returned `NoSuchEntity`. Boundary versions v1/v2 removed; AWS-managed SSM policy only detached. No compute, buckets or KMS keys created; no KMS or Organizations changes. |
| 2026-09-28 | Read-only playground reconnaissance | Confirmed caller identity and surveyed selected account services. This was reconnaissance, not a lab or domain assessment. | No resources created or changed. |
| 2026-09-28–2026-10-03 | CloudWatch CPU alarm observation | An alarm was created on an existing EC2 workload before the exact command was shown. The original command was not saved. On 2026-10-03, the learner inspected its Console settings, history, and graph; history showed `INSUFFICIENT_DATA` → `OK`, while the reviewed CPU graph remained below 2% with no gaps. No new AWS change was made during the Console review. | Existing alarm is not a disposable lab resource. Do not edit, import, apply IaC to, or delete it. Use a separate disposable target for any future end-to-end IaC exercise. |

## Session log

### 2026-10-04 — Tutoring format and canonical notes updated

- Saved teaching preferences in the [tutoring skill](.agents/skills/aws-cloudops-tutoring/SKILL.md): phase objective/goal/services/exit criteria first, concise explanation before scenarios, faster movement past demonstrated basics, operational multi-control questions, a small non-spoiling hint immediately after each question, and a visible finite progress counter. Learning mode remains the default; no personal-background details are added.
- Added the original [effective-permissions concept](aws-cloudops/knowledge/concepts/02-security/02-policies/README.md) and expanded canonical IAM/S3/KMS notes from the lesson. Source verification and documentation updates are not new learner mastery or executed test evidence. Phase 5 is complete; the next scheduled block remains Domain 1 on October 5.

### 2026-10-04 — Phase 5 exit gate met

- Learner retains the scoped bucket-policy correction accepting V1 and V2 and explicitly rejects broader KMS permissions. Using `ReportsRole`, correctly expects HTTPS V2/K2 download success, HTTP V2/K2 denial, direct K2 decrypt denial, direct K2 encrypt denial, and HTTPS V1/K1 regression success. Each test names principal, action/path, outcome and interpretation; direct-decrypt denial is correctly identified as intended behavior, not the production blocker.
- Tutor adds one hardening check: HTTPS `GetObject` through an unapproved endpoint or without an endpoint should remain denied. This sixth check is tutor-supplied, not independently selected by the learner. [AWS endpoint restrictions](https://docs.aws.amazon.com/AmazonS3/latest/userguide/example-bucket-policies-vpc-endpoint.html).
- Original scenarios 5/5 reviewed; final exit check complete, 0 remaining today. Phase 5 marked `done` against its stated exit gate; Domain 4 stays Practiced, broader coverage/reinforcement open. This is a verification plan in a paper scenario, not five executed AWS tests. No AWS mutation or new resources.
- Next scheduled session: October 5, Phase 1 / Domain 1 metrics-versus-logs signal selection; preserve the existing-workload alarm read-only. IaC recreation and supplemental KMS lab remain unperformed. Roadmap and domain status synchronized.

### 2026-10-04 — Final exit check: endpoint-migration diagnosis

- Learner correctly selected the bucket policy as the correction point and proposed also permitting V2, preserving V1. This identifies the scoped endpoint restriction without proposing broader KMS grants. Tutor specified the implementation as adding V2 to the existing deny-condition exception; no policy-syntax misconception inferred from the learner's shorthand.
- Original scenarios 5/5 reviewed; final exit check diagnosis/correction correct, verification plan not yet answered. Phase 5 remains pending. Next give positive, negative and regression tests using `ReportsRole`, with expected outcomes and what each establishes. Paper scenario only; no AWS mutation or new mastery claim.

### 2026-10-04 — Lab 03 exact IAM-only cleanup verified

- Reverified authorized identity, lab role/profile tags, expected inline and managed attachments, sole profile membership, and no shared managed-policy use. `eu-north-1` checks returned zero instance-profile associations and zero instances using the profile. An Organizations deny blocked the broader regional inspection; proceeded within the known IAM-only creation scope, without changing the guardrail.
- After exact-command review, deleted `soa-c03-lab03-role-profile`, removed inline `allow-s3-list`, detached AWS-managed SSM, removed the role's boundary association, and deleted `soa-c03-lab03-role`. Deleted boundary nondefault v1, boundary policy/default v2, and explicit-deny policy/default v1. Each of the four exact resources returned `NoSuchEntity`; cleanup verified.
- Original scenarios 5/5 reviewed, 0 remaining; IAM-only evaluation, learner Console inspection and cleanup complete. Phase 5 remains pending for independent verification expectations. Next exercise: specify positive, negative and regression tests with expected outcomes for a fresh S3/KMS remediation. IaC recreation and supplemental KMS lab remain unperformed. No scripts changed, unrelated resources touched, credentials or sensitive identifiers retained.

### 2026-10-04 — Scoped-boundary Console confirmation

- Learner screenshot confirms `soa-c03-lab03-boundary` is set and shows `AllowBucketInventory`, `Allow`, `s3:ListAllMyBuckets`, resource `*`, matching the tested configuration. The retained description says "permits no actions" and is stale; the screenshot does not show the version identifier.
- Original scenarios 5/5 reviewed, 0 remaining; scoped test and Console inspection complete, exact IAM-only cleanup pending. No AWS changes this turn or new mastery claim. No raw screenshot or sensitive identifiers retained.

### 2026-10-04 — Lab 03 scoped boundary restored and verified

- After command/scope review and identity verification, assistant created default boundary version `v2`, permitting only `s3:ListAllMyBuckets` on `*`, and attached it only to the disposable lab role. Old deny-all version `v1` is retained, not default; the S3-deny policy remains detached.
- Fresh assumed-role test returned identity `True` and bucket count `0`; current-role simulation reports bucket listing `allowed` with boundary coverage. Supplied-policy control model allows S3 and `ssm:ListAssociations` before the boundary, then allows S3 and implicitly denies SSM with the scoped boundary.
- Live-role SSM simulation already returned `explicitDeny` / `AllowedByOrganizations: false` before reattachment and still does afterward. No specific SCP was inspected; no Organizations control was changed. This is not an isolated real SSM boundary-denial test. See [Lab evidence](aws-cloudops/knowledge/labs/03-iam-policy-evaluation/EVIDENCE.md).
- Original scenarios 5/5 reviewed, 0 remaining in that block; scoped-boundary verification complete. Next learner inspects the attached scoped boundary in Console before exact IAM-only cleanup. Phase 5 pending; no scripts changed, credentials or sensitive identifiers retained, or new mastery claim.

### 2026-10-04 — Lab 03 positive verification and current-role simulation

- Learner reports identity check `True` and bucket count `0`, confirming successful `s3:ListAllMyBuckets` using the lab-role session with an empty inventory. Console screenshot confirms boundary association removed, inline allow and SSM attachment retained, S3-deny attachment absent. The CLI values are user-reported; the supplied screenshot establishes the Console configuration.
- Assistant read-only checks verified intended account, no role boundary (`null`), only SSM managed attachment, and current `SimulatePrincipalPolicy` decision `allowed` for bucket listing. This matches the current successful request, not a retroactively tested original denied-baseline simulation. No assistant AWS mutation or script change.
- Original scenarios 5/5 reviewed; three live configurations verified (identity deny, boundary deny, allowed listing). Current simulator/API comparison complete; scoped-boundary test and cleanup pending. Next preview the exact scoped allow boundary before applying it, preserving a guardrail instead of treating its removal as the production correction. Identifiers, credentials and raw screenshots not retained; no broad mastery claim.

### 2026-10-04 — Lab 03 boundary-denial test and API verification

- Learner screenshot shows identity check `True` and `s3:ListAllMyBuckets` `AccessDenied` explicitly naming `soa-c03-lab03-boundary`. Console screenshot confirms `soa-c03-lab03-explicit-deny` is no longer attached; inline `allow-s3-list`, SSM attachment and boundary remain.
- Console displayed `{}` for the boundary. Assistant made read-only API checks with the authorized lab profile after verifying the intended account: current default policy document still contains `NoPermissions`, `Deny`, action `*`, resource `*`; attached managed-policy names contain only `AmazonSSMManagedInstanceCore`. No policy mutation performed. The Console display did not reflect the retrieved document.
- Second real denial configuration verified; matches the earlier supplied-document model's expected boundary denial without claiming live-role baseline simulation. Original scenarios 5/5 reviewed; positive verification and cleanup pending. Next remove only the lab role's boundary association after exact scope/command review, retaining the existing grants; this increases effective permissions and is scoped to the disposable role. No identifiers, credentials or raw screenshots retained.

### 2026-10-04 — Lab 03 real-role denied baseline

- Learner screenshot shows lab-role identity check `True` followed by `ListBuckets` / `s3:ListAllMyBuckets` returning `AccessDenied`. Error context names an explicit deny in the identity-based policy `soa-c03-lab03-explicit-deny`. This confirms the assumed-role request path was used, unlike the earlier successful source-profile listing.
- The message reports one denial reason, not every applicable blocker; it does not establish that the separately configured boundary stopped applying. See [AWS S3 denial diagnostics](https://docs.aws.amazon.com/AmazonS3/latest/userguide/troubleshoot-403-errors.html). Baseline simulator comparison and live single-layer-removal tests remain pending.
- Recorded sanitized evidence only: no account identifiers, ARNs, credentials or raw screenshot. No assistant AWS call or mutation. Next controlled test removes only the S3-deny attachment after exact command/scope review, retains boundary and inline allow, verifies configuration/identity and repeats bucket listing. Original scenarios 5/5 reviewed; denied real-role baseline complete, remediation verification and IAM-only cleanup pending.

### 2026-10-04 — Lab 03 AssumeRole screenshot diagnosis

- Learner-provided screenshots show a successful source-profile `s3api list-buckets` call with an empty bucket inventory, a local CLI argument error from passing `--role-session-name` to that S3 command, and a successful `sts assume-role` call for the lab role.
- STS success establishes that role assumption was authorized for that request; it does not establish the lab role can list buckets. The source-profile success tested a different credential context. Tutor explained that returned temporary credentials must be used for the subsequent request; the session-name option belongs to STS, not S3.
- No credentials, account identifiers, identity ARNs or screenshot contents retained. No AWS calls or policy changes by the assistant. Next step: acquire a fresh session without printing credentials, verify the lab-role identity in a subshell and execute `s3:ListAllMyBuckets` using those credentials. Expected denial is conditional on the original deny policies remaining applied; actual assumed-role S3 outcome and cleanup pending. Original scenarios 5/5 reviewed.

### 2026-10-04 — Lab 03 final prediction and difficulty correction

- Learner correctly predicted `s3:ListAllMyBuckets` is permitted in the hypothetical with both deny layers removed, inline `allow-s3-list` retained and no other applicable restrictions. Tutor qualified the wording: this grants the named action, not every S3 operation. This is reasoning evidence, not an executed API result.
- Learner reported the recent questions were too easy for SOA-C03. Tutor accepted the calibration error: a short rule check can isolate a gap, but repeated single-rule variations are not sufficient exam-level practice. Close this sequence and resume evidence-based access troubleshooting, scoped remediation and verification. No personal background information is retained.
- Original scenarios remain 5/5 reviewed; elementary lab predictions complete. No new AWS test or mutation; live-role baseline simulation, assumed-role request verification and IAM-only cleanup pending. Domain 4 Practiced, Phase 5 pending.

### 2026-10-04 — Lab 03 boundary-only removal prediction

- Starting from the original configuration, the hypothetical removed only the permissions boundary while retaining `soa-c03-lab03-explicit-deny` and inline `allow-s3-list`. Learner correctly predicted `s3:ListAllMyBuckets` remains denied because explicit `Deny s3:*` overrides its allow.
- This is a correct prediction with reasoning, not an executed AWS result or broad mastery claim. No AWS changes or tests. Original scenario block remains 5/5 reviewed; real-role testing and cleanup pending. Final guided prediction: remove both deny layers, retain the inline allow, and assume no other applicable restrictions.

### 2026-10-04 — Lab 03 policy-reference clarification

- Learner correctly objected that a policy no longer applied to a role cannot continue affecting its permissions. Tutor clarified that the earlier hypothetical removed `soa-c03-lab03-explicit-deny`, while the different `soa-c03-lab03-boundary` remained set through the role's separate permissions-boundary field.
- Resolved: learner pointed out that the original question explicitly named `soa-c03-lab03-explicit-deny`; the tutor's later explanation blaming an unclear policy reference was inconsistent. Learner requested explicit questions and explanations. For subsequent hypotheticals, state the starting configuration, exact action, changed layer and unchanged layers.
- Learner now correctly explains that removing only the S3-deny attachment does not permit `s3:ListAllMyBuckets`, because the retained boundary denies every action on every resource. This is a correct guided teach-back after explanation, not independent mastery. No new AWS changes or tests. Scenario block remains 5/5 reviewed; real-role testing and cleanup pending. Next prediction starts from the original configuration and removes only the boundary, retaining the S3 deny and inline allow.

### 2026-10-04 — Lab 03 first what-if prediction and simulation

- **Scope clarification:** Learner reasonably asked whether “listing” meant buckets or objects. Tutor clarified the exact tested action, `s3:ListAllMyBuckets` (account bucket inventory), versus `s3:ListBucket` for objects in a general-purpose bucket. Ambiguous wording is a tutor framing issue, not a learner misconception.
- **Prediction / feedback:** For removing only the separate S3-deny policy, learner predicted success via the inline allow. Correct identification of the identity-policy grant was preserved; the effective-access prediction needed correction because the unchanged boundary explicitly denies every action.
- **Observed model result:** Ran read-only `iam:SimulateCustomPolicy` using the displayed inline allow and deny-all boundary documents, deliberately excluding the separate S3-deny policy. Returned `explicitDeny` and `AllowedByPermissionsBoundary: false`. This tests the supplied-document hypothetical, not the actual role or all live account controls.
- **Resource state / next check:** No AWS resource or policy was changed, no role was assumed and no S3 API was called. Real-role testing and IAM-only cleanup remain pending. Next prediction: remove only the boundary while retaining the attached S3 deny. Domain 4 Practiced, Phase 5 pending; original scenario block 5/5 complete.

### 2026-10-04 — Lab 03 Console evidence and boundary explanation

- **Learner evidence:** Shared a redacted screenshot of `soa-c03-lab03-role` showing inline `allow-s3-list` (`Allow` / `s3:ListAllMyBuckets`), attached `soa-c03-lab03-explicit-deny` (`Deny` / `s3:*`), `AmazonSSMManagedInstanceCore`, and the set `soa-c03-lab03-boundary` (`Deny` / all actions and resources). Console policy inspection is complete; the screenshot does not establish a tested API outcome. Details are recorded in [Lab 03 evidence](aws-cloudops/knowledge/labs/03-iam-policy-evaluation/EVIDENCE.md); no screenshot identifiers or authentication details are retained.
- **Understanding / teaching:** Correctly recognized a permissions boundary as a permission ceiling and proposed an SCP-like analogy for a role. Asked why it is needed. Tutor clarified the user/role attachment scope, actions/resources/conditions rather than a policy-count limit, no permission grant by the boundary itself, and its use for controlled delegation. This explanation is not an independently demonstrated result.
- **Progress / next check:** Console inspection complete; predict whether S3 listing would succeed after removing only the attached S3 deny while leaving the deny-all boundary unchanged. No layer was removed and no simulator or real S3 call was run. Evaluation and IAM-only cleanup remain pending; Domain 4 Practiced, Phase 5 pending, prior scenario block 5/5 complete.

### 2026-10-04 — Lab 03 personal-account setup

- **Scope:** Learner explicitly selected the personal account and authorized IAM-only setup using `personal-cloudops-lab` in `eu-north-1`. Re-verified the intended account and empty lab-prefixed role, policy and instance-profile listings before creation; no identifiers or authentication details are retained.
- **Creation:** Ran the existing `cli/01-create.sh` unchanged, with the selected profile/region and inherited access-key credential variables removed for that process. Created `soa-c03-lab03-role`, `soa-c03-lab03-role-profile`, `soa-c03-lab03-boundary` and `soa-c03-lab03-explicit-deny`; script exited successfully.
- **Read-back evidence:** Confirmed the role's expected boundary and lab tag, instance-profile membership/tag, inline `allow-s3-list` policy, and attached `AmazonSSMManagedInstanceCore` plus the explicit-deny policy. Read policy documents confirm an inline `s3:ListAllMyBuckets` allow, attached `s3:*` deny, and boundary deny on all actions.
- **Resource state:** IAM resources remain for the exercise. No existing workload was changed and no compute, bucket or KMS key was created. Cleanup must target these exact IAM resources and attachments; do not run the teardown script's KMS-deletion section for this IAM-only scope.
- **Progress / next step:** Setup complete; learner-led Console inspection, predictions, policy evaluation and cleanup remain pending. Inspect the role's inline policy, managed-policy attachments and permissions boundary in the Console before the next test. The separate evaluator simulator-argument issue remains unresolved; no evaluator or script rewrite was performed. Domain 4 remains Practiced, Phase 5 pending; scenario block 5/5 complete, 0 remaining.

### 2026-10-04 — Lab 03 setup retry with ApptweakAdmin

- **Commit:** Sealed the profile/progress updates and the one-line AssumeRole session-name fix in local commit `bc8754ea` (`Use ApptweakAdmin profile for study labs`). Not pushed.
- **Preflight:** Re-verified `sso-apptweakplayground-apptweakadmin` uses the intended playground and `ApptweakAdmin`. Lab-prefixed role, managed-policy and instance-profile listings succeeded and were empty.
- **Setup result:** Ran the reviewed existing creation script. Its first mutation, `iam:CreatePolicy` for `soa-c03-lab03-boundary`, returned `AccessDenied`: no identity-based policy allows that action. This is a setup-identity denial, not the intentional denial by the lab role, which was never created.
- **Resource state:** Repeated all three lab-prefixed listings after the failure; all were empty. No lab resources were created, no cleanup mutation was required, and no SSO permissions were changed.
- **Progress / next step:** Provisioning is blocked on authorized IAM management permissions. Evaluation, Console inspection and IaC remain unexecuted; Domain 4 stays Practiced, Phase 5 pending, and the scenario block complete (5/5, 0 remaining). Obtain scoped lab permissions through the account administrator or explicitly agree on an alternative environment/exercise before retrying.

### 2026-10-04 — Playground study profile changed

- **Learner action:** Configured `sso-apptweakplayground-apptweakadmin`, completed SSO login, and ran `sts get-caller-identity`. Shared output confirms `ApptweakAdmin` in the intended playground account. Account identifiers and authentication URLs are not retained here.
- **Going forward:** Use the new profile for study commands. The previous `PlaygroundAdmin` profile remains unchanged; its earlier permission denials remain valid historical evidence.
- **Next step:** Repeat Lab 03's read-only IAM preflight with the new profile. Successful login and identity verification do not establish its IAM inspection/management permissions or complete the lab. No new provisioning or policy-evaluation result is recorded; Domain 4 remains Practiced, Phase 5 pending, and the scenario block complete (5/5, 0 remaining).

### 2026-10-04 — Lab 03: read-only preflight

- **Observed:** Confirmed the configured playground profile's caller identity. No lab-prefixed roles were returned by `ListRoles`. `ListPolicies`, `ListInstanceProfiles`, and exact-name `GetPolicy`/`GetInstanceProfile` checks returned `AccessDenied`, stating that no identity-based policy allows those actions. Policy/profile existence is therefore unverified, not confirmed absent.
- **Safety:** No AWS mutation or lab resource creation was attempted. The script change remains limited to the requested AssumeRole session-name argument; the separate simulator argument issue remains unresolved.
- **Progress:** Preparation started; provisioning, policy evaluation, Console inspection, IaC and cleanup are not executed. Five scenarios remain complete (5/5, 0 remaining); Domain 4 remains Practiced and Phase 5 pending. This preflight adds no learner mastery evidence.
- **Next step:** Confirm an authorized lab profile with the required IAM inspection and scoped management permissions before creation. Do not broaden permissions or switch accounts implicitly.

### 2026-10-04 — Domain 4: S3/KMS access-control scenarios

- **Block progress:** 5/5 scenarios reviewed; 0 remaining. This is a completion counter, not a 5/5 correctness score or a timed practice-exam result. The first four cases were guided; the final case combined the taught rules independently. Lab 03 has not started.
- **Terminology warm-up:** After explanation, correctly identified customer-managed keys as the category the customer can administer. Requesting an explanation of the term was a tutor sequencing issue, not a learner mistake.
- **Scenario 1 — K2 boundary mismatch:** Correctly proposed allowing `kms:Decrypt` on K2 in addition to K1; the tutor made the permissions-boundary target explicit. Correctly expected K2 decryption to work and encryption to remain denied; the tutor added end-to-end S3 download verification.
- **Scenario 2 — Key-policy investigation:** Correctly selected the K2 key policy as the next investigation target when IAM and boundary permissions were sufficient. The answer was an appropriate hypothesis, not proof of the blocking statement. The tutor explained direct authorization versus IAM-policy delegation.
- **Scenario 3 — Transport restriction:** Correctly diagnosed the HTTP bucket-policy deny and proposed changing the failed request to HTTPS. Supplied the positive retry; the tutor added the negative check that HTTP must remain denied.
- **Scenario 4 — Cross-account access:** Correctly proposed adding `kms:Decrypt` to the caller role's IAM policy and an encryption negative test. The tutor clarified that the owner-account key policy already permitted access, specified the key ARN scope, and added the expected denial and positive download check.
- **Scenario 5 — Independent combined case:** Correctly identified both blockers and proposed the two needed changes: HTTPS and K2 decryption coverage in the boundary. Selected HTTPS, HTTP, and encryption tests. The tutor supplied explicit expected outcomes, use of the application role, and the K1 regression check. Changing the boundary before the client scheme was not treated as an error; both fixes were needed.
- **Assessment:** Domain 4 is Practiced. One independent combined diagnosis supports transfer of the taught rules, not whole-domain mastery. Phase 5 remains pending because verification expectations still needed coaching; Lab 03 and broader security/compliance coverage remain open.
- **Safety:** Discussion only; no AWS calls, resource changes, or tests were executed in this block.
- **Tutor process correction:** Progress was initially tracked in chat without updating the repository. At the learner's request, reconciled this file and the [Domain 4 README](aws-cloudops/domains/04-security-compliance/README.md). Future active tutoring should record observed answers and corrections in both canonical records, while retaining the visible completed/total counter.
- **Next step:** Read-only review of [Lab 03](aws-cloudops/knowledge/labs/03-iam-policy-evaluation/README.md) policies and cleanup scripts before any creation; then follow the explained CLI → learner-led Console → OpenTofu → verified-cleanup workflow. No additional scenario is scheduled in this five-case block.

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

### 2026-10-03 — Phase 0 diagnostic baseline: Domains 2 and 3 blocks

- **Result:** 10/10 across reliability/recovery and deployment/automation.
- **Demonstrated:** Correctly distinguished RPO from RTO; selected Multi-AZ for availability/failover rather than read scaling; identified functional recovery verification; and understood multi-AZ resilience limits. Correctly described OpenTofu plans, remote state locking, Terragrunt composition, infrastructure drift, and plan review as the apply safeguard.
- **Evidence limit:** Strong initial baseline evidence, not domain completion or hands-on proof. Continue the final security, networking, and cross-domain baseline blocks.

### 2026-10-03 — Phase 0 diagnostic baseline: Domains 4, 5, and cross-domain blocks

- **Result:** 9/10. Total diagnostic baseline: **23/25**.
- **Demonstrated:** Correctly applied explicit-deny precedence, an `AccessDenied` investigation sequence, Secrets Manager usage, and CloudTrail's audit purpose. Correctly selected a reachability investigation path, ALB Layer 7 routing, NAT Gateway egress for a private subnet, alarm `INSUFFICIENT_DATA` meaning, and the CLI → Console → import-or-recreate → reviewed-plan → cleanup workflow.
- **Correction:** Security groups are stateful; network ACLs are stateless. This matters because return traffic is automatically allowed by a matching security-group flow, whereas a network ACL needs explicit rules in both directions.
- **Phase 0 status:** The diagnostic baseline gate is complete. Phase 0 remains `pending` only until the chosen lab account/profile and default region are confirmed without storing credentials or account identifiers.

### 2026-10-03 — Domain 4: explicit-deny evaluation

- **Learner evidence:** Correctly concluded that an SCP explicit deny for `s3:GetObject` on `*` overrides an EC2 role identity-policy allow for `s3:GetObject` on `reports/*`.
- **Assessment:** Correct application of explicit-deny precedence. Continue by distinguishing a permissions boundary (maximum permission ceiling) from a resource policy (an additional grant path).
- **Tutor correction:** The learner correctly identified that a permissions boundary allowing only `s3:GetObject` blocks an identity-policy `s3:PutObject` allow. Continuing with single-policy recall after the 23/25 baseline is not useful at the learner's level. From here, use Associate-level operational scenarios with interacting services, evidence, trade-offs, and verification.
- **Tutor correction — baseline boundary:** The 25-question Phase 0 diagnostic is complete. Do not present additional questions as baseline work or substitute ad-hoc questions for a stated phase activity. State the next phase, outcome, and activity before using any question as a learning check.

## Readiness

No timed practice-exam baseline exists. Do not infer readiness from the current conversations or one quiz. Establish readiness using repeated timed mixed-domain performance, explanations for missed questions, and closure of high-risk gaps.
