---
id: "organizations"
kind: "service"
domains: [4]
services: ["organizations"]
related:
  - relation: "secured-by"
    target: "iam"
  - relation: "integrates-with"
    target: "cloudtrail"
  - relation: "integrates-with"
    target: "access-analyzer"
  - relation: "integrates-with"
    target: "config"
sources:
  - title: "AWS Organizations User Guide"
    url: "https://docs.aws.amazon.com/organizations/latest/userguide/orgs_introduction.html"
  - title: "Service Control Policies"
    url: "https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_scps.html"
  - title: "AWS Policy Evaluation Logic"
    url: "https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_evaluation-logic.html"
last_verified: 2026-10-03
---

# AWS Organizations & Service Control Policies (SCPs)

## In one paragraph

AWS Organizations centrally manages multiple AWS accounts. Service Control Policies (SCPs) set maximum permissions guardrails for member accounts — they define what actions *can* be allowed, but do not grant permissions themselves. SCPs are the organization-level boundary in the policy evaluation hierarchy.

## Behavior and boundaries

- **Organization structure**: Management account (payer) + member accounts. Organizational Units (OUs) group accounts for policy attachment.
- **SCPs are not permissions** — They are *allow-lists* (or deny-lists) that filter what identity/resource policies can allow. Effective permission = Identity Policy ∩ Resource Policy ∩ SCP ∩ Session Policy ∩ Permissions Boundary.
- **SCP attachment**: Can attach to Root, OU, or individual account. Inheritance flows down: Root → OU → Account.
- **Default SCP**: `FullAWSAccess` (allows all). Removing it without replacement blocks everything.
- **Management account is exempt** — SCPs do not apply to the management account (by design).
- **SCP size limit**: 5,120 characters per policy.

## Policy evaluation hierarchy (exam-critical)

```
Effective Permissions = 
  Identity Policy (user/role) 
  ∩ Resource Policy (bucket, KMS key, etc.) 
  ∩ SCP (org/OU/account) 
  ∩ Session Policy (assumed role) 
  ∩ Permissions Boundary (role)
```

**Evaluation logic for a request:**
1. Explicit **Deny** anywhere → **Deny** (wins always)
2. If no explicit Deny: check **Allow** in each layer — all applicable layers must Allow
3. SCP only restricts; it never grants. If SCP doesn't Allow an action, it's Denied even if identity policy Allows.

## SCP syntax (exam-relevant)

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyUnencryptedS3",
      "Effect": "Deny",
      "Action": "s3:PutObject",
      "Resource": "*",
      "Condition": {
        "StringNotEquals": {
          "s3:x-amz-server-side-encryption": "AES256"
        }
      }
    }
  ]
}
```

- **Effect: Allow** → Adds to the allow-list (must be allowed by SCP *and* identity policy)
- **Effect: Deny** → Explicit deny (wins over any Allow)
- **Condition keys**: `aws:PrincipalOrgID`, `aws:PrincipalOrgPaths`, `aws:PrincipalAccount`, `aws:RequestedRegion`, service-specific keys

## Common SCP patterns (exam-relevant)

| Pattern | Use case |
|---------|----------|
| **Deny by default** (Allow-list) | `"Effect": "Allow", "Action": ["s3:*", "ec2:*"], "Resource": "*"` — only listed services allowed |
| **Deny specific high-risk actions** | `"Effect": "Deny", "Action": ["organizations:LeaveOrganization", "account:CloseAccount"], "Resource": "*"` |
| **Enforce encryption** | Deny `s3:PutObject` without `s3:x-amz-server-side-encryption` |
| **Restrict regions** | `"Condition": { "StringNotEquals": { "aws:RequestedRegion": ["us-east-1", "eu-west-1"] } }` |
| **Prevent root usage** | Deny all actions for `arn:aws:iam::*:root` |
| **Guardrail for AI services** | Deny `bedrock:*`, `sagemaker:*` except approved OUs |

## Common confusion

- **SCP ≠ IAM Policy** — SCP filters what *can* be allowed; IAM policy grants. SCP `Allow` alone does nothing without matching IAM `Allow`.
- **Management account exemption** — SCPs never restrict the management account. Test from a member account.
- **Implicit deny in SCP** — If an action isn't listed in an Allow-list SCP, it's implicitly denied. An explicit `Deny` in SCP is redundant but clearer.
- **SCP doesn't affect service-linked roles** — Service-linked roles operate with their own permissions; SCPs don't restrict them.
- **OU inheritance** — Account inherits SCPs from all parent OUs + Root. Most restrictive union applies.
- **`aws:PrincipalOrgID` vs `aws:PrincipalAccount`** — OrgID = entire organization; Account = specific account. Use OrgID for "only my org" conditions.
- **SCP changes are not instant** — Propagation can take a few minutes across accounts.

## Operational signals

- **Organization CloudTrail** — Single trail in management account logs all member accounts (org trail).
- **Access Analyzer org analyzer** — Scans all member accounts for external access findings.
- **Config aggregator** — Multi-account compliance view.
- **Trusted Advisor** — Org-level checks (service limits, security groups, etc.).

## Exam mapping

- [Domain 4: Security and Compliance](../domains/04-security-compliance/README.md) — Task 4.1 (multi-account controls, SCPs, access auditing)

## Must-remember numbers

| Figure | Value |
|--------|-------|
| Max accounts per organization | 10,000 (soft limit) |
| Max OUs per organization | Unlimited (practical limit ~100s) |
| Max SCPs per organization | 1,000 |
| Max SCP size | 5,120 characters |
| Max policies attached per target | 5 (Root/OU/Account) |
| SCP evaluation | Always applied to member accounts; never management account |

## Related nodes

- [IAM](../services/iam/README.md) — secured-by (SCPs filter IAM permissions)
- [CloudTrail](../services/cloudtrail/README.md) — integrates-with (org trail)
- [Access Analyzer](../services/access-analyzer/README.md) — integrates-with (org analyzer)
- [Config](../services/config/README.md) — integrates-with (multi-account aggregator)