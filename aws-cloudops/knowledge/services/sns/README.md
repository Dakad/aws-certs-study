---
id: "sns"
kind: "service"
domains: [1]
services: ["sns"]
sources:
  - title: "What is Amazon SNS?"
    url: "https://docs.aws.amazon.com/sns/latest/dg/welcome.html"
  - title: "Monitoring Amazon SNS topics using CloudWatch"
    url: "https://docs.aws.amazon.com/sns/latest/dg/sns-monitoring-using-cloudwatch.html"
  - title: "AWS Certified CloudOps Engineer Associate - Domain 1"
    url: "https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain1.html"
last_verified: 2026-10-04
---

# Amazon Simple Notification Service

## In one paragraph

Amazon Simple Notification Service (Amazon SNS) is a managed publisher-to-subscriber messaging service. Publishers send messages to a topic, and the topic can deliver notifications to multiple subscribing endpoints, including Amazon SQS, Lambda, HTTP(S), email, SMS, and mobile push endpoints.

## Behavior and boundaries

- SNS supports fanout: a message published to a topic can be delivered to multiple subscriptions.
- Subscription filter policies can reject a message that does not match; a rejected message is not a successful delivery.
- SNS delivers notifications; it does not itself evaluate workload health or perform remediation. A CloudWatch alarm needs an SNS action configured to notify through a topic.

## Operational signals

- Compare `NumberOfMessagesPublished` with `NumberOfNotificationsDelivered` and `NumberOfNotificationsFailed` by topic to investigate notification delivery.
- Use `NumberOfNotificationsFilteredOut` to distinguish filter-policy rejection from a delivery failure.
- Alarm on delivery failures when notification delivery is operationally significant.

## Common confusion

- Publishing to an SNS topic is not proof that every endpoint received the message. Confirm delivery and failure metrics for the topic, and account for subscriptions filtered out by policy.

## Exam mapping

- [Domain 1](../../../domains/01-monitoring-logging-analysis-remediation-performance-optimization/README.md) - Task 1.1: configure AWS services and CloudWatch alarms to send notifications to Amazon SNS.
