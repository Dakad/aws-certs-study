---
title: Task 1.3 - Performance optimization
domain: 1
official_task: 1.3
last_verified: 2026-10-03
sources:
  - title: AWS SOA-C03 Content Domain 1
    url: https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain1.html
---

# Task 1.3 — Performance optimization

**Official skills:** 1.3.1 remediate compute using performance signals/tags/tools; 1.3.2 analyze EBS performance and volume choices; 1.3.3 apply S3 transfer, multipart, lifecycle, and access-pattern strategies; 1.3.4 select/tune EFS, FSx, or S3 Files; 1.3.5 use RDS metrics/Performance Insights/RDS Proxy; 1.3.6 optimize EC2 and attached storage/network including placement groups.

## Study / do

- For compute, storage, and database symptoms, identify measured bottleneck before proposing resizing or configuration changes; estimate cost and availability tradeoffs.
- Match EBS and shared-storage choices to I/O pattern, latency/throughput, interface, sharing, lifecycle, and access requirements.
- Match S3 transfer/caching/lifecycle behavior to object sizes and access patterns; distinguish durable storage from cache semantics.
- For RDS, separate query/resource saturation from connection pressure and state which metrics justify a change.

## Check

A database-backed service has high latency, modest EC2 CPU, and rising DB connections. Name three correlated measurements, two competing causes, and evidence needed before changing database size or connection handling. Include one cost/availability tradeoff.

**Look for:** no inference from EC2 CPU alone; distinguish query pressure from connection churn and measure before/after.
