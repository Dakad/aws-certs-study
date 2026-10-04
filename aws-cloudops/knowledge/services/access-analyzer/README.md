---
id: "access-analyzer"
kind: "service"
domains: [4]
services: ["access-analyzer"]
related:
  - relation: "secured-by"
    target: "iam"
  - relation: "integrates-with"
    target: "organizations"
  - relation: "integrates-with"
    target: "cloudtrail"
sources:
  - title: "IAM Access Analyzer User Guide"
    url: "https://docs.aws.amazon.com/IAM/latest/UserGuide/what-is-access-analyzer.html"
  - title: "Delegated administrator for IAM Access Analyzer"
    url: "https://docs.aws.amazon.com/IAM/latest/UserGuide/access-analyzer-delegated-administrator.html"
  - title: "IAM Access Analyzer findings"
    url: "https://docs.aws.amazon.com/IAM/latest/UserGuide/access-analyzer-findings.html"
  - title: "Archive IAM Access Analyzer findings"
    url: "https://docs.aws.amazon.com/IAM/latest/UserGuide/access-analyzer-findings-archive.html"
  - title: "Resolve IAM Access Analyzer findings"
    url: "https://docs.aws.amazon.com/IAM/latest/UserGuide/access-analyzer-findings-remediate.html"
  - title: "Validate policies with IAM Access Analyzer"
    url: "https://docs.aws.amazon.com/IAM/latest/UserGuide/access-analyzer-policy-validation.html"
  - title: "IAM Access Analyzer quotas"
    url: "https://docs.aws.amazon.com/IAM/latest/UserGuide/access-analyzer-quotas.html"
last_verified: 2026-10-04
---

# IAM Access Analyzer

## In one paragraph

IAM Access Analyzer uses automated reasoning to identify external access to supported resources, internal access to selected resources, and unused access for IAM users and roles. It also validates IAM policies against policy grammar and AWS best practices.

> [!IMPORTANT]
> **Archiving is not access remediation.** For SOA-C03 Domain 4 access-auditing decisions, remove the policy or permission that grants unintended access; treating an archive action as a fix leaves that access in place.

## Behavior and boundaries

- **External access analyzers**: Identify supported resources shared with principals outside an account or organization zone of trust.
- **Internal access analyzers**: Identify possible access paths from principals in an account or organization to selected business-critical resources.
- **Unused access analyzers**: Identify unused roles, IAM user credentials, and service- or action-level permissions based on access activity.
- **Organization analyzers**: An organization analyzer can be managed by the management account or an IAM Access Analyzer delegated administrator. The management account designates the delegated administrator.
- **Supported resources**: External and internal analysis cover supported resource types only, and their support differs by analyzer type. Unused-access analysis applies to IAM users and roles.
- **Policy validation**: Basic policy validation reports errors, security warnings, general warnings, and suggestions. It does not report unused permissions.
- **Custom policy checks**: Paid checks can assert that a proposed policy grants no new access, does not grant specified access, or cannot grant public access to a specified resource type.

## Operational signals

- **Findings console**: Filter findings by analyzer, resource, principal, and status.
- **Finding details**: Includes `action`, `condition`, `isPublic`, `principal`, `resource`, `resourceType`, `createdAt`, `updatedAt`.
- **Policy validation API**: `ValidatePolicy` returns validation findings for a policy document.
- **Archive versus resolve**: Archiving marks an expected finding as not active; it neither changes nor removes the access. To resolve an access finding, remove the access from the relevant policy or permission. A subsequent analysis changes the finding to `Resolved` when the access is gone.

## Policy validation categories (exam-relevant)

| Category | What it catches | Example |
|----------|-----------------|---------|
| **Error** | Policy issues that prevent a policy from functioning | Malformed ARN |
| **Security warning** | Access AWS considers a security risk because it is overly permissive | `"Action": "*", "Resource": "*"` |
| **Warning** | Best-practice issue that is not a security risk | Policy does not conform to a recommended practice |
| **Suggestion** | Recommended improvement that does not change permissions | A policy can be made clearer or more maintainable |

## Common confusion

**Common mistake** — An archived access finding means the external or internal access has been remediated.

**Actual AWS behavior** — Archiving clears a finding from the active list but does not delete it or change the underlying permission; remove the access to resolve it. [AWS documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/access-analyzer-findings-remediate.html)

**Why it matters** — Domain 4 Task 4.1 requires access auditing and least-privilege validation; the remediation decision is to change the relevant policy or permission, not suppress evidence.

**Common mistake** — Only the Organizations management account can operate an organization analyzer.

**Actual AWS behavior** — The management account can designate a member account as an IAM Access Analyzer delegated administrator, which can create and manage organization analyzers. [AWS documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/access-analyzer-delegated-administrator.html)

**Why it matters** — Domain 4 Task 4.1 tests multi-account controls, including selecting a delegated operational owner without assuming management-account-only administration.

**Common mistake** — External, internal, and unused-access analyzers answer the same question.

**Actual AWS behavior** — External analyzers evaluate access outside a zone of trust, internal analyzers evaluate selected resources within it, and unused-access analyzers use access activity for IAM users and roles. [AWS documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/what-is-access-analyzer.html)

**Why it matters** — Domain 4 Task 4.1 scenarios require choosing the analyzer that matches an external-exposure, internal-access, or least-privilege question.

## Exam mapping

- [Domain 4: Security and Compliance](../../../domains/04-security-compliance/README.md) - Task 4.1 (access auditing, least-privilege validation)

## Must-remember numbers

No SOA-C03 decision figure is retained for this service; choose the analyzer type and remediation action from the behavior above.

## Good to know

| Figure | Value |
|--------|-------|
| Account-level analyzers | 1 per analyzer type, account, and Region. [AWS documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/access-analyzer-quotas.html) |
| Policy validation | Basic checks are free. [AWS documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/access-analyzer-policy-validation.html) |
| Custom policy checks | Charged per check. [AWS documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/what-is-access-analyzer.html) |
