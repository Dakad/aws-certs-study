---
title: Task 1.1 - Monitoring and logging
domain: 1
official_task: 1.1
last_verified: 2026-10-03
sources:
  - title: AWS SOA-C03 Content Domain 1
    url: https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain1.html
---

# Task 1.1 — Monitoring and logging

**Official skills:** 1.1.1 configure monitoring/logging with CloudWatch, CloudTrail, and Managed Prometheus; 1.1.2 configure CloudWatch agent collection for EC2/ECS/EKS; 1.1.3 configure and troubleshoot alarms, composites, and actions; 1.1.4 create shareable cross-account/Region dashboards; 1.1.5 send notifications through SNS.

## Study / do

- Draw a signal path from source to collection, query/dashboard, alarm evaluation, notification, and operator response. Label metrics, logs, and API activity records.
- For an alarm, explain metric namespace/dimensions, statistic, period, threshold, evaluation windows, missing data, and action. Identify what each field cannot prove.
- Compare service telemetry with CloudWatch agent collection; identify configuration, permissions, and destination dependencies.
- Trace notification or remediation delivery across alarm/EventBridge/SNS and target permissions.

## Check

An EC2 CPU alarm is `OK` while users report high latency. Name two next signals to inspect, what each could establish, and one limitation for each. How would you verify that `OK` is based on low-CPU datapoints rather than missing-data treatment?

**Look for:** user-facing and host/downstream evidence, aligned timestamps and dimensions, and no assumption that `OK` proves application health.
