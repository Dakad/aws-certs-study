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

- **Management events** (control-plane): Enabled by default for 90 days in Event History; includes Create/Delete/Modify API calls, IAM actions, Console sign-ins. Read-only or write-only filtering available.
- **Data events** (data-plane): Opt-in per resource type; S3 object-level (`GetObject`, `PutObject`, `DeleteObject`), Lambda `Invoke`, DynamoDB item-level (`GetItem`, `PutItem`, `DeleteItem`, `UpdateItem`). Charged per 100k events.
- **Network activity events**: Opt-in `NetworkActivity` events that record eligible AWS API calls made through VPC endpoints. Configure them by event source.
- **Trails**: Persistent delivery to S3 bucket (and optionally CloudWatch Logs). Can be single-region or multi-region (recommended). Organization trail = one trail in management account logging all member accounts.
- **Event retention**: Event History is a 90-day Regional management-event view. Trail retention in S3 follows the bucket lifecycle. CloudTrail Lake retention depends on its pricing option: one-year extendable retention can extend to 10 years, while seven-year retention cannot extend beyond seven years.
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

- **Event History**: Console-searchable 90-day Regional management-event view; filters by resource, user, event name, time, and error code. It excludes data, Insights, and network activity events; console downloads support up to 200,000 events per file.
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
> Data events are **not captured by default**. You must explicitly add event selectors (basic or advanced) to the trail. Advanced selectors support field-level filtering (e.g., only `ReadOnly`=`false`).

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

- **Event History ≠ Trail** — Event History is a 90-day Regional management-event view with no S3 delivery; it excludes data, Insights, and network activity events. A trail is persistent, configurable delivery to S3.
- **Data events are not free** — Charged per 100k events; enable only what you need. Advanced selectors reduce cost by filtering.
- **Global services log to us-east-1** — If your trail is in eu-west-1, IAM/CloudFront/Route 53 events still appear there (delivered to trail's S3 bucket).
- **AccessDenied appears in CloudTrail** — `errorCode: "AccessDenied"` + `requestParameters` shows exactly what was attempted. This is the primary evidence for `AccessDenied` diagnosis.
- **Trail vs. Organization trail** — Org trail logs all member accounts to a central bucket; created in management account; member accounts cannot disable it.
- **Multi-region trail vs. single-region** — Single-region misses global service events and events in other regions. Multi-region is best practice.
- **CloudTrail Lake ≠ Trail + Athena** — Lake is a managed query engine with an immutable event data store and pricing based on ingestion, retention, and data scanned. Athena queries raw S3 files.
- **Insights scope** — Insights detect API call-rate and API error-rate deviations in management and data events. Data-event Insights require a trail; Insights do not analyze network activity events.
- **Log file delivery ≠ real-time** — Do not use trail delivery for sub-minute alerting.

## Exam mapping

- [Domain 1: Monitoring, Logging, Analysis, Remediation](../../../domains/01-monitoring-logging-analysis-remediation-performance-optimization/README.md) — Task 1.1 (audit logging)
- [Domain 4: Security and Compliance](../../../domains/04-security-compliance/README.md) — Task 4.1 (access auditing, CloudTrail evidence)

## Must-remember numbers

| Figure | Value |
|--------|-------|
| Event History retention | 90 days |
| Event History scope | Regional management events only; data, Insights, and network activity events excluded |
| Event History console download | Up to 200,000 events per file |
| Lake retention | One-year extendable retention: up to 10 years; seven-year retention: up to 7 years |
| Digest file delivery | Every hour |
