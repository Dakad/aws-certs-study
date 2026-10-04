---
id: "securityhub"
kind: "service"
domains: [4]
services: ["securityhub"]
sources:
  - title: "AWS Security Hub User Guide"
    url: "https://docs.aws.amazon.com/securityhub/latest/userguide/what-is-securityhub.html"
  - title: "AWS Security Finding Format (ASFF)"
    url: "https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-findings-format.html"
  - title: "Security Hub Standards and Controls"
    url: "https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-standards.html"
  - title: "Creating and updating findings in Security Hub CSPM"
    url: "https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-findings.html"
  - title: "Setting the workflow status of findings in Security Hub CSPM"
    url: "https://docs.aws.amazon.com/securityhub/latest/userguide/findings-workflow-status.html"
  - title: "Evaluating compliance status and control status"
    url: "https://docs.aws.amazon.com/securityhub/latest/userguide/controls-overall-status.html"
  - title: "Understanding cross-Region aggregation in Security Hub CSPM"
    url: "https://docs.aws.amazon.com/securityhub/latest/userguide/finding-aggregation.html"
  - title: "AWS Security Hub CSPM endpoints and quotas"
    url: "https://docs.aws.amazon.com/general/latest/gr/sechub.html"
last_verified: 2026-10-04
---

# AWS Security Hub

## In one paragraph

AWS Security Hub provides a centralized view of security posture across AWS accounts and Regions. It aggregates, normalizes, and prioritizes findings from AWS services and partner tools into the AWS Security Finding Format (ASFF), supports continuous compliance checks against standards, and can send findings to EventBridge for automated response.

## Behavior and boundaries

- **Finding aggregation**: Collects findings from Config (config rules), GuardDuty (threat detection), Inspector (vulnerability scans), IAM Access Analyzer (external access), Firewall Manager (policy compliance), and integrated partner products
- **Normalization**: All findings converted to **AWS Security Finding Format (ASFF)** - a common schema enabling cross-source querying and automation
- **Standards**: Security Hub manages security standards (CIS AWS Foundations Benchmark, PCI DSS, AWS Foundational Security Best Practices). Each standard contains controls that map to specific Config rules or Security Hub checks. Standards must be **enabled per account per Region**.
- **Control status**: A control's overall status is `Passed`, `Failed`, `Unknown`, `No data`, or `Disabled`. Security Hub derives it from its control findings' compliance status, excluding archived and suppressed findings.
- **Cross-Region aggregation**: Standalone, member, and administrator accounts can configure a home Region and linked Regions. Aggregation includes data only from linked Regions where Security Hub is enabled for that account.
- **Custom insights**: Managed insights (provided by Security Hub) + custom insights (group by + filter on finding attributes). Used for prioritization (e.g., "critical findings on internet-facing EC2").
- **Finding suppression rules**: Automatically suppress findings matching criteria (e.g., specific resource tags, accounts). Suppressed findings remain in Security Hub but excluded from security scores and insights. **Suppression != resolution**.
- **EventBridge integration**: Findings emitted as events to EventBridge (default event bus) for automated response (Lambda, Step Functions, SNS, Systems Manager).

## Finding lifecycle

Finding fields represent separate concepts:

- **Control compliance status**: A control finding can be `PASSED`, `FAILED`, `WARNING`, or `NOT_AVAILABLE`; these contribute to the overall control status.
- **`Workflow.Status`**: `NEW`, `NOTIFIED`, `SUPPRESSED`, or `RESOLVED` tracks investigation progress. `RESOLVED` means the finding was reviewed and remediated; it does not archive the finding.
- **`RecordState`**: `ACTIVE` or `ARCHIVED` describes whether the finding record is active or archived. Archiving is distinct from setting workflow to `RESOLVED`.

Security Hub permanently deletes an active finding that has not been updated for 90 days. It permanently deletes an archived finding that has not been updated for 30 days.

## Standards

| Standard | Description |
|----------|-------------|
| **AWS Foundational Security Best Practices** | AWS-maintained baseline (enabled by default) |
| **CIS AWS Foundations Benchmark** | Industry standard (v1.2.0, v1.4.0, v1.5.0) |
| **PCI DSS** | Payment card industry requirements |
| **Custom standards** | User-defined controls (via Security Hub API) |

Controls can have multiple findings. Their overall status is derived from the applicable control findings rather than from a single finding alone.

## Cross-Region aggregation

- **Home Region**: The Region that displays findings, finding updates, insights, control compliance statuses, and security scores from linked Regions.
- **Linked Regions**: Regions selected for aggregation; Security Hub does not enable itself automatically in them.
- **Administrator and member accounts**: An administrator's aggregation settings are inherited by its members. A standalone account can also configure aggregation without a delegated administrator.

## Common confusion

- **Security Hub != GuardDuty/Inspector**: Security Hub *aggregates* findings from these services; it does not perform threat detection or vulnerability scanning itself.
- **Control status != finding workflow**: Control status summarizes compliance findings; `Workflow.Status` tracks investigation work on one finding.
- **`RESOLVED` != `ARCHIVED`**: A workflow resolution does not change a finding's `RecordState` to `ARCHIVED`.
- **Suppression != remediation**: A suppressed finding remains a finding; suppression is not a fix to the underlying issue.
- **Cross-Region aggregation is per account**: It can be configured for standalone accounts as well as administered accounts, and only enabled linked Regions contribute data.
- **Finding format is ASFF**: Original service finding formats (GuardDuty, Inspector) are transformed. Query/automate against ASFF fields, not source-specific fields.
- **Security Hub does not enforce remediation**: It detects and prioritizes; remediation is separate (Systems Manager, Lambda, manual).

## Exam mapping

- **[Domain 4: Security and Compliance](../../../domains/04-security-compliance/README.md)** - Task 4.1 (Implement compliance monitoring and security tools)

## Must-remember numbers

| Figure | Value |
|--------|-------|
| Active finding retention | Expires after 90 days without an update |
| Archived finding retention | Expires after 30 days without an update |
| Max custom insights per account and Region | 100 |
| Standards enabled | Per account, per Region |
| Max member accounts | 10,000 per administrator account, per Region |
