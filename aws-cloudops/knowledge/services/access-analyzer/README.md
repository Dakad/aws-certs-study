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

- **Access Analyzer != IAM Policy Simulator**: The simulator evaluates a specified principal, action, and resource. Access Analyzer analyzes supported access paths and validates policies.
- **External, internal, and unused access are distinct**: External analysis looks beyond a defined trust zone; internal analysis evaluates selected resources within it; unused analysis evaluates IAM access activity.
- **Organization analyzer governance**: A delegated administrator can create and manage organization analyzers; it is not management-account-only.
- **Archiving != remediation**: An archived finding remains stored and can be unarchived. Removing the access is what resolves an access finding.
- **Custom checks are targeted assertions**: They compare for new access, test specified access, or test public access. They are not a general unused-permissions report.

## Exam mapping

- [Domain 4: Security and Compliance](../../../domains/04-security-compliance/README.md) - Task 4.1 (access auditing, least-privilege validation)

## Must-remember numbers

| Figure | Value |
|--------|-------|
| Account-level analyzers | 1 per analyzer type, account, and Region |
| Policy validation | Basic checks are free |
| Custom policy checks | Charged per check |
