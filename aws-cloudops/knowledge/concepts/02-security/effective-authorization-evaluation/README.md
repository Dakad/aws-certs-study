---
id: "effective-authorization-evaluation"
kind: "concept"
domains: [4]
related:
  - relation: "commonly-used-with"
    target: "iam"
  - relation: "commonly-used-with"
    target: "organizations"
  - relation: "commonly-used-with"
    target: "kms"
  - relation: "troubleshoots-with"
    target: "cloudtrail"
  - relation: "commonly-used-with"
    target: "s3"
sources:
  - title: "IAM policy evaluation logic"
    url: "https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_evaluation-logic.html"
  - title: "Permissions boundaries for IAM entities"
    url: "https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_boundaries.html"
  - title: "Service control policies"
    url: "https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_scps.html"
  - title: "Key policies in AWS KMS"
    url: "https://docs.aws.amazon.com/kms/latest/developerguide/key-policies.html"
  - title: "Allowing users in other accounts to use a KMS key"
    url: "https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-modifying-external-accounts.html"
  - title: "Protecting data in transit with encryption"
    url: "https://docs.aws.amazon.com/AmazonS3/latest/userguide/UsingEncryptionInTransit.html"
  - title: "SOA-C03 Domain 4: Security and Compliance"
    url: "https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain4.html"
last_verified: 2026-10-04
---

# Effective authorization evaluation

## In one paragraph

Effective authorization is the result for one request, not the text of one policy. Identify the principal, action, resource, owning account, and request context; then determine which policy types apply. An applicable explicit `Deny` ends the request. For an IAM-policy authorization path, verify the applicable permissions boundary and SCP; separately evaluate resource-policy conditions and, for KMS operations, the key policy or grant path. [IAM policy evaluation logic](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_evaluation-logic.html)

> [!IMPORTANT]
> **Authorization is request-specific.** For SOA-C03 Domain 4, an identity-policy `Allow` does not establish that a request succeeds: transport conditions, boundaries, SCPs, resource policies, and KMS controls can still block it. Changing the first policy that contains an `Allow` risks widening access without fixing the failed request.

## Reusable evaluation path

1. Establish the request: actual caller or role session, action, resource ARN, resource-owner account, and context such as TLS, source, tag, or encryption context.
2. Check every applicable explicit `Deny`. A bucket policy that denies requests where `aws:SecureTransport` is `false`, for example, blocks HTTP independently of S3, IAM, or KMS allows. [Protecting data in transit with encryption](https://docs.aws.amazon.com/AmazonS3/latest/userguide/UsingEncryptionInTransit.html)
3. Identify an authorization path. Identity policies may allow a principal; a resource policy may also allow access when its principal and conditions match. Neither is a universal override for the other policy types. [IAM policy evaluation logic](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_evaluation-logic.html)
4. Apply ceilings to IAM-based access. A permissions boundary limits what an IAM identity policy can grant; it does not grant access. An SCP limits permissions for member-account IAM users and roles; it also does not grant access. [Permissions boundaries for IAM entities](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_boundaries.html), [Service control policies](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_scps.html)
5. For a KMS action, evaluate the key's own authorization. In the same account, a key policy can directly allow the caller or enable IAM delegation, and a grant can supply an allow path. Across accounts, policy-based key use needs an owner-account key-policy allow and a caller-account IAM allow; a grant is an alternative path, not evidence that both policy-side allows exist. [Key policies in AWS KMS](https://docs.aws.amazon.com/kms/latest/developerguide/key-policies.html), [Allowing users in other accounts to use a KMS key](https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-modifying-external-accounts.html)

This is an investigation order, not a claim about AWS's internal evaluation sequence. It prevents the common error of treating every `AccessDenied` as an IAM-policy omission.

## Worked reasoning

An application role downloads an SSE-KMS S3 report. Its identity policy permits `s3:GetObject` and `kms:Decrypt`, but the request uses HTTP and the role boundary omits the report key ARN.

- The HTTP request is denied by the transport guardrail. Switching to HTTPS is necessary, but it does not change the boundary.
- The HTTPS request reaches the remaining KMS authorization check and still fails because the IAM-delegation path lacks boundary coverage for that key.
- The scoped correction is to retain the transport deny and add only `kms:Decrypt` for the required key ARN to the boundary, after confirming that the key policy or grant path permits the role. Do not remove the boundary or add `kms:*`.

## Verification expectations

Use the application role and the original resource/context, then record the observed authorization result and relevant CloudTrail evidence.

- **Positive:** the intended HTTPS read of the intended KMS-encrypted object succeeds.
- **Negative:** HTTP remains denied; unrelated encryption or write actions remain denied.
- **Regression:** an already authorized read, such as one using a previously covered key, still succeeds.

For a cross-account KMS failure, first establish whether the owner key policy already permits the external principal. If it does, add the narrowly scoped caller-side IAM permission only when that is the missing control; do not modify both sides by default. [Allowing users in other accounts to use a KMS key](https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-modifying-external-accounts.html)

## Common confusion

- **Common mistake** — An `Allow` in an identity policy proves the request is authorized.
- **Actual AWS behavior** — Explicit denies override allows, while permissions boundaries and SCPs restrict what IAM policies can grant; resource-policy conditions and KMS key authorization can independently decide the request. [IAM policy evaluation logic](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_evaluation-logic.html), [Key policies in AWS KMS](https://docs.aws.amazon.com/kms/latest/developerguide/key-policies.html)
- **Why it matters** — Domain 4 access investigations require a scoped correction at the control that actually blocks the request, followed by positive, negative, and regression checks.

## Exam mapping

- [Domain 4: Security and Compliance](../../../../domains/04-security-compliance/README.md) — Task 4.1 access controls and multi-account guardrails; Task 4.2 transport protection, encryption, and KMS authorization.
