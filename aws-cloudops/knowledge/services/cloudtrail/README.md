---
id: "cloudtrail"
kind: "service"
domains: [1, 4]
services: ["cloudtrail"]
related:
  - relation: "integrates-with"
    target: "cloudwatch"
  - relation: "integrates-with"
    target: "s3"
  - relation: "integrates-with"
    target: "sns"
  - relation: "secured-by"
    target: "kms"
  - relation: "audited-by"
    target: "config"
  - relation: "integrates-with"
    target: "organizations"
  - relation: "integrates-with"
    target: "securityhub"
  - relation: "integrates-with"
    target: "guardduty"
sources:
  - title: "AWS CloudTrail User Guide"
    url: "https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-user-guide.html"
  - title: "CloudTrail Event Reference"
    url: "https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-event-reference.html"
  - title: "CloudTrail Event History"
    url: "https://docs.aws.amazon.com/awscloudtrail/latest/userguide/view-cloudtrail-events.html"
  - title: "CloudTrail Insights"
    url: "https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-insights.html"
  - title: "CloudTrail Network Activity Events"
    url: "https://docs.aws.amazon.com/awscloudtrail/latest/userguide/logging-network-events-with-cloudtrail.html"
  - title: "CloudTrail Log File Integrity Validation"
    url: "https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-log-file-validation-intro.html"
  - title: "CloudTrail Lake"
    url: "https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-lake.html"
  - title: "AWS CloudTrail Pricing"
    url: "https://aws.amazon.com/cloudtrail/pricing/"
last_verified: 2026-10-04
---

# CloudTrail

## In one paragraph

CloudTrail records AWS API calls and account activity as events for governance, compliance, and operational troubleshooting. It captures management events (control-plane) and optionally data events (S3, Lambda, DynamoDB) and network activity events.

## Behavior and boundaries

