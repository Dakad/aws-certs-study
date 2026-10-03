---
id: "securityhub"
kind: "service"
domains: [4]
services: ["securityhub"]
related:
  - relation: "aggregates-findings-from"
    target: "config"
  - relation: "aggregates-findings-from"
    target: "guardduty"
  - relation: "aggregates-findings-from"
    target: "inspector"
  - relation: "aggregates-findings-from"
    target: "access-analyzer"
  - relation: "integrates-with"
    target: "organizations"
  - relation: "integrates-with"
    target: "cloudtrail"
  - relation: "integrates-with"
    target: "iam"
sources:
  - title: "AWS Security Hub User Guide"
    url: "https://docs.aws.amazon.com/securityhub/latest/userguide/what-is-securityhub.html"
  - title: "AWS Security Finding Format (ASFF)"
    url: "https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-findings-format.html"
  - title: "Security Hub Standards and Controls"
    url: "https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-standards.html"
last_verified: 2026-10-03
---

# AWS Security Hub

## In one paragraph

AWS Security Hub provides a centralized view of security posture across AWS accounts and regions. It aggregates, normalizes, and prioritizes findings from AWS services (Config, GuardDuty, Inspector, IAM Access Analyzer, Firewall Manager) and partner tools into the AWS Security Finding Format (ASFF), enables continuous compliance checks against standards (CIS AWS Foundations, PCI DSS, AWS Foundational Security Best Practices), and supports automated response via EventBridge.

## Behavior and boundaries

- **Finding aggregation**: Collects findings from Config (config rules), GuardDuty (threat detection), Inspector (vulnerability scans), IAM Access Analyzer (external access), Firewall Manager (policy compliance), and integrated partner products
- **Normalization**: All findings converted to **AWS Security Finding Format (ASFF)** — a common schema enabling cross-source querying and automation
- **Standards**: Security Hub manages security standards (CIS AWS Foundations Benchmark, PCI DSS, AWS Foundational Security Best Practices). Each standard contains controls that map to specific Config rules or Security Hub checks. Standards must be **enabled per account per region**.
- **Compliance status per control**: `PASSED`, `FAILED`, `WARNING`, `NOT_AVAILABLE`. Security score = percentage of passed controls per standard.
- **Custom insights**: Managed insights (provided by Security Hub) + custom insights (group by + filter on finding attributes). Used for prioritization (e.g., "critical findings on internet-facing EC2").
- **Finding suppression rules**: Automatically suppress findings matching criteria (e.g., specific resource tags, accounts). Suppressed findings remain in Security Hub but excluded from security scores and insights. **Suppression ≠ resolution**.
- **Cross-region aggregation**: Requires **delegated administrator account** in AWS Organizations. Member accounts send findings to the delegated admin account in the aggregation region. The admin account sees a consolidated view across all member accounts and regions.
- **EventBridge integration**: Findings emitted as events to EventBridge (default event bus) for automated response (Lambda, Step Functions, SNS, Systems Manager).

## Finding lifecycle

```
Generated → Active → Suppressed/Resolved → Archived
```

**Workflow status** (tracked on each finding):
- `NEW` — Initial state when finding is created
- `NOTIFIED` — Finding has been sent to notification channels
- `RESOLVED` — Underlying issue has been fixed (finding auto-archives after 90 days)
- `SUPPRESSED` — Finding matches a suppression rule

## Standards

| Standard | Description |
|----------|-------------|
| **AWS Foundational Security Best Practices** | AWS-maintained baseline (enabled by default) |
| **CIS AWS Foundations Benchmark** | Industry standard (v1.2.0, v1.4.0, v1.5.0) |
| **PCI DSS** | Payment card industry requirements |
| **Custom standards** | User-defined controls (via Security Hub API) |

Controls map 1:1 to findings. A failed control = a finding with `Compliance.Status = FAILED`.

## Cross-region aggregation

- **Delegated administrator**: Designated in Organizations console or via CLI. Must be in the same organization.
- **Aggregation region**: Single region where delegated admin receives findings. Other regions forward findings to this region.
- **Member accounts**: Automatically associated when Security Hub is enabled in member account (if org integration enabled).
- **Permissions**: Delegated admin gets `securityhub:GetFindings`, `securityhub:BatchImportFindings` across member accounts via service-linked role.

## Common confusion

- **Security Hub ≠ GuardDuty/Inspector** — Security Hub *aggregates* findings from these services; it does not perform threat detection or vulnerability scanning itself.
- **Standards must be enabled per region** — Enabling a standard in us-east-1 does not enable it in eu-west-1. Each region is independent.
- **Suppression ≠ resolution** — Suppressed findings are hidden from scores/insights but remain `ACTIVE` with `Workflow.Status = SUPPRESSED`. Resolved findings move to `ARCHIVED`.
- **Delegated admin required for org view** — Without delegated admin, each account sees only its own findings. No cross-account view.
- **Finding format is ASFF** — Original service finding formats (GuardDuty, Inspector) are transformed. Query/automate against ASFF fields, not source-specific fields.
- **Security Hub does not enforce remediation** — It detects and prioritizes; remediation is separate (Systems Manager, Lambda, manual).

## Exam mapping

- **[Domain 4: Security and Compliance](../domains/04-security-compliance/README.md)** — Task 4.1 (Implement compliance monitoring and security tools)
  - Multi-account security posture via Security Hub + Organizations
  - Standards-based compliance (CIS, PCI DSS, AWS Foundational)
  - Finding aggregation, insights, and automated response via EventBridge

## Must-remember numbers

| Figure | Value |
|--------|-------|
| Finding retention (default) | 90 days |
| Finding retention (max, with retention config) | 3 years (1095 days) |
| Max custom insights per account/region | 100 |
| Max suppression rules per account/region | 100 |
| Standards enabled | Per account, per region |
| Delegated admin | 1 per organization |
| Aggregation regions | 1 per delegated admin |
| Max member accounts | 5,000 per delegated admin |

## Related nodes

- [Config](../services/config/README.md) — aggregates-findings-from (config rules → findings)
- [GuardDuty](../services/guardduty/README.md) — aggregates-findings-from (threat detections)
- [Inspector](../services/inspector/README.md) — aggregates-findings-from (vulnerability findings)
- [Access Analyzer](../services/access-analyzer/README.md) — aggregates-findings-from (external access findings)
- [Organizations](../services/organizations/README.md) — integrates-with (delegated admin, cross-account aggregation)
- [CloudTrail](../services/cloudtrail/README.md) — integrates-with (control plane events, finding history)
- [IAM](../services/iam/README.md) — integrates-with (Access Analyzer findings, permissions for Security Hub)