# Lab 03 evidence — IAM evaluation and verified cleanup

Status: **IAM-only evaluation, learner Console inspection and cleanup verified; all four exact IAM resources absent. Identity-denial, boundary-denial, successful bucket-list and restored scoped-boundary configurations recorded below. Original denied-baseline principal simulation was not observed; IaC recreation and supplemental KMS exercise were not performed.** No KMS resources created.

Redact account IDs to the last four characters. Never record ARNs in full or any
credential material.

## Session

- Date: 2026-10-04
- AWS profile used: `personal-cloudops-lab`
- Region: `eu-north-1`

## Console evidence

The learner shared a redacted screenshot of `soa-c03-lab03-role` showing:

- Inline `allow-s3-list`: `Allow` for `s3:ListAllMyBuckets` on `*`.
- Attached `soa-c03-lab03-explicit-deny`: `Deny` for `s3:*` on `*`.
- Attached `AmazonSSMManagedInstanceCore` policy.
- Set permissions boundary `soa-c03-lab03-boundary`: `Deny` for `*` on `*`.

This establishes the displayed configuration, not an API-test outcome. Subsequent screenshot evidence establishes the real-role denied baseline below; the earlier custom-policy what-if model remains a separate test. Account identifiers, full ARNs, credentials and raw screenshots are not retained here.

## Step 2 — Prediction before testing

With an inline `Allow` on `s3:ListAllMyBuckets`, an attached policy with an
explicit `Deny` on `s3:*`, and a boundary that denies everything, my prediction
for `s3:ListAllMyBuckets` is:

## Step 2 — Simulator vs reality

| | Result |
|---|---|
| Simulator `EvalDecision` |  |
| Matched statement source policy |  |
| Real call outcome | Lab-role identity check `True`; real `ListBuckets` call denied. |
| Error code / message shape | `AccessDenied` for `s3:ListAllMyBuckets`, explicit deny in identity-based policy `soa-c03-lab03-explicit-deny`. Identifiers omitted. |

Did the simulator match reality? If not, what did the simulator not know about?

