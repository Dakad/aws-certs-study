---
id: "eventbridge"
kind: "service"
domains: [1, 3]
services: ["eventbridge"]
sources:
  - title: "What Is Amazon EventBridge?"
    url: "https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-what-is.html"
  - title: "Rules in Amazon EventBridge"
    url: "https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-rules.html"
  - title: "Monitoring Amazon EventBridge"
    url: "https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-monitoring.html"
  - title: "AWS Certified CloudOps Engineer Associate - Domain 1"
    url: "https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain1.html"
  - title: "AWS Certified CloudOps Engineer Associate - Domain 3"
    url: "https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain3.html"
last_verified: 2026-10-04
---

# Amazon EventBridge

## In one paragraph

Amazon EventBridge is a serverless event service for connecting producers and consumers. An event bus receives events and uses rules to match, optionally transform, and send matching events to one or more targets; EventBridge Pipes instead provides a point-to-point source-to-target integration.

## Behavior and boundaries

- A rule matches event data against its event pattern and invokes its configured target or targets only when the pattern matches.
- A single rule can send an event to multiple targets, which run in parallel.
- Scheduled rules are a legacy EventBridge feature; AWS recommends EventBridge Scheduler for new scheduled invocations.

## Operational signals

- Use `MatchedEvents` and `Invocations` to distinguish rule matching from target invocation.
- Investigate nonzero `FailedInvocations`, `InvocationsSentToDlq`, and `InvocationsFailedToBeSentToDlq`; EventBridge CloudWatch metrics are best-effort operational signals, not a complete audit record.

## Common confusion

- **Common mistake** — EventBridge is just a notification topic, so it is interchangeable with Amazon SNS.
- **Actual AWS behavior** — An EventBridge rule matches event data against an event pattern and sends matching events to its configured targets; use SNS when the requirement is publisher-to-subscriber notification fanout rather than event-pattern routing. [Rules in Amazon EventBridge](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-rules.html)
- **Why it matters** — Domain 1 Task 1.2 requires selecting the service that routes, enriches, delivers, and troubleshoots events and event bus rules.

> [!IMPORTANT]
> **EventBridge rule matching** decides whether an event reaches a target. For SOA-C03 Domain 1 event-routing questions, treating it as SNS fanout risks choosing a design that cannot filter structured events by an event pattern.

## Exam mapping

- [Domain 1](../../../domains/01-monitoring-logging-analysis-remediation-performance-optimization/README.md) - Task 1.2: route, enrich, deliver, and troubleshoot events and event bus rules.
- [Domain 3](../../../domains/03-deployment-provisioning-automation/README.md) - Task 3.2: implement event-driven automation.
