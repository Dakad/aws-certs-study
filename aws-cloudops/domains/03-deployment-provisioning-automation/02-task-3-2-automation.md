---
title: Task 3.2 - Operational automation
domain: 3
official_task: 3.2
last_verified: 2026-10-03
sources:
  - title: AWS SOA-C03 Content Domain 3
    url: https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain3.html
---

# Task 3.2 — Automate management of existing resources

**Official skills:** 3.2.1 automate operational work with AWS services such as Systems Manager; 3.2.2 implement event-driven automation with Lambda, S3 notifications, EventBridge, and related features.

## Study / do

- Specify trigger, inputs, preconditions, permissions, idempotency, success signal, failure handling, and rollback for one repeated operator action.
- Compare scheduled automation, Systems Manager runbooks, and EventBridge-driven functions based on trigger semantics and safety controls.
- Account for duplicate/out-of-order event delivery, retry behavior, dead-letter handling, and target permissions.
- Add approval/guardrails for actions that can disrupt workloads, change access, or delete data; state how an operator stops or reverses them.

## Check

A function tags new resources but sometimes receives the same event twice. Design safe handling. What must be idempotent, where do you observe errors, and what should happen if the tag operation is denied?

**Look for:** repeated events converge, failures remain visible, and denied operations are not reported as success.