The live-role baseline simulator has not been observed, so no baseline simulator/API equivalence is claimed. The S3 error names one policy reason; it does not establish whether other deny layers also apply. [AWS documents that multiple denial reasons can yield only one reported reason](https://docs.aws.amazon.com/AmazonS3/latest/userguide/troubleshoot-403-errors.html).

## Step 3 — Removing one layer at a time

The live sequence is cumulative: Step 2 below removes the boundary after the S3-deny attachment has already been removed in Step 1. Separate earlier hypotheticals starting from the original configuration are not substituted for this live sequence.

| Step | Layer removed | Predicted outcome | Actual outcome | Prediction correct? |
|---|---|---|---|---|
| 1 | explicit Deny detached | Initial: succeeds via `allow-s3-list`; after teaching, learner correctly explained the retained boundary denies it. | Identity check `True`; `AccessDenied` explicitly names `soa-c03-lab03-boundary`. | Initial prediction incorrect; subsequent corrected reasoning matches the real result. |
| 2 | boundary removed after S3 deny already detached | Learner correctly predicted success with both deny layers removed and inline allow retained, assuming no other restrictions. | Learner reports identity `True`, bucket count `0`; Console confirms boundary not set. Current principal simulator: `allowed`. | Correct for this tested action/configuration. |
| 3 | boundary reattached but scoped to allow bucket listing | No independent learner prediction recorded. | Assistant fresh role-session identity `True`, bucket count `0`; principal simulator S3 `allowed` / boundary coverage true. Controlled model SSM `implicitDeny`; live SSM separately Organizations-denied. | Assistant verification, not a scored learner prediction. |

The order that surprised me, and what it taught me about evaluation order:

### Read-only model of Step 3, first removal

- Exact action clarified: `s3:ListAllMyBuckets`, listing account buckets, not objects inside a bucket.
- Model inputs: inline `AllowS3List` allow plus the deny-all `NoPermissions` boundary; separate S3-deny policy deliberately omitted.
- Command type: `iam:SimulateCustomPolicy`, using `--policy-input-list` and `--permissions-boundary-policy-input-list` with the JSON documents shown in the Console.
- Observed result: `EvalDecision: explicitDeny`; `AllowedByPermissionsBoundary: false`.
- At the time of this model, no actual policy was detached, role assumed or S3 API called. The later real Step 3 result is recorded separately above; this model does not include every live account control.

### Subsequent real boundary-denial test

- Learner Console evidence confirms the S3-deny attachment removed, with inline allow, SSM attachment and boundary retained. Actual assumed-role S3 request returned explicit boundary denial, matching the earlier model's expected outcome.
- The Console's boundary JSON view displayed `{}`. Assistant read-only API checks verified the current default document is still `NoPermissions` / `Deny` / action `*` / resource `*`. Managed attachments contain only `AmazonSSMManagedInstanceCore`; no assistant policy mutation occurred.
- No account identifiers, full ARNs, credentials or raw screenshots retained. Subsequent boundary removal and positive verification are recorded below.

### Subsequent positive verification and current-role simulation

- Learner reports CLI identity `True` and bucket count `0`; the supplied Console screenshot shows boundary not set, inline S3-list allow and SSM attachment retained, S3 deny absent. The CLI result is user-reported, not displayed in that screenshot.
- Assistant read-only calls verify no boundary (`null`), only SSM managed attachment, and `SimulatePrincipalPolicy` / `s3:ListAllMyBuckets` result `allowed`. This compares the current role to current success; it does not fill the original denied-baseline simulation fields.
- No policy mutation by the assistant in that positive-verification turn; no identifiers or credentials retained. Subsequent scoped-boundary reattachment is recorded below; cleanup remains unexecuted.

### Scoped-boundary restoration and independent control model

- Starting state: S3-deny attachment absent, boundary association absent; inline bucket-list allow and AWS-managed SSM attachment retained. Assistant verified the boundary policy had no managed attachments or boundary users before changing it.
- After learner authorization and exact-command review, created default managed-policy version `v2` and attached the scoped boundary only to `soa-c03-lab03-role`. Version `v1` remains nondefault. Retrieved `v2` document and boundary association match the reviewed configuration:

```json
{"Version":"2012-10-17","Statement":[{"Sid":"AllowBucketInventory","Effect":"Allow","Action":"s3:ListAllMyBuckets","Resource":"*"}]}
```

- Assistant assumed a fresh role session without displaying or persisting temporary credentials: role-identity check `True`, real bucket-list count `0`. Principal simulator: S3 `allowed`, `AllowedByPermissionsBoundary: true`, `AllowedByOrganizations: true`.
- Independent `SimulateCustomPolicy` control: supplied identity policy allows both `s3:ListAllMyBuckets` and `ssm:ListAssociations` on `*`. Without a supplied boundary, both evaluate `allowed`. With the scoped boundary, S3 remains `allowed` / boundary coverage true; SSM becomes `implicitDeny` / boundary coverage false. This demonstrates the boundary intersection without relying on live account restrictions. [Custom-policy simulator](https://docs.aws.amazon.com/cli/latest/reference/iam/simulate-custom-policy.html), [permissions boundaries](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_boundaries.html).
- Live-role SSM simulation returned `explicitDeny`, no matched identity statements, and `AllowedByOrganizations: false` before boundary reattachment; afterward it still reports the Organizations denial, with boundary detail absent. No specific SCP was inspected, no Organizations control changed, and no actual SSM API test was run. The custom-policy model is not substituted for a live SSM test. [Principal-policy simulator](https://docs.aws.amazon.com/cli/latest/reference/iam/simulate-principal-policy.html).
- Scoped test is assistant-executed operational evidence, not new independent learner mastery. Next learner Console inspection confirms the scoped boundary before exact IAM-only cleanup. No compute, storage or KMS resources created; scripts unchanged.

### Subsequent scoped-boundary Console confirmation

- On 2026-10-04, learner screenshot confirms `soa-c03-lab03-boundary` is set, with `AllowBucketInventory` / `Allow` / `s3:ListAllMyBuckets` / resource `*`. This matches the policy tested above; version number is not visible in the screenshot.
- The description still says "permits no actions" from the original deny-all configuration. Record this as stale descriptive text, not contradictory policy JSON. No AWS mutation or raw screenshot retention this turn; exact IAM-only cleanup remains pending.

## Step 4 — KMS

Deferred to the separate data-protection lab; outside this session's agreed IAM-only resource scope. No KMS key or encrypted object was created or deleted.

Two-layer explanation of "the application cannot read the encrypted S3 object":

Evidence that distinguishes an S3 authorization failure from a KMS decryption failure:

## Teardown

On 2026-10-04, assistant performed the authorized exact-target IAM-only cleanup. The existing `cli/99-teardown.sh` was not run or edited because it includes prefix-wide targets and optional KMS deletion outside this cleanup scope.

- Preflight: intended identity verified; lab role/profile tags, expected inline/managed policies and sole profile membership confirmed. Boundary used only by the lab role; neither custom policy had managed attachments. `eu-north-1`: zero EC2 profile associations and zero instances using the profile. A broader regional inspection was blocked by an Organizations deny; no global usage-absence claim.
- Removed the role from its exact instance profile, deleted that profile, removed inline `allow-s3-list`, detached AWS-managed SSM without deleting it, removed the boundary association and deleted the role. Deleted boundary nondefault v1 before deleting boundary/default v2, then deleted explicit-deny/default v1. [IAM role deletion requirements](https://docs.aws.amazon.com/cli/latest/reference/iam/delete-role.html), [managed-policy deletion requirements](https://docs.aws.amazon.com/cli/latest/reference/iam/delete-policy.html).
- Final exact readbacks, not inferred from successful delete exit codes:

```text
role absent: NoSuchEntity
instance-profile absent: NoSuchEntity
boundary-policy absent: NoSuchEntity
explicit-deny-policy absent: NoSuchEntity
clean: all four exact IAM lab resources absent
```

No KMS or Organizations mutations, unrelated deletions, script edits or sensitive output retained. Cleanup is operational evidence, not an independent learner assessment.

## Surprises
