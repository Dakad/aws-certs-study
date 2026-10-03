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

- **Monitoring and audit:** Amazon CloudWatch (metrics, alarms, dashboards, agent), AWS CloudTrail, Amazon Managed Service for Prometheus, and Amazon SNS.
- **Remediation and event routing:** Amazon EventBridge, AWS Lambda, AWS Systems Manager Automation, AWS DevOps Agent, and Kiro (as named in the current objective).
- **Performance:** Amazon EC2 and placement groups, Amazon EBS, Amazon S3 (including lifecycle and transfer features), AWS DataSync, Amazon EFS, Amazon FSx, Amazon S3 Files, Amazon RDS, and RDS Proxy.

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
- Status: Learning — initial diagnostic, CLI alarm creation, and Console inspection completed; IaC comparison and further practice remain.
- Questions/practice evidence (2026-09-28): Given rising API latency and HTTP 5xx with normal EC2 CPU, proposed checking VPC Flow Logs and EC2 logs, using `curl` to inspect response headers/body, and using `dig` conditionally if the hostname fails to resolve.
- Strengths observed: Started from the user-visible symptom; suggested gathering response evidence; considered both application and infrastructure layers; made DNS checking conditional rather than automatic.
- Correction to practice: An HTTP 5xx means an HTTP-speaking server-side component returned an error; it does not by itself identify the application, load balancer, gateway, or CDN as the source. If a 5xx response is received, basic DNS and transport worked for that request, so first correlate the response/request ID with service metrics and logs across the actual request path. VPC Flow Logs show IP-flow metadata and accept/reject status, not HTTP headers, body, or application errors; use them when connection/path evidence is in question. Normal CPU rules out only the CPU saturation hypothesis, not memory, disk, thread/connection pools, throttling, dependencies, or unhealthy targets.
- Mistake/uncertainty to revisit: Chose VPC Flow Logs early before establishing that network reachability was failing; follow-up pending to distinguish a load-balancer-generated 5xx from a target-generated 5xx.
- CLI lab (2026-09-28): Created temporary alarm `codex-study-cpu-high-ec2-lab` on an EC2 `CPUUtilization` metric. It evaluates 5-minute averages, requires 2 of 2 datapoints >=80%, treats missing data as not breaching, and has actions disabled. No instance settings or application were changed.
- Observed evidence: Playground identity was verified. The alarm initially reported `INSUFFICIENT_DATA` with reason “Initial alarm creation,” then transitioned to `OK` after evaluation using two non-breaching datapoints. This demonstrates that `INSUFFICIENT_DATA` at creation is not necessarily a fault and that alarm state is based on configured evaluation periods.
- Console check (2026-10-03): Screenshots show the alarm in `OK`; `AWS/EC2` / `CPUUtilization`, `Average`, 5-minute period, threshold `>= 80`, 2 of 2 datapoints within 10 minutes, missing data treated as good/not breaching, and “No actions.” The Details view's “No actions” is an action-configuration label, not the alarm's state reason. History shows a state update from `INSUFFICIENT_DATA` to `OK` at 2026-09-28 19:37:40 UTC; it does not give a more detailed cause. The learner then inspected the graph for 19:00–20:29 UTC and reported a continuous line below 2%, no missing datapoints, and a displayed 1.54% datapoint around 19:40 UTC. This supports the alarm evaluating `OK` from observed non-breaching CPU in the reviewed period rather than relying on the missing-data fallback. “OK” does not establish overall instance or application health. See [CloudWatch alarm actions](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/alarm-actions.html) and [CloudWatch missing data treatment](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/alarms-and-missing-data.html).
- M-of-N retrieval (2026-10-03): When asked what 2-of-2 means, the learner was initially unsure and predicted an 85% 5-minute average followed by 15% would trigger. Correction: for this alarm, both of the two 5-minute Average datapoints must be >=80%; one breaching period out of two does not meet 2-of-2. In the immediate follow-up, the learner correctly answered that 83% and 85% would trigger, citing the >=80 threshold. This shows threshold application after the explanation in this exchange, not independent mastery; revisit with a fresh mixed pair and ask the learner to explain the count condition.
- M-of-N retrieval, mixed datapoints (2026-10-03): Given two present readings of 84% and 78% for a 2-of-2 alarm at >=80%, the learner correctly noticed that 78% does not breach the threshold but classified the state as `INSUFFICIENT_DATA`. Correction: with both datapoints present, one breaching and one non-breaching means the 2-of-2 condition is false, so the alarm remains `OK`; `INSUFFICIENT_DATA` is not the result of a valid low reading. Threshold recognition is emerging, while distinguishing non-breaching data from missing/unavailable data needs another check.
- M-of-N immediate retest (2026-10-03): For two present readings of 84% and 81%, the learner correctly answered `ALARM` because both breach `>=80%` and M=2 is met. This is correct application immediately after the correction; continue Domain 1 rather than treating one coached retest as durable mastery.
- Guided signal selection (2026-10-03): Given rising `HTTPCode_Target_5XX_Count` with `HTTPCode_ELB_5XX_Count` at zero, selected application/target logs. Correctly identified that the target, rather than the ALB, generated the 5xx. Refinement: this does not prove there is no network issue, and “target” is not necessarily a single EC2 application; trace the configured target type and any downstream dependency.
- Lab-safety correction: The screenshot confirms the alarm is attached to an existing EC2 workload, not a dedicated disposable study instance. No AWS changes were made. Do not update, delete, import, or apply IaC against this alarm as a lab target.
- OpenTofu comparison: Pending. Use the observed settings to learn the HCL shape without applying to this existing resource. Any future end-to-end CLI → Console → OpenTofu lab should use a separate disposable resource/account after authentication, scope, cost, and cleanup are clear.
- Next action: Continue Domain 1 with a signal-selection scenario: distinguish a metric that quantifies an error rate over time from logs that expose details for one failing request. Later, separately test missing-data treatment. Keep this existing-workload alarm read-only and do not import, edit, apply IaC to, or delete it.
