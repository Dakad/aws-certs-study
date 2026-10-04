---
id: "elb"
kind: "service"
domains: [1, 2, 5]
services: ["elb"]
sources:
  - title: "What is Elastic Load Balancing?"
    url: "https://docs.aws.amazon.com/elasticloadbalancing/latest/userguide/what-is-load-balancing.html"
  - title: "What is an Application Load Balancer?"
    url: "https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html"
  - title: "What is a Network Load Balancer?"
    url: "https://docs.aws.amazon.com/elasticloadbalancing/latest/network/introduction.html"
  - title: "CloudWatch metrics for your Application Load Balancer"
    url: "https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-cloudwatch-metrics.html"
  - title: "CloudWatch metrics for your Network Load Balancer"
    url: "https://docs.aws.amazon.com/elasticloadbalancing/latest/network/load-balancer-cloudwatch-metrics.html"
  - title: "AWS Certified CloudOps Engineer - Associate: Domain 1"
    url: "https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain1.html"
  - title: "AWS Certified CloudOps Engineer - Associate: Domain 2"
    url: "https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain2.html"
  - title: "AWS Certified CloudOps Engineer - Associate: Domain 5"
    url: "https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain5.html"
last_verified: 2026-10-04
---

# Elastic Load Balancing

## In one paragraph

Elastic Load Balancing distributes incoming traffic across registered targets and uses target-group health checks to inform routing. Choose the load-balancer type from the traffic and routing requirement: an Application Load Balancer (ALB) evaluates HTTP application traffic and listener rules, while a Network Load Balancer (NLB) forwards Layer 4 connections and flows.

## Behavior and boundaries

- ALB listener rules can route requests using application-layer request content, including host and path conditions. NLB selects a target for its configured listener and routes an individual connection or flow to that target for its lifetime.
- Health checks are configured per target group. They determine ELB routing eligibility; they do not replace application diagnosis or independently create replacement capacity.
- ALB and NLB can route to unhealthy targets in their documented fail-open conditions, so an unhealthy-target count alone does not prove that no traffic was forwarded.

## Operational signals

- For an ALB, correlate `HealthyHostCount` and `UnHealthyHostCount` with `TargetResponseTime`, `HTTPCode_Target_5XX_Count`, and `HTTPCode_ELB_5XX_Count` to distinguish target-generated from load-balancer-generated HTTP failures.
- For an NLB, use `HealthyHostCount` and `UnHealthyHostCount` with `ActiveFlowCount`, `NewFlowCount`, `TCP_Client_Reset_Count`, `TCP_ELB_Reset_Count`, and `TCP_Target_Reset_Count` to investigate connection and reset behavior.

## Common confusion

- **Common mistake** — ALB and NLB differ only by performance characteristics.
- **Actual AWS behavior** — An ALB performs Layer 7 request routing using listener rules, while an NLB routes Layer 4 connections and flows. See [What is an Application Load Balancer?](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html) and [What is a Network Load Balancer?](https://docs.aws.amazon.com/elasticloadbalancing/latest/network/introduction.html).
- **Why it matters** — Domain 5 Task 5.3 troubleshooting and Domain 2 Task 2.2 availability decisions start with choosing the load balancer that can inspect the required traffic information.

- **Common mistake** — A target-group health check replaces unhealthy capacity automatically.
- **Actual AWS behavior** — Target-group health checks control routing eligibility; replacement capacity requires a separately configured mechanism such as an Auto Scaling group. See [What is an Application Load Balancer?](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html).
- **Why it matters** — Domain 2 Task 2.2 requires separating ELB health-based routing from the capacity mechanism needed to restore availability.

> [!IMPORTANT]
> **Concept: target-group health checks versus capacity replacement.** For SOA-C03 availability decisions, ELB health checks decide where traffic is routed, not whether a replacement target is created. Treating an unhealthy-target signal as automatic recovery can leave a workload without healthy capacity. See [What is Elastic Load Balancing?](https://docs.aws.amazon.com/elasticloadbalancing/latest/userguide/what-is-load-balancing.html).

## Exam mapping

- [Domain 1](../../../domains/01-monitoring-logging-analysis-remediation-performance-optimization/README.md): Tasks 1.1 and 1.2 (monitor and diagnose availability signals).
- [Domain 2](../../../domains/02-reliability-business-continuity/README.md): Task 2.2, Skill 2.2.1 (configure and troubleshoot ELB and Route 53 health checks).
- [Domain 5](../../../domains/05-networking-content-delivery/README.md): Task 5.3, Skill 5.3.2 (collect and interpret ELB access logs for connectivity troubleshooting).
