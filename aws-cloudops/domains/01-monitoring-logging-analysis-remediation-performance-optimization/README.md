# Domain 1 — Monitoring, Logging, Analysis, Remediation, and Performance Optimization

**Exam weight:** 22% of scored content  
**Status:** Learning  
**Official objective:** [AWS Domain 1 guide](https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain1.html) (scope checked 2026-10-03)

## What this domain is about
Operate workloads by observing useful signals, finding the cause of unhealthy behavior, restoring service, and improving performance without wasting resources. The exam expects you to distinguish metrics from logs and events, choose a useful alarm or filter, interpret what monitoring data does and does not prove, and select an appropriate remediation or optimization.

## Official task areas and study guides

| Official task | What to study | Task guide |
|---|---|---|
| **1.1 — Implement metrics, alarms, and filters using AWS monitoring and logging services** | CloudWatch, CloudTrail, Managed Prometheus, CloudWatch agent, alarm configuration/actions, dashboards, and SNS notification paths. | [Monitoring and logging](01-task-1-1-monitoring-logging.md) |
| **1.2 — Identify and remediate issues using monitoring and availability metrics** | Evidence-led diagnosis, performance/availability signals, EventBridge routing, and bounded Systems Manager Automation or other remediation. | [Analysis and remediation](02-task-1-2-remediation.md) |
| **1.3 — Implement performance optimization strategies for compute, storage, and database resources** | Compute, EBS, S3, shared storage, RDS, and EC2 signals; changes should fit the measured bottleneck and cost constraints. | [Performance optimization](03-task-1-3-performance.md) |

Use the [Domain 1 contexts index](contexts/README.md) for reusable scenarios. The task guides provide practice and a check for understanding; learner results remain in the progress notes below and [`PROGRESS.md`](../../../PROGRESS.md).

## Services
The service list follows the [official Domain 1 objectives](https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain1.html); examples are exam-scope coverage, not an exhaustive AWS catalog.

- **Monitoring and audit:** [Amazon CloudWatch](../../knowledge/services/cloudwatch/README.md) (metrics, alarms, dashboards, agent), [AWS CloudTrail](../../knowledge/services/cloudtrail/README.md), Amazon Managed Service for Prometheus, and [Amazon SNS](../../knowledge/services/sns/README.md).
- **Remediation and event routing:** [Amazon EventBridge](../../knowledge/services/eventbridge/README.md), [AWS Lambda](../../knowledge/services/lambda/README.md), [AWS Systems Manager Automation](../../knowledge/services/ssm-automation/README.md), AWS DevOps Agent, and Kiro (as named in the current objective).
- **Performance:** [Amazon EC2](../../knowledge/services/ec2/README.md) and placement groups, Amazon EBS, [Amazon S3](../../knowledge/services/s3/README.md) (including lifecycle and transfer features), AWS DataSync, Amazon EFS, Amazon FSx, Amazon S3 Files, [Amazon RDS](../../knowledge/services/rds/README.md), and RDS Proxy.

### Cross-service impacts
Monitoring and CloudTrail evidence help diagnose compute, storage, database, and network incidents; EventBridge/Lambda/Systems Manager can automate remediation but depend on appropriately scoped IAM permissions (see [Domain 3](../03-deployment-provisioning-automation/README.md) and [Domain 4](../04-security-compliance/README.md)). Performance changes to compute, storage, databases, or network paths can alter availability, recovery needs, and cost (see [Domain 2](../02-reliability-business-continuity/README.md) and [Domain 5](../05-networking-content-delivery/README.md)). Treat these as study connections, not claims that one service automatically configures another.

## Learning targets
- Explain when to use metrics, logs, traces/events, and audit history.
- Work through a symptom from alarm → related metrics/logs/events → likely cause → safe remediation → verification.
- Understand CloudWatch alarm states and why missing data, dimensions, periods, and thresholds matter.
- Compare representative storage/compute/database optimization choices using evidence rather than guesswork.

## Practice and evidence
- **CLI:** inspect metrics/alarms/log groups and retrieve targeted evidence.
- **Console:** navigate from an alarm or dashboard to the underlying signal and resource.
- **IaC:** where useful, define a small alarm/dashboard/logging example with OpenTofu; review the plan before any apply.
- **Demonstrated when:** independently diagnose a new monitoring scenario, state what evidence supports the conclusion, and select a proportionate fix and verification.

### Progress notes
- **Status:** Learning. Alarm observation and Console inspection completed; no disposable IaC comparison yet.
- **Durable evidence:** Applied the observed 2-of-2 alarm settings after correction; guided target-versus-ALB response-origin signal selection completed.
- **Next study:** Independently diagnose a fresh symptom with metrics, logs, and CloudTrail as appropriate; later revisit missing-data treatment. The existing workload alarm remains read-only.
