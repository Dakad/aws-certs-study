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

> [!IMPORTANT]
> **Security Hub aggregates and tracks findings; it does not remediate their underlying causes.** For SOA-C03 Domain 4 findings decisions, use Security Hub to prioritize and route evidence, then remediate with the responsible service or automation; treating a workflow update as a fix leaves the issue unresolved.

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

**Common mistake** — Security Hub performs the threat detection and vulnerability scanning that created its GuardDuty or Inspector findings.

**Actual AWS behavior** — Security Hub receives findings from controls, integrated AWS services, partner products, and custom integrations, then normalizes them to ASFF; the source service performs its own detection or assessment. [AWS documentation](https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-findings.html)

**Why it matters** — Domain 4 Task 4.1 requires selecting the source security service to investigate or configure, while using Security Hub as the centralized findings view.

**Common mistake** — Changing `Workflow.Status` to `RESOLVED` archives a finding or prevents another finding for the same issue.

**Actual AWS behavior** — Workflow status tracks an individual investigation and does not affect generation of new findings; `RecordState` is a separate active-or-archived field. [AWS documentation](https://docs.aws.amazon.com/securityhub/latest/userguide/findings-workflow-status.html)

**Why it matters** — Domain 4 Task 4.1 requires distinguishing investigation progress from evidence retention and remediation of the underlying control failure.

**Common mistake** — Suppressing a finding fixes the underlying security issue.

**Actual AWS behavior** — A suppressed finding indicates that no action is needed after review; it remains a finding and does not remediate the resource or prevent a new finding for the same issue. [AWS documentation](https://docs.aws.amazon.com/securityhub/latest/userguide/findings-workflow-status.html)

**Why it matters** — Domain 4 Task 4.1 requires choosing suppression only for reviewed, expected results, not as a substitute for remediation.

**Common mistake** — Cross-Region aggregation automatically enables Security Hub everywhere or collects data from every Region.

**Actual AWS behavior** — Aggregation collects from linked Regions where Security Hub is enabled for that account; it does not enable Security Hub in linked Regions automatically. [AWS documentation](https://docs.aws.amazon.com/securityhub/latest/userguide/finding-aggregation.html)

**Why it matters** — Domain 4 Task 4.1 multi-account and multi-Region compliance scenarios require verifying regional enablement before interpreting an empty aggregate view.

## Exam mapping

- **[Domain 4: Security and Compliance](../../../domains/04-security-compliance/README.md)** - Task 4.1 (Implement compliance monitoring and security tools)

## Must-remember numbers

No SOA-C03 decision figure is retained for Security Hub; the exam-critical decision is to distinguish source, status, and remediation above.

## Good to know

| Figure | Value |
|--------|-------|
| Active finding retention | Expires after 90 days without an update. [AWS documentation](https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-findings.html) |
| Archived finding retention | Expires after 30 days without an update. [AWS documentation](https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-findings.html) |
| Maximum custom insights per account and Region | 100. [AWS documentation](https://docs.aws.amazon.com/general/latest/gr/sechub.html) |
| Maximum member accounts per administrator account and Region | 10,000. [AWS documentation](https://docs.aws.amazon.com/general/latest/gr/sechub.html) |
