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
  - title: "CloudTrail Lake"
    url: "https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-lake.html"
  - title: "CloudTrail Insights"
    url: "https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-insights.html"
last_verified: 2026-10-03
---

# CloudTrail

## In one paragraph

CloudTrail records AWS API calls and account activity as events, providing an immutable audit trail for governance, compliance, and operational troubleshooting. It captures management events (control-plane) and optionally data events (S3, Lambda, DynamoDB) and network activity events (VPC endpoint).

## Behavior and boundaries

- **Management events** (control-plane): Enabled by default for 90 days in Event History; includes Create/Delete/Modify API calls, IAM actions, Console sign-ins. Read-only or write-only filtering available.
- **Data events** (data-plane): Opt-in per resource type; S3 object-level (`GetObject`, `PutObject`, `DeleteObject`), Lambda `Invoke`, DynamoDB item-level (`GetItem`, `PutItem`, `DeleteItem`, `UpdateItem`). Charged per 100k events.
- **Network activity events**: VPC endpoint DNS requests to AWS services; opt-in per VPC endpoint.
- **Trails**: Persistent delivery to S3 bucket (and optionally CloudWatch Logs). Can be single-region or multi-region (recommended). Organization trail = one trail in management account logging all member accounts.
- **Event retention**: Event History = 90 days free, no S3. Trails to S3 = unlimited (your bucket lifecycle). CloudTrail Lake = 7-year max retention.
- **Integrity validation**: SHA-256 hash chain via digest files delivered to S3 every hour; proves log integrity and detects tampering.
- **Log file encryption**: SSE-S3 (default) or SSE-KMS (customer-managed key). KMS key policy must allow CloudTrail to encrypt/decrypt.
- **Global services**: IAM, CloudFront, Route 53, WAF, STS — events delivered to trail's home region (default us-east-1 for org trails).
- **CloudTrail Lake** (separate from trails): SQL-based query engine on immutable event data store; retention up to 7 years; supports federated queries; charged per TB scanned.
- **CloudTrail Insights** (paid add-on): Detects unusual write/delete API volume patterns (e.g., spike in `TerminateInstances`, `DeleteBucket`). Runs on management events only; creates Insight events.

## Trail configuration (exam-relevant)

| Setting | Options | Recommendation |
|---------|---------|----------------|
| **Multi-region** | Yes / No | **Yes** — captures global services + regional events in one trail |
| **Organization trail** | Yes / No | Yes for multi-account; created in management account |
| **Log file validation** | Enabled / Disabled | **Enabled** — integrity proof |
| **SSE-KMS** | Enabled / Disabled | Enabled for compliance; key policy must allow `cloudtrail.amazonaws.com` |
| **CloudWatch Logs delivery** | Enabled / Disabled | Enables metric filters/alarms on API activity |
| **SNS notifications** | Enabled / Disabled | Notifies on log file delivery (every ~5 min) |
| **Data event selectors** | Per resource (S3/Lambda/DynamoDB) | Add only high-value resources; cost per 100k events |

## Operational signals

- **Event History**: Console/searchable 90-day window; filter by resource, user, event name, time, error code. No SQL, no export.
- **Trail to CloudWatch Logs**: Enables metric filters and alarms on API activity (e.g., `ConsoleLogin` failures, `DeleteBucket`, `AttachRolePolicy`).
- **Trail to S3**: Long-term storage; query with Athena, feed to Security Hub, GuardDuty, or SIEM. JSON lines, gzipped.
- **CloudTrail Lake**: SQL queries on event data store; supports `SELECT`, `JOIN`, aggregations; retention 30 days–7 years.
- **Insights** (paid): Detects unusual write/delete API patterns; creates `AwsCloudTrailInsight` events; viewable in console.

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

- **Event History ≠ Trail** — History is 90-day rolling window, no S3 delivery, no data events. Trail = persistent, configurable, S3 delivery.
- **Data events are not free** — Charged per 100k events; enable only what you need. Advanced selectors reduce cost by filtering.
- **Global services log to us-east-1** — If your trail is in eu-west-1, IAM/CloudFront/Route 53 events still appear there (delivered to trail's S3 bucket).
- **AccessDenied appears in CloudTrail** — `errorCode: "AccessDenied"` + `requestParameters` shows exactly what was attempted. This is the primary evidence for `AccessDenied` diagnosis.
- **Trail vs. Organization trail** — Org trail logs all member accounts to a central bucket; created in management account; member accounts cannot disable it.
- **Multi-region trail vs. single-region** — Single-region misses global service events and events in other regions. Multi-region is best practice.
- **CloudTrail Lake ≠ Trail + Athena** — Lake is a managed query engine with fixed schema, immutable store, and pay-per-TB-scanned. Athena queries raw S3 files.
- **Insights only on management events** — Does not analyze data events or network activity events.
- **Log file delivery ≠ real-time** — Files delivered ~every 5 minutes; CloudWatch Logs delivery similar latency. Not for sub-minute alerting.

## Exam mapping

- [Domain 1: Monitoring, Logging, Analysis, Remediation](../domains/01-monitoring-logging-analysis-remediation-performance-optimization/README.md) — Task 1.1 (audit logging)
- [Domain 4: Security and Compliance](../domains/04-security-compliance/README.md) — Task 4.1 (access auditing, CloudTrail evidence)

## Must-remember numbers

| Figure | Value |
|--------|-------|
| Event History retention | 90 days |
| Max trails per region | 5 (per account) |
| Max organization trails | 1 per organization |
| Data event cost | $0.10 per 100k events |
| Insights cost | $0.35 per 100k management events analyzed |
| Lake retention | 30 days – 7 years |
| Lake query cost | $0.005 per GB scanned |
| Digest file delivery | Every hour |
| Log file delivery | ~Every 5 minutes |

## Related nodes

- [CloudWatch](../services/cloudwatch/README.md) — integrates-with (Log delivery, metric filters)
- [S3](../services/s3/README.md) — integrates-with (Trail bucket)
- [SNS](../services/sns/README.md) — integrates-with (Delivery notifications)
- [KMS](../services/kms/README.md) — secured-by (SSE-KMS on trail bucket)
- [Config](../services/config/README.md) — audited-by (Config uses CloudTrail for compliance timeline)
- [Organizations](../services/organizations/README.md) — integrates-with (Org trail)
- [Security Hub](../services/securityhub/README.md) — integrates-with (Findings ingestion)
- [GuardDuty](../services/guardduty/README.md) — integrates-with (Threat detection uses CloudTrail)