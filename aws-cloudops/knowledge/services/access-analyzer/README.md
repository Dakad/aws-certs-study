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
    url: "https://docs.aws.amazon.com/IAM/latest/UserGuide/access-analyzer.html"
  - title: "Access Analyzer Policy Validation"
    url: "https://docs.aws.amazon.com/IAM/latest/UserGuide/access-analyzer-policy-validation.html"
last_verified: 2026-10-03
---

# IAM Access Analyzer

## In one paragraph

IAM Access Analyzer identifies unintended resource access by analyzing policies using automated reasoning. It generates findings for resources shared with external principals and validates IAM policies for syntax, best practices, and over-permissive permissions.

## Behavior and boundaries

- **Two analyzer types**:
  - **Account analyzer**: Finds resources in your account shared with external principals (other accounts, public, AWS services).
  - **Organization analyzer**: Created in management account; scans all member accounts; finds cross-account and external access across the organization.
- **Supported resource types**: S3 buckets, IAM roles, KMS keys, SQS queues, Lambda functions, Secrets Manager secrets, ECR repositories, EFS file systems, RDS snapshots, and more.
- **Finding status**: `Active` (access exists), `Archived` (resolved), `Resolved` (access removed).
- **Policy validation**: Checks IAM policies (identity, resource, SCPs) for:
  - Syntax errors
  - Security warnings (over-permissive, unused permissions)
  - Best practice suggestions (condition keys, constraint resources)
- **Custom policy checks** (paid): Validate policies against custom rules (e.g., "no `*` action on `*` resource").

## Operational signals

- **Findings console**: Filter by resource type, principal, status, analyzer. Shows external principal ARN, resource ARN, permission granted, condition context.
- **Finding details**: Includes `action`, `condition`, `isPublic`, `principal`, `resource`, `resourceType`, `createdAt`, `updatedAt`.
- **Policy validation API**: `ValidatePolicy` — returns `errors`, `warnings`, `suggestions`, `findings` for a policy document.
- **Archive/Resolve workflow**: Archive = suppress finding (known intent). Resolve = access actually removed (analyzer re-scans and auto-resolves).

## Policy validation categories (exam-relevant)

| Category | What it catches | Example |
|----------|-----------------|---------|
| **Error** | Invalid JSON, malformed ARN, unsupported condition key | `Condition: { "StringEquals": { "aws:PrincipalTag/CostCenter": "123" } }` — tag key not valid |
| **Security Warning** | Over-permissive: `*` action, `*` resource, missing condition | `"Action": "*", "Resource": "*"` |
| **Suggestion** | Add condition keys, constrain resources, use `aws:SourceArn`/`aws:SourceAccount` | S3 bucket policy missing `aws:SourceAccount` for CloudTrail delivery |

## Common confusion

- **Access Analyzer ≠ IAM Policy Simulator** — Simulator tests *specific* principal+action+resource; Access Analyzer *scans all policies* for external access and validates syntax/best practices across the board.
- **Account vs. Organization analyzer** — Org analyzer requires management account; member accounts cannot create their own org analyzer. Account analyzer only sees its own account.
- **Findings are not vulnerabilities** — External access may be intentional (e.g., public S3 bucket for static site). You must review and archive if expected.
- **Resolver = access removed** — Archiving doesn't fix the policy; it silences the finding. "Resolved" status means the analyzer re-scanned and the access no longer exists.
- **Custom policy checks are paid** — Basic validation (errors/warnings/suggestions) is free. Custom rules require Access Analyzer Custom Policy Checks (additional cost).
- **Scanner runs periodically** — Not real-time. New resource/policy changes may take hours to appear as findings.

## Exam mapping

- [Domain 4: Security and Compliance](../domains/04-security-compliance/README.md) — Task 4.1 (access auditing, least privilege validation)

## Must-remember numbers

| Figure | Value |
|--------|-------|
| Max account analyzers per region | 1 |
| Max organization analyzers per org | 1 |
| Supported resource types | 20+ (S3, IAM, KMS, SQS, Lambda, Secrets Manager, ECR, EFS, RDS, etc.) |
| Scan frequency | Periodic (not real-time); ~24 hours for full scan |
| Policy validation | Free (errors/warnings/suggestions) |
| Custom policy checks | Paid feature |

## Related nodes

- [IAM](../services/iam/README.md) — secured-by (analyzes IAM policies)
- [Organizations](../services/organizations/README.md) — integrates-with (org analyzer)
- [CloudTrail](../services/cloudtrail/README.md) — integrates-with (audit trail for access changes)