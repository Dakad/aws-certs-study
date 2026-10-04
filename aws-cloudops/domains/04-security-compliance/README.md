# Domain 4 — Security and Compliance

**Exam weight:** 16% of scored content  
**Status:** Practiced — Phase 5 exit gate met on 2026-10-04; IAM-only lab cleaned up, independent verification plan demonstrated, broader domain coverage remains open\
**Official objective:** [AWS Domain 4 guide](https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain4.html) (scope checked 2026-10-03)

## What this domain is about

Apply and troubleshoot access controls, meet policy/compliance requirements, and protect data and infrastructure. Exam scenarios often require finding the correct control point—identity policy, resource policy, organization guardrail, network boundary, encryption configuration, or secrets service—and interpreting audit/security findings.

## Official task areas and study guides

| Official task | What to study | Task guide |
|---|---|---|
| **4.1 — Implement and manage security and compliance tools and policies** | IAM features, access auditing, multi-account controls, Trusted Advisor security checks, and continuous compliance monitoring. | [Security and compliance tools](01-task-4-1-security-compliance-tools.md) |
| **4.2 — Implement strategies to protect data and infrastructure** | Data classification, encryption at rest/in transit, secret storage, and findings from security services such as Security Hub, GuardDuty, Config, and Inspector. | [Data and infrastructure protection](02-task-4-2-data-infrastructure-protection.md) |

Use the [Domain 4 contexts index](contexts/README.md) for reusable scenarios, the graph-native [AWS IAM node](../../knowledge/services/iam/README.md), and the existing [imported IAM notes](../../knowledge/services/13-security-identity-compliance/01-iam/README.md) for additional service detail. The task guides provide practice and checks; learner results remain in the progress notes below and [`PROGRESS.md`](../../../PROGRESS.md).

