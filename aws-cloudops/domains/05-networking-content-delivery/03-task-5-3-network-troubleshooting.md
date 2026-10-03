---
title: Task 5.3 - Network troubleshooting
domain: 5
official_task: 5.3
last_verified: 2026-10-03
sources:
  - title: AWS SOA-C03 Content Domain 5
    url: https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain5.html
---

# Task 5.3 — Network troubleshooting

**Official skills:** 5.3.1 troubleshoot VPC/subnet/routes/NACL/SG/Transit Gateway/NAT; 5.3.2 use VPC Flow, ELB, WAF, CloudFront, and container logs; 5.3.3 diagnose CloudFront caching; 5.3.4 troubleshoot hybrid/private connectivity; 5.3.5 configure/analyze CloudWatch network monitoring.

## Study / do

- Record source, destination, protocol/port, timestamp, and expected path. Check DNS, route, filtering, connection, listener/target, application, return path.
- Distinguish Flow Logs acceptance/rejection from packet capture and application logs; verify interface, fields, and time window before inferring.
- Compare ELB, WAF, CloudFront, and container logs by request stage; correlate timestamps/IDs.
- For hybrid paths, trace both routes, propagation/association, CIDR overlap, and controls across on-prem, VPN/Direct Connect, transit, and VPC.
- For CloudFront, inspect cache key/TTL, invalidation/versioning, origin headers, health, and whether the edge contacted origin.

## Check

Some users receive HTTP 503; DNS resolves and the ALB is reachable. Trace investigation using response headers/body, ALB health/access logs, app/container logs, and Flow Logs. What can each establish, and what is a limitation? Do not assume ALB generated the 503.

**Look for:** correlate a request across layers, determine which component emitted the response if evidence allows, and do not equate accepted network flow with successful application processing.
