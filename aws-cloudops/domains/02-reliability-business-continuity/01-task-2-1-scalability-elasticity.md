---
title: Task 2.1 - Scalability and elasticity
domain: 2
official_task: 2.1
last_verified: 2026-10-03
sources:
  - title: AWS SOA-C03 Content Domain 2
    url: https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain2.html
---

# Task 2.1 — Scalability and elasticity

**Official skills:** 2.1.1 configure/manage compute scaling; 2.1.2 use AWS caching such as CloudFront/ElastiCache to support dynamic scalability; 2.1.3 configure/manage scaling in RDS and DynamoDB.

## Study / do

- For a request-driven system, name the scaling signal, capacity response, warm-up/cool-down, limit, and failure if capacity lags demand.
- Compare horizontal/vertical scaling and elastic/planned capacity. Explain what cache layer removes repeated work and its freshness/correctness risk.
- Distinguish compute scaling from managed database scaling; identify remaining bottlenecks and verification signals.

## Check

Traffic doubles, instances scale out, but latency rises. Which three measurements would you correlate across load balancer, compute, and database/cache? What evidence suggests more EC2 capacity is not the answer?

**Look for:** request/latency and healthy capacity by tier, scaling activity, plus downstream saturation or connection/throughput ceilings.
