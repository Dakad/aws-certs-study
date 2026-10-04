---
id: "cloudwatch"
kind: "service"
domains: [1]
services: ["cloudwatch"]
related:
  - relation: "collects-metrics-from"
    target: "ec2"
  - relation: "collects-metrics-from"
    target: "s3"
  - relation: "collects-metrics-from"
    target: "rds"
  - relation: "collects-metrics-from"
    target: "lambda"
  - relation: "collects-metrics-from"
    target: "elb"
  - relation: "integrates-with"
    target: "eventbridge"
  - relation: "automated-by"
    target: "ssm-automation"
  - relation: "notifies-via"
    target: "sns"
  - relation: "integrates-with"
    target: "cloudtrail"
sources:
  - title: "AWS Certified CloudOps Engineer Associate - Domain 1"
    url: "https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain1.html"
  - title: "CloudWatch Alarm Actions"
    url: "https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/alarm-actions.html"
  - title: "CloudWatch Missing Data Treatment"
    url: "https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/alarms-and-missing-data.html"
  - title: "CloudWatch Alarms - Evaluation Window"
    url: "https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/alarm-evaluation-window.html"
  - title: "CloudWatch Agent"
    url: "https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Install-CloudWatch-Agent.html"
  - title: "CloudWatch Metrics Concepts and Retention"
    url: "https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/cloudwatch_concepts.html"
  - title: "CloudWatch Service Quotas"
    url: "https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/cloudwatch_limits.html"
  - title: "Amazon EBS CloudWatch Metrics"
    url: "https://docs.aws.amazon.com/ebs/latest/userguide/using_cloudwatch_ebs.html"
  - title: "Application Load Balancer CloudWatch Metrics"
    url: "https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-cloudwatch-metrics.html"
  - title: "Network Load Balancer CloudWatch Metrics"
    url: "https://docs.aws.amazon.com/elasticloadbalancing/latest/network/load-balancer-cloudwatch-metrics.html"
  - title: "Composite Alarms"
    url: "https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/composite-alarms.html"
last_verified: 2026-10-04
---

# CloudWatch

## In one paragraph

CloudWatch is the primary observability service for AWS, providing metrics, logs, alarms, and dashboards to monitor the health and performance of infrastructure and applications. It collects and tracks metrics, collects and monitors log files, sets alarms, and automatically reacts to changes in AWS resources.

## Behavior and boundaries

- Not just a dashboard; it is an engine for state tracking.
- Alarms respond to transitions (OK/ALARM/INSUFFICIENT_DATA) — actions fire only on state change, not while state persists.
- Does not act automatically unless an action (SNS, Lambda, SSM Automation, EC2, Auto Scaling, Incident Manager) is configured.
- Multi-step logic (M-of-N, "Datapoints to Alarm" out of "Evaluation Periods") evaluates alarm state across multiple datapoints.
- Missing data treatment is configurable: `missing` (default), `notBreaching`, `breaching`, `ignore`.
- Evaluation range: CloudWatch retrieves more datapoints than Evaluation Periods (wider window) to handle missing data; exact count depends on period and resolution.
- Standard-resolution metrics have one-minute granularity. Five-minute intervals are service-specific publishing cadences, such as EC2 basic monitoring.
- High-resolution custom metric data is retained for 3 hours; data at 1-minute resolution for 15 days, 5-minute resolution for 63 days, and 1-hour resolution for 455 days. See [CloudWatch metrics concepts and retention](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/cloudwatch_concepts.html).

## Alarm configuration (must-know fields)

| Field | Purpose | Exam relevance |
|-------|---------|----------------|
| **Namespace** | Container for metrics (e.g., `AWS/EC2`, `AWS/RDS`) | Identifies service |
| **MetricName** | What is measured (e.g., `CPUUtilization`, `DatabaseConnections`) | Must match service |
| **Dimensions** | Key-value pairs to filter (e.g., `InstanceId=i-123`) | Alarms are per-dimension |
| **Statistic** | Aggregation: `Average`, `Sum`, `SampleCount`, `Minimum`, `Maximum`, `pNN.NN` | `Average` most common for utilization |
| **Period** | Length of each datapoint (10s, 30s, 1m, 5m, etc.) | Must align with metric resolution |
| **Evaluation Periods** | Number of recent periods to evaluate (N in M-of-N) | Total window = Period × Evaluation Periods |
| **Datapoints to Alarm** | How many of those periods must breach (M in M-of-N) | M ≤ N |
| **Threshold** | Value to compare against | Numeric |
| **ComparisonOperator** | `GreaterThanOrEqualToThreshold`, `GreaterThanThreshold`, `LessThanThreshold`, `LessThanOrEqualToThreshold`, `LessThanLowerOrGreaterThanUpperThreshold`, `LessThanLowerThreshold`, `GreaterThanUpperThreshold` | Includes anomaly detection bands |
| **TreatMissingData** | `missing`, `notBreaching`, `breaching`, `ignore` | Default `missing` |
| **AlarmActions / OKActions / InsufficientDataActions** | ARNs for SNS, Lambda, EC2, ASG, SSM, Incident Manager | Only fire on transition |

