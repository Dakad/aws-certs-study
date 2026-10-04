---
id: "config"
kind: "service"
domains: [4]
services: ["config"]
sources:
  - title: "What is AWS Config?"
    url: "https://docs.aws.amazon.com/config/latest/developerguide/WhatIsConfig.html"
  - title: "Viewing compliance history for AWS resources with AWS Config"
    url: "https://docs.aws.amazon.com/config/latest/developerguide/view-manage-resource-console.html"
  - title: "Working with CloudTrail event history"
    url: "https://docs.aws.amazon.com/awscloudtrail/latest/userguide/view-cloudtrail-events.html"
  - title: "SOA-C03 Domain 4"
    url: "https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain4.html"
last_verified: 2026-10-04
---

# AWS Config

## In one paragraph

AWS Config records supported resource configurations and relationships over time, then can evaluate those configurations with rules. It answers how a recorded resource was configured and whether it met a rule; it is not the account's general API audit log.

## Behavior and boundaries

- Recording scope determines which supported resource types provide configuration history. Resource timelines show configuration, relationship, and compliance events for a recorded resource.
- Config rules evaluate configuration conditions and report compliance. Historical compliance changes require recording the `AWS::Config::ResourceCompliance` resource type; current rule evaluation does not.

## Operational signals

- Use a resource timeline to compare the last known configuration, its relationships, and compliance events around a change. This establishes recorded state, not who issued an API request.

## Common confusion

- **Common mistake** — AWS Config replaces CloudTrail for change investigation.
- **Actual AWS behavior** — Config records resource configuration and compliance history; CloudTrail records management events that identify the API activity behind a change.
- **Why it matters** — Start with Config to establish the changed state, then use CloudTrail when the investigation needs the actor and API call.

## Exam mapping

- [Domain 4, Task 4.1](../../../domains/04-security-compliance/README.md) includes continuous compliance monitoring and AWS Config conformance packs; Task 4.2 includes reports and remediation for Config findings.
