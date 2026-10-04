---
id: "iam"
kind: "service"
domains: [4]
services: ["iam"]
sources:
  - title: "What is IAM?"
    url: "https://docs.aws.amazon.com/IAM/latest/UserGuide/introduction.html"
  - title: "IAM policy evaluation logic"
    url: "https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_evaluation-logic.html"
  - title: "Permissions boundaries for IAM entities"
    url: "https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_boundaries.html"
  - title: "IAM policy testing with the IAM policy simulator"
    url: "https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_testing-policies.html"
  - title: "AssumeRole command reference"
    url: "https://docs.aws.amazon.com/cli/latest/reference/sts/assume-role.html"
  - title: "Using an IAM role in the AWS CLI"
    url: "https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-role.html"
  - title: "SOA-C03 Domain 4"
    url: "https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain4.html"
last_verified: 2026-10-04
---

# AWS Identity and Access Management (IAM)

## In one paragraph

IAM controls authentication and authorization for AWS requests. It defines principals and applies policies to decide which actions they may perform on which resources; the result depends on the request context and every applicable policy type, not only an identity policy.

## Behavior and boundaries

- IAM evaluates applicable identity-based and resource-based policies; an explicit `Deny` overrides an `Allow`. Permissions boundaries and organization policies can further constrain effective permissions.
- IAM changes are eventually consistent. Do not place a just-created or changed principal or policy on a critical application path without allowing for propagation.

## Operational signals

- For an `AccessDenied` response, identify the principal, requested action, resource, and request context, then test for an explicit deny or a boundary that excludes the action. This establishes the authorization decision, not an application fault.

## Permissions boundaries and effective permissions

A boundary is a managed policy assigned separately to an IAM user or role. It limits identity-policy grants; it grants nothing itself. Under this path, both identity and boundary must allow the action/resource, subject to other restrictions. A missing boundary allow is an implicit deny; a matching `Deny` is explicit. Detaching an ordinary deny policy leaves the boundary association unchanged. [AWS boundary rules](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_boundaries.html)

Calling it an “SCP for one role” describes a ceiling, not the implementation: a boundary is assigned to a user/role, while [Organizations SCPs](../organizations/README.md#behavior-and-boundaries) have root/OU/account scope. Neither grants access.

Boundaries support delegated permission management. A team can manage identity grants within an approved ceiling; require the boundary during creation and protect its policy and association against unauthorized changes/removal. Otherwise the delegate could change the ceiling. [AWS delegation example](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_boundaries.html)

Do not generalize the intersection to every resource-policy principal: same-account grants directly to role-session ARNs bypass implicit identity/boundary/session denies. Role-ARN grants remain limited by boundary/session implicit denies. Applicable explicit denies still win. [AWS principal-specific evaluation](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_boundaries.html)

In the [disposable IAM lab](../../labs/03-iam-policy-evaluation/README.md), the inline bucket-inventory allow cannot override either the attached S3 deny or deny-all boundary. Detach only the S3 deny and the boundary still blocks listing; remove both and the inline allow can apply, assuming no other restrictions. Restore a boundary allowing only inventory and that action remains available while other identity-granted actions outside the ceiling are denied. This illustrates evaluation, not a recommendation to remove production guardrails. Correct the narrow missing permission instead. [IAM evaluation](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_evaluation-logic.html)

## Simulator evidence and verification

A simulator evaluates selected policies and supplied context, not a live service request. Custom mode can isolate one control; principal mode uses the selected identity's policies. Confirm the intended result with the actual role and request path rather than substituting simulated `allowed` for application success. [AWS simulator limitations](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_testing-policies.html)

Operational practice: define principal, action/resource, path/context, expected outcome, and what each test establishes before running it. Include restored-path positives, retained-guardrail negatives, and old-path regressions. A direct KMS call is not equivalent to [S3-mediated decryption](../kms/README.md#s3-mediated-decrypt-versus-a-direct-kms-call). Learner results remain in the domain/progress record, not inferred from these expectations.

## Roles, STS, and the credentials actually used

`aws sts assume-role` returns temporary credentials for a role session. `--role-session-name` belongs to that operation, not to `s3api list-buckets`. Receiving credentials does not switch later commands to the role: calls using the original source profile still use that profile's credential configuration. [AssumeRole](https://docs.aws.amazon.com/cli/latest/reference/sts/assume-role.html)

Use the returned credentials in a scoped process, or configure a separate role profile with `role_arn`, `source_profile`, and `role_session_name`. The CLI then assumes the role when that role profile is selected. Verify `sts get-caller-identity` under the same credential setup used for the test; look for the intended assumed role, not merely a successful response. Never print or commit its credential values. [AWS CLI role profiles](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-role.html)

The [IAM evaluation lab](../../labs/03-iam-policy-evaluation/README.md) supplies the disposable worked sequence and its recorded evidence.

## Common confusion

- **Common mistake** — An identity-policy `Allow` is sufficient for access.
- **Actual AWS behavior** — Explicit denies override allows, and permissions boundaries plus applicable organization policies can limit a principal's permissions. [IAM policy evaluation logic](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_evaluation-logic.html)
- **Why it matters** — Domain 4 access investigations require locating the effective permission boundary rather than adding broader permissions.

> [!IMPORTANT]
> **Effective IAM permissions** are constrained by explicit denies, permissions boundaries, and applicable organization policies. For SOA-C03 Domain 4, treating an identity-policy allow as decisive risks granting broader access while leaving the actual denial unresolved.

## Exam mapping

- [Domain 4, Task 4.1](../../../domains/04-security-compliance/README.md) covers IAM features, access troubleshooting, and multi-account controls. The [imported IAM notes](../13-security-identity-compliance/01-iam/README.md) remain a separate, upstream-authored reference.
