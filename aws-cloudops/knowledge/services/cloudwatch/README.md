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
- High-resolution custom metric data is retained for 3 hours; data at 1-minute resolution for 15 days, 5-minute resolution for 63 days, and 1-hour resolution for 455 days.

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
> EC2 actions (stop/terminate/reboot/recover) **only work on alarms watching EC2 metrics** (`AWS/EC2` namespace). They do not work on custom metrics or other service metrics.

## Common confusion

- **"No actions" on an alarm** → This is an action-configuration label, not the alarm's state reason. The alarm still evaluates and changes state; it simply has no configured SNS/Lambda/EC2/ASG action to fire on transition.
- **Missing data vs. non-breaching data** → A valid low datapoint (e.g., 78% on a >=80% threshold) is *not* missing data. With M-of-N, if enough real datapoints exist to fill the evaluation window, the missing-data treatment is ignored entirely.
- **INSUFFICIENT_DATA at creation** → Normal behavior ("Initial alarm creation"); transitions to OK/ALARM once enough datapoints are available.
- **Premature ALARM transitions** → CloudWatch avoids false alarms when the oldest breaching datapoint in the evaluation range is at least as old as M (Datapoints to Alarm) and all newer points are breaching or missing — even if total points < M.
- **Alarm period vs. metric resolution** → A 10-second alarm period requires high-resolution data; it does not resample a one-minute datapoint.
- **Composite alarm vs. metric math alarm** → Composite = boolean logic (AND/OR/NOT) over *other alarms*; metric math = single alarm evaluating an expression (e.g., `m1/m2 * 100`). Composite reduces action noise.
- **Anomaly detection bands** → Use `LessThanLowerOrGreaterThanUpperThreshold` operator; model trains on up to 2 weeks of data; not suitable for sparse or highly seasonal metrics without tuning.
- **Cross-account dashboards** → Requires CloudWatch cross-account observability enabled; source accounts share metrics/logs with monitoring account via sink.

## Exam mapping

- [Domain 1: Monitoring, Logging, Analysis, Remediation, and Performance Optimization](../../../domains/01-monitoring-logging-analysis-remediation-performance-optimization/README.md)
  - Task 1.1: Implement metrics, alarms, and filters (Skills 1.1.1–1.1.5)
  - Task 1.2: Identify and remediate issues (Skills 1.2.1–1.2.3)
  - Task 1.3: Performance optimization (Skills 1.3.1–1.3.6)

## Must-remember numbers

| Figure | Value | Context |
|--------|-------|---------|
| Max metric retention | 15 months | Downsampled over time |
| Max alarm evaluation periods | 1,000 | For high-res alarms |
| Max metrics per GetMetricData | 500 | Per call |
| Max dashboards per account | 500 | Soft limit |
| Max log groups per account | 1,000,000 | |
| Max metric filters per log group | 100 | |
| `PutMetricData` request rate | 500 requests/second | Per account/Region; adjustable |
| Anomaly detection training window | Up to 2 weeks | |
| Alarm history retention | 14 days | |
