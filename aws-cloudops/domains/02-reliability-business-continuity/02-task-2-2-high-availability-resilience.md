---
title: Task 2.2 - High availability and resilience
domain: 2
official_task: 2.2
last_verified: 2026-10-03
sources:
  - title: AWS SOA-C03 Content Domain 2
    url: https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain2.html
---

# Task 2.2 — High availability and resilience

**Official skills:** 2.2.1 configure/troubleshoot ELB and Route 53 health checks; 2.2.2 implement fault-tolerant environments such as Multi-AZ deployments.

## Study / do

- Trace DNS/routing → listener → target group/health check → backend; identify signals that can disagree with user experience.
- Map instance, AZ, and dependency failure domains; identify shared components that can fail together.
- Compare single-AZ, Multi-AZ, and multi-Region choices by failure coverage, data behavior, cost, and operations.

## Check

An ALB reports every target unhealthy after deployment, though instances are running. Order checks from target health configuration through network path and application response. What separates a health-check mismatch from a failed dependency?

**Look for:** health reason, registered port/path/protocol, security/routing path, direct application behavior, and dependency signals; instance state alone is insufficient.
