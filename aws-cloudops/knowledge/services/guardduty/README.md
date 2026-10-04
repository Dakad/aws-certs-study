---
id: "guardduty"
kind: "service"
domains: [4]
services: ["guardduty"]
sources:
  - title: "What is Amazon GuardDuty?"
    url: "https://docs.aws.amazon.com/guardduty/latest/ug/what-is-guardduty.html"
  - title: "GuardDuty foundational data sources"
    url: "https://docs.aws.amazon.com/guardduty/latest/ug/guardduty_data-sources.html"
  - title: "SOA-C03 Domain 4"
    url: "https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain4.html"
last_verified: 2026-10-04
---

# Amazon GuardDuty

## In one paragraph

Amazon GuardDuty is a threat-detection service that analyzes AWS data sources to identify suspicious or potentially malicious activity and produces security findings. When enabled, it monitors foundational sources including CloudTrail management events, EC2 VPC flow log data, and, for EC2 instances using AWS DNS resolvers, Route 53 Resolver DNS query logs.

## Behavior and boundaries

- GuardDuty consumes foundational data through independent streams; it does not manage the account's CloudTrail events or VPC Flow Logs configuration, retention, or access.
- A finding is evidence of a potential threat that needs investigation and response. It does not by itself prove compromise or perform remediation.

## Operational signals

- A GuardDuty finding identifies the suspected threat and affected resource. Use its details to scope an investigation, then correlate with the underlying audit, network, or workload evidence.

## Common confusion

- **Common mistake** — Creating a VPC Flow Log is required before GuardDuty can detect EC2 network threats.
- **Actual AWS behavior** — GuardDuty consumes EC2 VPC flow log data from an independent stream after it is enabled; existing VPC Flow Log configuration does not control that analysis.
- **Why it matters** — Domain 4 scenarios distinguish enabling detection from retaining network logs for independent investigation.

## Exam mapping

- [Domain 4, Task 4.2](../../../domains/04-security-compliance/README.md) covers configuring reports and remediating findings from Amazon GuardDuty and other AWS security services.
