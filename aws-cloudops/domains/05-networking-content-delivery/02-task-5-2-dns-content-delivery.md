---
title: Task 5.2 - DNS and content delivery
domain: 5
official_task: 5.2
last_verified: 2026-10-03
sources:
  - title: AWS SOA-C03 Content Domain 5
    url: https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain5.html
---

# Task 5.2 — DNS and content delivery

**Official skills:** 5.2.1 configure DNS including Route 53 Resolver; 5.2.2 configure Route 53 policies, hosted zones, and query logging; 5.2.3 distribute content/services with CloudFront or Global Accelerator.

## Study / do

- Trace client resolver to recursive resolver and authoritative answer, including private zones and Resolver forwarding rules.
- Compare routing policy decisions, health inputs, and the effect of TTL/cached records on failover.
- Compare CloudFront and Global Accelerator by traffic type, edge behavior, caching, and origin/service path.
- For stale/wrong content, inspect DNS answer, cache key/TTL, origin headers/health, and access logs to distinguish cache from origin problems.

## Check

One network resolves a service to a different IP than others. Sequence checks for resolver/cache/TTL, private-zone association, forwarding rules, and authoritative policy. What does `dig` prove—and not prove?

**Look for:** identify which resolver answered and the returned record/TTL; successful DNS resolution does not demonstrate application reachability.
