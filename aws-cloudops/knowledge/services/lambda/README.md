---
id: "lambda"
kind: "service"
domains: [1, 3]
services: ["lambda"]
sources:
  - title: "What is AWS Lambda?"
    url: "https://docs.aws.amazon.com/lambda/latest/dg/welcome.html"
  - title: "Using CloudWatch metrics with Lambda"
    url: "https://docs.aws.amazon.com/lambda/latest/dg/monitoring-functions-metrics.html"
  - title: "Types of metrics for Lambda functions"
    url: "https://docs.aws.amazon.com/lambda/latest/dg/monitoring-metrics-types.html"
  - title: "Process Amazon S3 event notifications with Lambda"
    url: "https://docs.aws.amazon.com/lambda/latest/dg/with-s3.html"
  - title: "AWS Certified CloudOps Engineer - Associate: Domain 1"
    url: "https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain1.html"
  - title: "AWS Certified CloudOps Engineer - Associate: Domain 3"
    url: "https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain3.html"
last_verified: 2026-10-04
---

# AWS Lambda

## In one paragraph

AWS Lambda runs function code in response to events or API calls without the customer provisioning or managing servers. Lambda manages execution environments and scaling, while the function owner remains responsible for the handler's correctness, configuration, permissions, and event-processing design.

## Behavior and boundaries

- Each function invocation runs independently; Lambda can reuse an execution environment, so a function must not rely on in-memory state persisting between invocations.
- Lambda automatically emits function metrics to CloudWatch. A function error and an invocation throttle are different outcomes: throttled requests do not count as `Invocations` or `Errors`.
- An S3 notification invokes Lambda asynchronously and requires permission in the function's resource-based policy. Writing back to the same triggering bucket can create a recursive invocation loop.

## Operational signals

- Use `Invocations`, `Errors`, and `Duration` to establish volume, failure, and handler execution time; use `Throttles` and `ConcurrentExecutions` for concurrency pressure.
- For asynchronous processing, investigate `AsyncEventAge` and `AsyncEventsDropped`; for stream sources, `IteratorAge` shows the age of the last record delivered to the function.

## Common confusion

- **Common mistake** — `Errors` includes Lambda invocation requests rejected because of throttling.
- **Actual AWS behavior** — `Errors` counts function or runtime errors; throttled requests are reported in `Throttles` and count as neither `Invocations` nor `Errors`. [Types of metrics for Lambda functions](https://docs.aws.amazon.com/lambda/latest/dg/monitoring-metrics-types.html)
- **Why it matters** — [Domain 1](../../../domains/01-monitoring-logging-analysis-remediation-performance-optimization/README.md), Tasks 1.1 and 1.2 require choosing the signal that distinguishes a function failure from concurrency pressure.

> [!IMPORTANT]
> **Lambda `Errors` versus `Throttles`:** For SOA-C03, use the separate metrics to choose code/runtime investigation or concurrency remediation; treating throttles as errors risks an incorrect diagnosis and the wrong operational response.

## Exam mapping

- [Domain 1](../../../domains/01-monitoring-logging-analysis-remediation-performance-optimization/README.md): Tasks 1.1 and 1.2 (monitor serverless workloads and automate remediation).
- [Domain 3](../../../domains/03-deployment-provisioning-automation/README.md): Task 3.2, Skill 3.2.2 (event-driven automation with Lambda and S3 event notifications).
