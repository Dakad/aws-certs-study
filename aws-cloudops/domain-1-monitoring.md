# Domain 1 — Monitoring, Logging, Analysis, Remediation, and Performance Optimization

**Exam weight:** 22% of scored content  
**Status:** Learning  
**Official objective:** [AWS Domain 1 guide](https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain1.html)

## What this domain is about

Operate workloads by observing useful signals, finding the cause of unhealthy behavior, restoring service, and improving performance without wasting resources. The exam expects you to distinguish metrics from logs and events, choose a useful alarm or filter, interpret what monitoring data does and does not prove, and select an appropriate remediation or optimization.

## Official task areas

- **1.1 — Metrics, alarms, and filters:** Configure monitoring and logging; use CloudWatch and CloudTrail; collect host/container signals with the CloudWatch agent; reason about alarm states/actions, dashboards, EventBridge, and SNS notifications.
- **1.2 — Identify and remediate issues:** Use performance and availability metrics, events, Systems Manager Automation, Lambda, or other appropriate automation to diagnose and remediate operational problems.
- **1.3 — Performance optimization:** Interpret compute, EBS, S3, shared-storage, RDS, and EC2 performance signals; choose changes that improve efficiency while accounting for cost and workload behavior.

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

- Status: Learning — initial diagnostic plus first CloudWatch alarm lab started; Console and IaC portions remain.
- Questions/practice evidence (2026-09-28): Given rising API latency and HTTP 5xx with normal EC2 CPU, proposed checking VPC Flow Logs and EC2 logs, using `curl` to inspect response headers/body, and using `dig` conditionally if the hostname fails to resolve.
- Strengths observed: Started from the user-visible symptom; suggested gathering response evidence; considered both application and infrastructure layers; made DNS checking conditional rather than automatic.
- Correction to practice: An HTTP 5xx means an HTTP-speaking server-side component returned an error; it does not by itself identify the application, load balancer, gateway, or CDN as the source. If a 5xx response is received, basic DNS and transport worked for that request, so first correlate the response/request ID with service metrics and logs across the actual request path. VPC Flow Logs show IP-flow metadata and accept/reject status, not HTTP headers, body, or application errors; use them when connection/path evidence is in question. Normal CPU rules out only the CPU saturation hypothesis, not memory, disk, thread/connection pools, throttling, dependencies, or unhealthy targets.
- Mistake/uncertainty to revisit: Chose VPC Flow Logs early before establishing that network reachability was failing; follow-up pending to distinguish a load-balancer-generated 5xx from a target-generated 5xx.
- CLI lab (2026-09-28): Created temporary alarm `codex-study-cpu-high-ec2-lab` on an EC2 `CPUUtilization` metric. It evaluates 5-minute averages, requires 2 of 2 datapoints >=80%, treats missing data as not breaching, and has actions disabled. No instance settings or application were changed.
- Observed evidence: Playground identity was verified. The alarm initially reported `INSUFFICIENT_DATA` with reason “Initial alarm creation,” then transitioned to `OK` after evaluation using two non-breaching datapoints. This demonstrates that `INSUFFICIENT_DATA` at creation is not necessarily a fault and that alarm state is based on configured evaluation periods.
- Console check: Not completed by the tutor because browser UI access to Firefox was not approved and the in-app browser tab could not be created. Console path for this alarm: CloudWatch → Alarms → All alarms → `codex-study-cpu-high-ec2-lab`; compare metric, dimension, threshold, evaluation periods, missing-data handling, and actions-enabled state with the CLI.
- OpenTofu recreation and cleanup: Pending. Keep this temporary alarm only through the comparison exercise, then delete it and verify removal.
- Next action: Inspect the alarm in the Console; then recreate the same alarm in a disposable OpenTofu lab configuration, compare the plan/configuration to the CLI-created alarm, and clean up.