## Operational signals

- **Metrics**: Standard-resolution metrics have 1-minute granularity; some services publish on a 5-minute cadence, and high-resolution custom metrics have 1-second granularity.
- **Logs**: CloudWatch Logs — log groups, log streams, retention (1 day to 10 years, or never expire).
- **Log Insights**: Query language for log analysis; can create metric filters from log patterns.
- **Metric Filters**: Turn log data into numerical metrics (e.g., count ERROR lines).
- **Alarms**: Single-metric, metric math expression, or composite (AND/OR/NOT of other alarms).
- **Composite Alarms**: Combine multiple alarms; reduce noise; only ALARM state triggers actions.
- **Anomaly Detection**: ML-based expected value bands; alarm when metric goes outside band.
- **Dashboards**: Cross-account, cross-region; markdown widgets, text, metric graphs, alarm status.
- **CloudWatch Agent**: Collects system-level metrics (memory, disk, swap, processes) and logs from EC2, on-premises servers, and containerized applications. Systems Manager Parameter Store is an optional configuration source.
- **Metric Streams**: Near-real-time delivery of metrics to destinations (S3, Firehose, third-party).
- **Cross-account observability**: Central monitoring account links source accounts via CloudWatch observability access manager.

## Key metrics by service (exam-relevant)

| Service | Namespace | Critical metrics |
|---------|-----------|------------------|
| EC2 | `AWS/EC2` | `CPUUtilization`, `StatusCheckFailed`, `StatusCheckFailed_Instance`, `StatusCheckFailed_System`, `NetworkIn/Out`, `DiskReadOps/WriteOps`, `CPUCreditUsage/Balance` (T-class) |
| EBS | `AWS/EBS` | `VolumeReadOps/WriteOps`, `VolumeReadBytes/WriteBytes`, `VolumeTotalReadTime/WriteTime`, `VolumeIdleTime`, `BurstBalance` (`gp2`, `st1`, and `sc1` only) |
| RDS | `AWS/RDS` | `CPUUtilization`, `DatabaseConnections`, `FreeableMemory`, `FreeStorageSpace`, `ReadIOPS/WriteIOPS`, `ReadLatency/WriteLatency`, `ReplicaLag`, `SwapUsage` |
| ALB | `AWS/ApplicationELB` | `RequestCount`, `TargetResponseTime`, `HTTPCode_Target_2XX/4XX/5XX_Count`, `HTTPCode_ELB_4XX/5XX_Count`, `HealthyHostCount`, `UnHealthyHostCount`, `TargetConnectionErrorCount` |
| NLB | `AWS/NetworkELB` | `ActiveFlowCount`, `NewFlowCount`, `ProcessedBytes`, `TCP_Client/ELB/Target_Reset_Count`, `HealthyHostCount`, `UnHealthyHostCount` |
| Lambda | `AWS/Lambda` | `Invocations`, `Errors`, `Duration`, `Throttles`, `ConcurrentExecutions`, `ProvisionedConcurrentExecutions`, `IteratorAge` (stream) |
| S3 | `AWS/S3` | `BucketSizeBytes`, `NumberOfObjects`, `AllRequests`, `GetRequests`, `PutRequests`, `4xxErrors`, `5xxErrors`, `FirstByteLatency` |
| Auto Scaling | `AWS/AutoScaling` | `GroupMinSize`, `GroupMaxSize`, `GroupDesiredCapacity`, `GroupInServiceInstances`, `GroupTotalInstances` |
| VPN/DX | `AWS/VPN`, `AWS/DX` | `TunnelState`, `TunnelDataIn/Out` |

## Alarm actions detail

| Action type | Supported on | Notes |
|-------------|--------------|-------|
| SNS notification | All alarm types | Contributor-level for multi-time-series |
| Lambda invocation | All alarm types | Payload includes alarm data; async |
| EC2 action (stop/terminate/reboot/recover) | EC2 metric alarms only | Requires `EC2ActionsAccess` role; recover only on impaired host |
| Auto Scaling scaling policy | EC2 metric alarms, custom metrics | Step/simple scaling; target tracking uses separate policy type |
| SSM OpsItem creation | Metric alarms, composite alarms | Alarm-level only |
| Incident Manager incident | Metric alarms, composite alarms | Alarm-level only |
| CloudWatch Investigation | Metric alarms only | Alarm-level only |
| EventBridge event | All alarms | Emitted on every state change; enables custom routing |