The [IAM service note](../../knowledge/services/iam/README.md#permissions-boundaries-and-effective-permissions) covers boundary/SCP scope and implicit versus explicit deny, with [simulator/live evidence](../../knowledge/services/iam/README.md#simulator-evidence-and-verification). Today's other service-specific distinctions are in [IAM role credentials](../../knowledge/services/iam/README.md#roles-sts-and-the-credentials-actually-used), [S3 endpoint/HTTPS controls](../../knowledge/services/s3/README.md#authorization-and-request-context), and [KMS service-mediated decrypt](../../knowledge/services/kms/README.md#s3-mediated-decrypt-versus-a-direct-kms-call).

## Services

The service list follows the [official Domain 4 objectives](https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain4.html); examples are exam-scope coverage, not an exhaustive AWS catalog.

- **Identity and governance:** [AWS Identity and Access Management (IAM)](../../knowledge/services/iam/README.md), [AWS CloudTrail](../../knowledge/services/cloudtrail/README.md), [IAM Access Analyzer](../../knowledge/services/access-analyzer/README.md), IAM policy simulator, [AWS Organizations and service control policies (SCPs)](../../knowledge/services/organizations/README.md), IAM Identity Center, and AWS Trusted Advisor.
- **Compliance and findings:** [AWS Config](../../knowledge/services/config/README.md) (including conformance packs), [AWS Security Hub](../../knowledge/services/securityhub/README.md), [Amazon GuardDuty](../../knowledge/services/guardduty/README.md), [Amazon Inspector](../../knowledge/services/inspector/README.md), and AWS Security Agent.
- **Data and infrastructure protection:** [AWS Key Management Service (AWS KMS)](../../knowledge/services/kms/README.md), AWS Certificate Manager (ACM), and AWS secret-storage services such as [AWS Secrets Manager](../../knowledge/services/secretsmanager/README.md) and Systems Manager Parameter Store.

### Cross-service impacts

IAM roles and policies constrain provisioning and operational automation (see [Domain 3](../03-deployment-provisioning-automation/README.md)); CloudTrail, Config, and security findings feed monitoring and remediation workflows (see [Domain 1](../01-monitoring-logging-analysis-remediation-performance-optimization/README.md)). Encryption and secret access affect storage, databases, backups, and recovery (see [Domain 2](../02-reliability-business-continuity/README.md)); WAF, Shield, DNS Firewall, and Network Firewall connect security choices to network paths (see [Domain 5](../05-networking-content-delivery/README.md)). The effective result depends on the specific identity, resource, organization, and network policies—not merely on enabling a security service.

## Learning targets

- Diagnose access by separating identity-based permissions, resource policies, session/organization boundaries, and explicit denies.
- Choose least-privilege roles and understand federation and temporary credentials.
- Explain KMS encryption, TLS, secrets handling, and the difference between encryption and authorization.
- Treat findings as evidence to investigate, not automatic proof of exploitability or compliance.

## Practice and evidence

- **CLI:** inspect identity, policy/configuration, and audit evidence with read-only commands first.
- **Console:** trace a finding or access-denied event to the relevant principal, policy, resource, and context.
- **IaC:** express a narrowly scoped role/policy or encryption setting in a disposable lab; avoid touching existing production resources.
- **Demonstrated when:** independently locate the effective permission boundary in a new access scenario and propose a least-privilege correction with verification.

### Progress notes

- Status: Practiced — five original scenarios reviewed; IAM-only lab evaluation, learner Console inspection and cleanup complete. Final endpoint-migration response correctly supplies five explicit role-specific test expectations. Phase 5 exit gate met on 2026-10-04; broader Domain 4 mastery not established. Controlled lab model and actual results remain distinguished.
- Questions/practice evidence (2026-10-03): 4/4. Correctly applied explicit-deny precedence, the `AccessDenied` investigation sequence, Secrets Manager for runtime secrets, and CloudTrail for AWS API audit history.
- Explicit-deny evaluation (2026-10-03): Correctly concluded that an SCP explicit deny of `s3:GetObject` on `*` overrides an EC2 role identity-policy allow for `reports/*`. This supports the baseline finding; continue with permissions boundaries and resource-policy interactions.
- Permissions-boundary evaluation (2026-10-03): Correctly concluded that a boundary allowing only `s3:GetObject` blocks an identity-policy `s3:PutObject` allow. Future Domain 4 practice should use operational, multi-control scenarios rather than single-rule recall.
- Next action: Today's Domain 4 block is complete. Resume [Domain 1 monitoring and investigation](../01-monitoring-logging-analysis-remediation-performance-optimization/README.md) on October 5 with metrics-versus-logs signal selection. Retain Domain 4 reinforcement for October 22–25; [Lab 03](../../knowledge/labs/03-iam-policy-evaluation/README.md) IAM resources are cleaned up, IaC recreation and supplemental KMS work remain unperformed.

#### 2026-10-04 — Phase 5 exit gate met: independent verification plan

- Learner correctly preserves the scoped bucket-policy correction accepting both V1/V2 and rejects broader KMS grants. Five tests explicitly name `ReportsRole`, request path/action, expected outcome and interpretation: HTTPS V2/K2 succeeds; HTTP V2/K2 is denied; direct K2 decrypt and encrypt are denied; old HTTPS V1/K1 still succeeds. Correctly distinguishes expected `kms:ViaService` direct-decrypt denial from the production S3 blocker. [AWS KMS condition](https://docs.aws.amazon.com/kms/latest/developerguide/conditions-kms.html#conditions-kms-via-service).
- Tutor adds an unapproved-endpoint/no-endpoint HTTPS negative check, expected denied; that extra check is not learner-selected evidence. [AWS endpoint restrictions](https://docs.aws.amazon.com/AmazonS3/latest/userguide/example-bucket-policies-vpc-endpoint.html).
- Original scenarios 5/5 reviewed; final exit check complete, 0 remaining today. Phase 5 `done`, Domain 4 Practiced rather than whole-domain mastery. These are independently stated test expectations in a paper scenario, not executed AWS tests. No AWS changes or additional resources; next scheduled session is Domain 1 on October 5.

#### 2026-10-04 — Final exit check: endpoint-migration diagnosis

- Learner correctly proposed changing the bucket policy to also permit V2, retaining V1, rather than broadening KMS permissions. Tutor clarified that the change belongs in the existing deny-condition exception; the learner's shorthand is not evidence of a policy-syntax mistake.
- Original scenarios 5/5 reviewed; final exit check diagnosis/correction correct, verification plan unanswered. Phase 5 remains pending for that evidence. No AWS mutation or whole-domain mastery claim.

#### 2026-10-04 — Exact IAM-only cleanup verified

- Assistant reverified identity, lab tags, expected dependencies and unshared policy use; zero EC2 profile associations and profile-backed instances in `eu-north-1`. An Organizations deny blocked cross-region inspection, so no global EC2 absence claim is made. The known creation scope was IAM-only.
- Deleted only the exact role, profile and two custom policies, including boundary versions v1/v2; AWS-managed SSM policy was detached, not deleted. Four exact readbacks returned `NoSuchEntity`. No KMS or Organizations mutations; scripts unchanged. See [cleanup evidence](../../knowledge/labs/03-iam-policy-evaluation/EVIDENCE.md#teardown).
- Original scenarios 5/5 reviewed; IAM-only lifecycle complete. Phase 5 remains pending for independent verification expectations, not resource cleanup; assistant deletion is not new mastery evidence.

#### 2026-10-04 — Scoped-boundary Console confirmation

- Learner screenshot confirms boundary set to `soa-c03-lab03-boundary` with `AllowBucketInventory` allowing only `s3:ListAllMyBuckets` on `*`. This matches the tested configuration; the screenshot does not establish the version number. Its old "permits no actions" description is stale.
- Console inspection complete; original scenarios 5/5 reviewed, cleanup pending. No AWS changes or new mastery claim. Sanitized observation recorded in [Lab evidence](../../knowledge/labs/03-iam-policy-evaluation/EVIDENCE.md).

#### 2026-10-04 — Lab 03 scoped-boundary verification

- Assistant applied the reviewed scoped boundary as default version `v2` and attached it to the disposable role, retaining nondefault `v1`. Fresh role-session identity `True` and bucket count `0` confirm listing remains successful; principal simulation agrees with boundary coverage.
- Controlled supplied-policy model: both bucket listing and `ssm:ListAssociations` allowed without a boundary; with the scoped boundary, S3 allowed and SSM `implicitDeny` / boundary coverage false. The boundary limits existing grants rather than granting permissions itself. [AWS permissions boundaries](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_boundaries.html).
- Live SSM simulation reports `explicitDeny` and `AllowedByOrganizations: false` both before and after boundary restoration; it cannot isolate the new boundary's effect. No specific SCP inspected or account-level control changed. See [Lab evidence](../../knowledge/labs/03-iam-policy-evaluation/EVIDENCE.md).
- Original scenarios 5/5 reviewed; scoped test complete, learner Console inspection and cleanup pending. Assistant execution is operational evidence, not independent learner mastery. No scripts changed or sensitive output retained.

#### 2026-10-04 — Lab 03 positive verification and simulator comparison

- Learner reports `True` and `0`: lab-role identity confirmed, successful account bucket listing with empty inventory. Console screenshot confirms boundary association removed; S3-deny attachment absent, inline allow and SSM retained.
- Assistant read-only API checks confirm no boundary and no S3-deny attachment; current principal simulation returns `allowed` for `s3:ListAllMyBuckets`, matching the successful request. Original denied-baseline principal simulation remains unobserved. Evidence distinguishes learner-reported CLI output from Console and assistant API observations.
- Three live configurations verified; original scenarios 5/5 reviewed. Scoped-boundary test and cleanup pending; no assistant mutation, script change, sensitive identifier retention or broad mastery claim.

#### 2026-10-04 — Lab 03 boundary-denial test

- Learner correctly identifies the next blocker: real-role identity `True`, `ListBuckets` denied explicitly by `soa-c03-lab03-boundary`. Console confirms S3-deny attachment removed, inline allow and SSM attachment retained, boundary still set.
- Assistant read-only API verification resolves the Console's `{}` display: default boundary document still explicitly denies all actions/resources; only SSM remains as an attached managed policy. No AWS mutation; identifiers and raw screenshots not retained. See [Lab evidence](../../knowledge/labs/03-iam-policy-evaluation/EVIDENCE.md).
- Original scenarios 5/5 reviewed; two real denial configurations confirmed. Positive verification, live-role baseline simulator comparison and cleanup pending; no broad mastery claim.

#### 2026-10-04 — Lab 03 real-role denied baseline

- Learner screenshot confirms lab-role identity check `True` and actual `s3:ListAllMyBuckets` denial. Error names identity-based `soa-c03-lab03-explicit-deny`; role assumption and credential handoff worked. Sanitized details are in [Lab 03 evidence](../../knowledge/labs/03-iam-policy-evaluation/EVIDENCE.md).
- A denial message can report only one reason when several apply; this does not establish the boundary is absent or ineffective. [Official S3 diagnostics](https://docs.aws.amazon.com/AmazonS3/latest/userguide/troubleshoot-403-errors.html). Next test isolates a layer; no new recall question.
- Original scenarios 5/5 reviewed; real-role denied baseline complete. Live-role baseline simulation, remediation verification and cleanup pending. No credentials, identifiers or raw screenshot retained; no assistant AWS mutation or broad mastery claim.

#### 2026-10-04 — Lab 03 AssumeRole screenshot diagnosis

- Learner screenshots establish source-profile bucket listing succeeded with empty inventory and lab-role `sts assume-role` succeeded. Passing `--role-session-name` to `s3api list-buckets` failed local argument validation; this was not an AWS authorization denial.
- Tutor separated successful session issuance from using that session for S3. No assumed-role S3 request outcome is established. Next verification uses fresh temporary credentials without displaying or persisting them; no policy or trust-policy modification justified by the screenshots.
- Only sanitized observations retained; no credentials, identifiers or screenshot contents saved. No assistant AWS calls. Original scenarios 5/5 reviewed; real-role S3 verification and cleanup pending.

#### 2026-10-04 — Lab 03 final prediction and difficulty correction

- Correctly predicted account bucket listing is permitted with both deny layers removed, inline `allow-s3-list` retained and no other applicable restrictions. The permission is for `s3:ListAllMyBuckets`, not blanket S3 access. No API outcome was tested.
- Learner requested more challenging SOA-C03 practice; tutor accepted that repeated single-rule questions were insufficient. Close elementary predictions and return to operational investigation, interacting controls, least-privilege remediation and verification. No personal background information retained.
- Original scenarios 5/5 reviewed; elementary lab predictions complete. Real-role simulation/request verification and IAM-only cleanup remain pending; Domain 4 Practiced, Phase 5 pending.

#### 2026-10-04 — Lab 03 boundary-only removal prediction

- Correctly predicted that removing only the boundary from the original configuration does not permit `s3:ListAllMyBuckets`: the retained `soa-c03-lab03-explicit-deny` has `Deny s3:*`, which overrides the inline allow.
- Prediction and reasoning observed; no AWS test or mutation and no broad mastery claim. Original scenario block remains 5/5 reviewed; real-role testing and cleanup pending. Final guided contrast removes both deny layers while retaining the inline allow and assuming no other applicable restrictions.

#### 2026-10-04 — Lab 03 policy-reference clarification

- Valid learner objection: a policy no longer applied to the role cannot continue blocking it. The tutor's hypothetical removed `soa-c03-lab03-explicit-deny`, not the different policy `soa-c03-lab03-boundary` set in the separate permissions-boundary field.
- Resolved: learner correctly noted that the question had explicitly named the detached policy; the tutor's claim of an unclear policy reference was inconsistent. Future questions must state exact action, starting configuration, removed layer and retained layers.
- Correct guided teach-back after explanation: `s3:ListAllMyBuckets` remains denied after removing only the S3-deny attachment because the retained boundary denies any action on any resource. No independent-mastery claim, new AWS test or mutation; real-role testing and cleanup remain pending, prior scenario block 5/5 reviewed.

#### 2026-10-04 — Lab 03 first what-if simulation

- Learner asked a valid scope question: account buckets versus objects inside a bucket. Tutor clarified `s3:ListAllMyBuckets` versus `s3:ListBucket`; vague “listing” wording was the tutor's framing issue.
- Predicted success after removing only the attached S3 deny, correctly identifying the inline allow. Tutor corrected effective access: the unchanged deny-all boundary is independently sufficient to block the action.
- Read-only `SimulateCustomPolicy` with inline allow plus deny-all boundary, excluding the separate S3 deny, returned `explicitDeny` and boundary allow `false`. This is a supplied-document model, not a live role test. Prediction and model evidence are kept separately in [Lab 03 evidence](../../knowledge/labs/03-iam-policy-evaluation/EVIDENCE.md).
- No policies were detached, no role assumed and no S3 call made. Real-role testing and IAM-only cleanup remain pending; Domain 4 Practiced, Phase 5 pending; prior scenario block 5/5 complete.

#### 2026-10-04 — Lab 03 Console inspection

- Learner supplied a redacted screenshot confirming the inline S3-list allow, attached S3 explicit deny, original SSM policy attachment and set deny-all boundary on `soa-c03-lab03-role`. See [Lab 03 evidence](../../knowledge/labs/03-iam-policy-evaluation/EVIDENCE.md). No account identifiers or authentication details are retained.
- Correctly recognized the boundary's permission-ceiling purpose and proposed an SCP-like analogy for a specific role. The tutor clarified the analogy's scope and explained controlled delegation; independent recall of the no-grant rule and practical purpose remains unassessed. Asking for the missing rationale is not a learner mistake.
- Console inspection complete; no simulator, role assumption, S3 action test or policy change was performed in this turn. Predictions, evaluation and IAM-only cleanup remain pending; Domain 4 Practiced, Phase 5 pending; prior scenario block 5/5 complete.

#### 2026-10-04 — Lab 03 personal-account setup

- Learner explicitly authorized the personal account for IAM-only setup using `personal-cloudops-lab` in `eu-north-1`. Account and empty lab-prefixed IAM listings were re-verified before creation; no account identifiers or authentication details are retained.
- The assistant ran the existing creation script unchanged and verified the resulting `soa-c03-lab03-role`, `soa-c03-lab03-role-profile`, boundary policy and explicit-deny policy. Read-back confirmed the inline S3-list allow, attached S3 deny, deny-all boundary, original SSM policy attachment, lab tags and instance-profile membership.
- Four disposable IAM resources remain for the exercise; no compute, buckets or KMS keys were created and no existing workload was changed. Cleanup is pending and must stay IAM-only with exact targets, excluding the teardown script's KMS-deletion section.
- Setup is complete, not the lab or a learner mastery assessment. Console inspection, predictions, policy evaluation and cleanup remain pending; the evaluator's separate simulator-argument issue remains unresolved. Domain 4 stays Practiced, Phase 5 pending; scenario block 5/5 complete, 0 remaining.

#### 2026-10-04 — Lab 03 setup retry

- Re-verified the new playground `ApptweakAdmin` identity. All three lab-prefixed IAM listings succeeded and were empty before setup.
- The existing creation script failed on its first write: `iam:CreatePolicy` for `soa-c03-lab03-boundary`, because no identity-based policy allows the action. This is the caller's provisioning permission failure, not a denial from a lab role or boundary already in place.
- Post-failure listings confirmed no lab roles, policies or instance profiles. No lab resources were created and no SSO permissions were changed. Policy evaluation remains unexecuted; Domain 4 stays Practiced and Phase 5 pending. These are assistant-observed operational results, not new learner mastery evidence.

#### 2026-10-04 — New study profile verified by the learner

- Configured `sso-apptweakplayground-apptweakadmin` and shared successful SSO login and STS identity output confirming `ApptweakAdmin` in the intended playground account. This is the study profile to use going forward; the previous profile remains unchanged.
- Identity is verified; IAM permissions still need read-only checks. No lab resource creation or policy evaluation is inferred from the login. Domain 4 remains Practiced and Phase 5 pending; the five-scenario block remains complete.

#### 2026-10-04 — Lab 03 preflight

- Confirmed playground caller identity; no lab-prefixed roles appeared in `ListRoles`. Policy/profile listing and exact-name inspection returned `AccessDenied` because the corresponding identity-policy allows were missing. Their existence remains unverified.
- No AWS resources were created or changed. Preparation started, but hands-on policy evaluation has not run; Domain 4 remains Practiced and Phase 5 pending. The requested session-name fix is in place; the separate simulator argument issue remains unresolved.
- Resume after an authorized lab profile with sufficient scoped IAM permissions is confirmed. This is operational preflight evidence, not a learner assessment or lab completion.

#### 2026-10-04 — S3/KMS access-control block

- **Progress:** 5/5 scenarios reviewed, 0 remaining; four guided cases followed by one independent combined case. This is block completion, not a perfect score. Lab 03 is not started; no AWS tests or changes were performed.
- **Terminology:** After explanation, correctly identified customer-managed key administration. The initial unfamiliar term reflected a tutor sequencing issue, not a learner misconception. See the canonical [KMS notes](../../knowledge/services/kms/README.md).
- **Boundary mismatch:** Correctly proposed extending K2 decryption coverage and keeping encryption denied; the tutor specified the boundary as the correction target and added actual S3 download verification.
- **Key-policy investigation:** Correctly chose the key policy as the next check when identity and boundary permissions were sufficient. This was a diagnostic hypothesis, not a confirmed root cause.
- **Transport restriction:** Correctly identified HTTP as the blocked request context and HTTPS as the fix. The tutor supplied the missing HTTP-denial negative test.
- **Cross-account case:** Correctly proposed adding `kms:Decrypt` to the caller role IAM policy and an encryption test. The tutor corrected unnecessary key-policy modification because its permission was already established, scoped the IAM allow to K3's full key ARN, and specified expected test outcomes.
- **Independent combined case:** Correctly separated the HTTP restriction and K2 boundary gap, proposed HTTPS plus a scoped boundary correction, and selected HTTPS/HTTP/encryption tests. The tutor completed expected success/denial outcomes and added the K1 regression check. Fix order was not scored as a mistake.
- **Evidence limits:** One independent combined diagnosis is evidence of applying the taught rules, not whole-domain mastery. Verification completeness and hands-on evidence remain follow-ups; learner-proposed tests are not executed results.
- **Tutor process:** Reconciled this README and [PROGRESS.md](../../../PROGRESS.md) after the learner pointed out the missing repository updates. Keep both current during active tutoring and show the finite block counter before subsequent scenarios.
