---
id: "organizations"
kind: "service"
domains: [4]
services: ["organizations"]
sources:
  - title: "AWS Organizations User Guide"
    url: "https://docs.aws.amazon.com/organizations/latest/userguide/orgs_introduction.html"
  - title: "Service Control Policies"
    url: "https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_scps.html"
  - title: "AWS Policy Evaluation Logic"
    url: "https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_evaluation-logic.html"
  - title: "Resource control policies (RCPs)"
    url: "https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_rcps.html"
  - title: "AWS Organizations quotas and service limits"
    url: "https://docs.aws.amazon.com/organizations/latest/userguide/orgs_reference_limits.html"
last_verified: 2026-10-04
---

# AWS Organizations & Service Control Policies (SCPs)

## In one paragraph

AWS Organizations centrally manages multiple AWS accounts. Service Control Policies (SCPs) set maximum-permission guardrails for IAM users and roles in member accounts. They define what actions can be allowed, but do not grant permissions themselves. SCPs are one organizational input to authorization, not a universal policy-evaluation formula.

## Behavior and boundaries

- **Organization structure**: Management account (payer) + member accounts. Organizational Units (OUs) group accounts for policy attachment.
- **SCPs are not permissions**: They are allow-lists (or deny-lists) that filter what identity and resource policies can allow. The applicable IAM policy still grants permission.
- **SCP attachment**: Can attach to Root, OU, or individual account. Inheritance flows down: Root -> OU -> Account.
- **Default SCP**: `FullAWSAccess` (allows all). Removing it without replacement blocks everything.
- **Management account is exempt**: SCPs do not apply to the management account.
- **RCP distinction**: RCPs are also organizational guardrails and do not grant permissions. Unlike SCPs, applicable RCPs constrain access to supported resources in member accounts, including requests from principals outside the organization.

## Policy evaluation hierarchy (exam-critical)

Authorization is request- and principal-dependent. IAM determines which identity-based, resource-based, session, and permissions-boundary policies apply to that request. Applicable SCPs limit IAM users and roles in member accounts; applicable RCPs limit supported resources in member accounts. An explicit `Deny` in any applicable policy wins.

- SCPs do not grant permissions. A principal still needs an applicable IAM `Allow`.
- In an SCP allow-list, an action must be allowed at every applicable organization level for a member-account identity to use it.
- An SCP attached to the resource owner's account does not restrict an outside principal that a resource policy grants access to. An applicable RCP can restrict access to the resource instead.

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

- **Effect: Allow**: Adds to the SCP allow-list; it still does not grant IAM permissions.
- **Effect: Deny**: Explicitly denies the action and takes precedence over an Allow.
- **Condition keys**: `aws:PrincipalOrgID`, `aws:PrincipalOrgPaths`, `aws:PrincipalAccount`, `aws:RequestedRegion`, service-specific keys

## Common SCP patterns (exam-relevant)

| Pattern | Use case |
|---------|----------|
| **Deny by default** (Allow-list) | `"Effect": "Allow", "Action": ["s3:*", "ec2:*"], "Resource": "*"` - only listed services can be allowed |
| **Deny specific high-risk actions** | `"Effect": "Deny", "Action": ["organizations:LeaveOrganization", "account:CloseAccount"], "Resource": "*"` |
| **Enforce encryption** | Deny `s3:PutObject` without `s3:x-amz-server-side-encryption` |
| **Restrict regions** | `"Condition": { "StringNotEquals": { "aws:RequestedRegion": ["us-east-1", "eu-west-1"] } }` |
| **Prevent root usage** | Deny all actions for `arn:aws:iam::*:root` |
| **Guardrail for AI services** | Deny `bedrock:*`, `sagemaker:*` except approved OUs |

## Common confusion

- **SCP != IAM Policy**: SCP filters what can be allowed; IAM policy grants. SCP `Allow` alone does nothing without matching IAM permission.
- **Management account exemption**: SCPs never restrict the management account. Test from a member account.
- **Implicit deny in SCP**: If an action is not listed in an allow-list SCP, it is denied for affected member-account identities.
- **SCP does not affect service-linked roles**: Service-linked roles cannot be restricted by SCPs.
- **OU inheritance**: An account inherits SCPs from all parent OUs + Root. In an allow-list design, every applicable level must permit the action.
- **SCP scope is the member-account identity**: A resource policy can grant an outside principal access to a member-account resource without that resource owner's SCP applying to the outside principal.

## Operational signals

- **Organization CloudTrail**: Single trail in management account logs all member accounts (org trail).
- **Access Analyzer org analyzer**: Scans all member accounts for external access findings.
- **Config aggregator**: Multi-account compliance view.
- **Trusted Advisor**: Org-level checks (service limits, security groups, etc.).

## Exam mapping

- [Domain 4: Security and Compliance](../../../domains/04-security-compliance/README.md) - Task 4.1 (multi-account controls, SCPs, access auditing)

## Must-remember numbers

| Figure | Value |
|--------|-------|
| Default maximum accounts per organization | 10; adjustable up to 50,000 |
| Maximum OUs per organization | 2,000 |
| Maximum SCPs per organization | 10,000 |
| Maximum SCP size | 10,240 characters |
| Directly attached SCPs per Root, OU, or account | 10 |
| SCP evaluation | Applies to member-account IAM users and roles, not the management account |