> [!IMPORTANT]
> **Concept: EC2 alarm actions.** For SOA-C03 remediation selection, stop, terminate, reboot, and recover actions work only on metric alarms that watch `AWS/EC2` metrics. Choosing one for a custom or other-service metric leaves the intended remediation unable to run. See [CloudWatch Alarm Actions](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/alarm-actions.html).

## Common confusion

- **Common mistake** — “No actions” means the alarm is not evaluating, or it explains the alarm state.
- **Actual AWS behavior** — “No actions” only means that no action ARN is configured; the alarm still evaluates and changes state, but nothing fires on a transition. See [CloudWatch Alarm Actions](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/alarm-actions.html).
- **Why it matters** — Domain 1 Task 1.1 requires selecting and interpreting alarm configuration without confusing notification/remediation setup with the monitored condition.

- **Common mistake** — A valid non-breaching datapoint is missing data, so missing-data treatment decides the result.
- **Actual AWS behavior** — A datapoint below a `>=` threshold is present and non-breaching; when enough real datapoints fill the M-of-N evaluation window, CloudWatch does not apply missing-data treatment. See [CloudWatch Missing Data Treatment](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/alarms-and-missing-data.html).
- **Why it matters** — Domain 1 Task 1.1 alarm-state questions depend on counting breaching datapoints correctly; treating a valid low value as missing can produce the wrong `OK`, `ALARM`, or `INSUFFICIENT_DATA` conclusion.

- **Common mistake** — A short alarm period makes standard-resolution metrics more granular.
- **Actual AWS behavior** — A 10-second alarm period requires high-resolution metric data; it does not resample a one-minute datapoint. See [CloudWatch metrics concepts and retention](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/cloudwatch_concepts.html).
- **Why it matters** — Domain 1 Task 1.1 requires an alarm period that matches the available metric resolution, or the alarm cannot provide the intended detection speed.

- **Common mistake** — Composite alarms and metric-math alarms are interchangeable ways to combine metrics.
- **Actual AWS behavior** — A composite alarm applies boolean logic to other alarms, while a metric-math alarm evaluates an expression; composite alarms can suppress action noise. See [Composite Alarms](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/composite-alarms.html).
- **Why it matters** — Domain 1 Task 1.2 scenarios distinguish a calculated operational threshold from alarm-level gating of notifications or remediation.

## Exam mapping

- [Domain 1: Monitoring, Logging, Analysis, Remediation, and Performance Optimization](../../../domains/01-monitoring-logging-analysis-remediation-performance-optimization/README.md)
  - Task 1.1: Implement metrics, alarms, and filters (Skills 1.1.1–1.1.5)
  - Task 1.2: Identify and remediate issues (Skills 1.2.1–1.2.3)
  - Task 1.3: Performance optimization (Skills 1.3.1–1.3.6)

## Must-remember numbers

| Figure | Value | SOA-C03 decision and source |
|--------|-------|------------------------------|
| Standard-resolution metric granularity | 1 minute | Select an alarm period that the metric can support. See [CloudWatch metrics concepts and retention](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/cloudwatch_concepts.html). |
| High-resolution custom metric granularity | 1 second | Required when the scenario needs a 10-second alarm period. See [CloudWatch metrics concepts and retention](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/cloudwatch_concepts.html). |

## Good to know

| Figure | Value | Operational context and source |
|--------|-------|--------------------------------|
| Metric retention | 15 months | Metrics are downsampled over time. See [CloudWatch metrics concepts and retention](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/cloudwatch_concepts.html). |
| High-resolution custom metric retention | 3 hours | One-minute data is retained for 15 days, five-minute data for 63 days, and one-hour data for 455 days. See [CloudWatch metrics concepts and retention](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/cloudwatch_concepts.html). |
| Maximum alarm evaluation periods | 1,000 | Applies to high-resolution alarms. See [CloudWatch Service Quotas](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/cloudwatch_limits.html). |
| Maximum metrics per `GetMetricData` call | 500 | Per call. See [CloudWatch Service Quotas](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/cloudwatch_limits.html). |
| Maximum dashboards per account | 500 | Soft limit. See [CloudWatch Service Quotas](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/cloudwatch_limits.html). |
| Maximum log groups per account | 1,000,000 | See [CloudWatch Service Quotas](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/cloudwatch_limits.html). |
| Maximum metric filters per log group | 100 | See [CloudWatch Service Quotas](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/cloudwatch_limits.html). |
| `PutMetricData` request rate | 500 requests/second | Per account and Region; adjustable. See [CloudWatch Service Quotas](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/cloudwatch_limits.html). |
| Anomaly detection training window | Up to 2 weeks | See [CloudWatch metrics concepts and retention](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/cloudwatch_concepts.html). |
| Alarm history retention | 14 days | See [CloudWatch Alarm Actions](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/alarm-actions.html). |