- **Management events** (control-plane): Enabled by default for 90 days in Event History; includes Create/Delete/Modify API calls, IAM actions, Console sign-ins. Read-only or write-only filtering available. See [CloudTrail Event History](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/view-cloudtrail-events.html).
- **Data events** (data-plane): Opt-in per resource type; S3 object-level (`GetObject`, `PutObject`, `DeleteObject`), Lambda `Invoke`, DynamoDB item-level (`GetItem`, `PutItem`, `DeleteItem`, `UpdateItem`). Charged per 100k events. See [AWS CloudTrail Pricing](https://aws.amazon.com/cloudtrail/pricing/).
- **Network activity events**: Opt-in `NetworkActivity` events that record eligible AWS API calls made through VPC endpoints. Configure them by event source.
- **Trails**: Persistent delivery to S3 bucket (and optionally CloudWatch Logs). Can be single-region or multi-region (recommended). Organization trail = one trail in management account logging all member accounts.
- **Event retention**: Event History is a 90-day Regional management-event view. Trail retention in S3 follows the bucket lifecycle. CloudTrail Lake retention depends on its pricing option: one-year extendable retention can extend to 10 years, while seven-year retention cannot extend beyond seven years. See [CloudTrail Event History](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/view-cloudtrail-events.html) and [CloudTrail Lake](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-lake.html).
- **Integrity validation**: When enabled, digest files and their hash chain let you detect log-file modification or deletion after CloudTrail delivers the files to S3.
- **Log file encryption**: SSE-S3 (default) or SSE-KMS (customer-managed key). KMS key policy must allow CloudTrail to encrypt/decrypt.
- **Global services**: IAM, CloudFront, Route 53, WAF, STS — events delivered to trail's home region (default us-east-1 for org trails).
- **CloudTrail Lake** (separate from trails): SQL-based query engine on immutable event data stores. Its pricing option determines ingestion, retention, and query costs; it supports federated queries.
- **CloudTrail Insights** (paid add-on): Detects deviations from baseline API call rates and API error rates in management and data events. Data-event Insights are supported on trails, not event data stores.

## Trail configuration (exam-relevant)

| Setting | Options | Recommendation |
|---------|---------|----------------|
| **Multi-region** | Yes / No | **Yes** — captures global services + regional events in one trail |
| **Organization trail** | Yes / No | Yes for multi-account; created in management account |
| **Log file validation** | Enabled / Disabled | **Enabled** — integrity proof |
| **SSE-KMS** | Enabled / Disabled | Enabled for compliance; key policy must allow `cloudtrail.amazonaws.com` |
| **CloudWatch Logs delivery** | Enabled / Disabled | Enables metric filters/alarms on API activity |
| **SNS notifications** | Enabled / Disabled | Notifies on log file delivery |
| **Data event selectors** | Per resource (S3/Lambda/DynamoDB) | Add only high-value resources; cost per 100k events |

## Operational signals

- **Event History**: Console-searchable 90-day Regional management-event view; filters by resource, user, event name, time, and error code. It excludes data, Insights, and network activity events; console downloads support up to 200,000 events per file. See [CloudTrail Event History](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/view-cloudtrail-events.html).
- **Trail to CloudWatch Logs**: Enables metric filters and alarms on API activity (e.g., `ConsoleLogin` failures, `DeleteBucket`, `AttachRolePolicy`).
- **Trail to S3**: Long-term storage; query with Athena, feed to Security Hub, GuardDuty, or SIEM. JSON lines, gzipped.
- **CloudTrail Lake**: SQL queries on event data stores; supports `SELECT`, `JOIN`, and aggregations. Retention is set by the selected pricing option.
- **Insights** (paid): Detects unusual API call-rate and API error-rate activity; creates `AwsCloudTrailInsight` events; viewable in the console.

## Data event details (exam-relevant)

| Resource type | Event examples | Selector format |
|---------------|----------------|-----------------|
| S3 | `GetObject`, `PutObject`, `DeleteObject`, `ListObjects` | `arn:aws:s3:::bucket-name` or `arn:aws:s3:::bucket-name/prefix/` |
| Lambda | `Invoke`, `InvokeAsync` | `arn:aws:lambda:region:account-id:function:function-name` |
| DynamoDB | `GetItem`, `PutItem`, `DeleteItem`, `UpdateItem`, `Query`, `Scan` | `arn:aws:dynamodb:region:account-id:table/table-name` |

> [!IMPORTANT]
> **Concept: CloudTrail data-event selectors.** For SOA-C03 audit-coverage decisions, S3 object, Lambda invocation, and DynamoDB item events are not captured by default; a trail needs basic or advanced event selectors. Assuming management-event coverage includes them leaves the required data-plane evidence unavailable. See [CloudTrail Event Reference](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-event-reference.html).

## Key fields in an event (exam-relevant)

| Field | Purpose |
|-------|---------|
| `eventTime` | ISO 8601 timestamp |
| `eventSource` | Service endpoint (e.g., `ec2.amazonaws.com`) |
| `eventName` | API action (e.g., `RunInstances`, `AttachRolePolicy`) |
| `userIdentity` | Principal: type (IAMUser, AssumedRole, Root, AWSService, FederatedUser), ARN, accountId, sessionContext (includes `sessionIssuer` for assumed roles) |
| `requestParameters` | Input to the API call |
| `responseElements` | Output (empty on error) |
| `errorCode` / `errorMessage` | Present on failure — **key for AccessDenied investigation** |
| `sourceIPAddress` | Caller IP (or `AWS Internal` for service-initiated) |
| `userAgent` | Console (`aws-internal`, `console.amazonaws.com`), CLI (`aws-cli/2.x`), SDK, service |
| `eventType` | `AwsApiCall`, `AwsServiceEvent`, `AwsConsoleSignIn` |
| `recipientAccountId` | Account that owns the resource (useful for cross-account) |
| `vpcEndpointId` | Present for network activity events |

## Common confusion

- **Common mistake** — Event History is a durable audit archive equivalent to a trail.
- **Actual AWS behavior** — Event History is a 90-day, Regional view of management events and excludes data, Insights, and network activity events; a trail persistently delivers configured events to S3. See [CloudTrail Event History](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/view-cloudtrail-events.html) and the [AWS CloudTrail User Guide](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-user-guide.html).
- **Why it matters** — Domain 4 Task 4.1 access-auditing decisions require durable, appropriately scoped evidence rather than relying on the limited Event History view.

- **Common mistake** — Enabling CloudTrail captures S3 object, Lambda invocation, and DynamoDB item activity automatically.
- **Actual AWS behavior** — Those data events are opt-in and require event selectors; the selected event volume is billed. See [CloudTrail Event Reference](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-event-reference.html) and [AWS CloudTrail Pricing](https://aws.amazon.com/cloudtrail/pricing/).
- **Why it matters** — Domain 1 Task 1.1 and Domain 4 Task 4.1 require choosing audit coverage that can actually establish data-plane activity without collecting unnecessary event volume.

- **Common mistake** — A single-Region trail provides account-wide audit coverage.
- **Actual AWS behavior** — A single-Region trail misses activity in other Regions; a multi-Region trail captures regional activity across Regions and is the appropriate choice for centralized coverage. See the [AWS CloudTrail User Guide](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-user-guide.html).
- **Why it matters** — Domain 4 Task 4.1 scenarios require coverage that still yields audit evidence when an API call occurs outside the trail's home Region.

- **Common mistake** — CloudTrail delivery to S3 is the evidence path for sub-minute alerting.
- **Actual AWS behavior** — Trail log delivery is not a real-time alerting mechanism; use the trail's CloudWatch Logs integration with metric filters and alarms when the scenario needs detection and response. See the [AWS CloudTrail User Guide](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-user-guide.html).
- **Why it matters** — Domain 1 Task 1.2 remediation decisions must distinguish retained audit evidence from a monitoring path that can trigger an alarm or automation.

## Exam mapping

- [Domain 1: Monitoring, Logging, Analysis, Remediation](../../../domains/01-monitoring-logging-analysis-remediation-performance-optimization/README.md) — Task 1.1 (audit logging)
- [Domain 4: Security and Compliance](../../../domains/04-security-compliance/README.md) — Task 4.1 (access auditing, CloudTrail evidence)

## Must-remember numbers

| Figure | Value | SOA-C03 decision and source |
|--------|-------|------------------------------|
| Event History retention | 90 days | It is not a long-term audit archive. See [CloudTrail Event History](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/view-cloudtrail-events.html). |

## Good to know

| Figure | Value | Operational context and source |
|--------|-------|--------------------------------|
| Event History console download | Up to 200,000 events per file | See [CloudTrail Event History](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/view-cloudtrail-events.html). |
| CloudTrail Lake retention | One-year extendable retention: up to 10 years; seven-year retention: up to 7 years | The selected pricing option determines the retention boundary. See [CloudTrail Lake](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-lake.html). |
| Digest file delivery | Every hour | See [CloudTrail Log File Integrity Validation](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-log-file-validation-intro.html). |
