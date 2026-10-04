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

## Common confusion

- **Common mistake** — An identity-policy `Allow` is sufficient for access.
- **Actual AWS behavior** — Explicit denies override allows, and permissions boundaries plus applicable organization policies can limit a principal's permissions. [IAM policy evaluation logic](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_evaluation-logic.html)
- **Why it matters** — Domain 4 access investigations require locating the effective permission boundary rather than adding broader permissions.

> [!IMPORTANT]
> **Effective IAM permissions** are constrained by explicit denies, permissions boundaries, and applicable organization policies. For SOA-C03 Domain 4, treating an identity-policy allow as decisive risks granting broader access while leaving the actual denial unresolved.

## Exam mapping

- [Domain 4, Task 4.1](../../../domains/04-security-compliance/README.md) covers IAM features, access troubleshooting, and multi-account controls. The [imported IAM notes](../13-security-identity-compliance/01-iam/README.md) remain a separate, upstream-authored reference.
