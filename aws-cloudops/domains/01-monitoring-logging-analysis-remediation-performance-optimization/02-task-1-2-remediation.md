---
title: Task 1.2 - Analysis and remediation
domain: 1
official_task: 1.2
last_verified: 2026-10-03
sources:
  - title: AWS SOA-C03 Content Domain 1
    url: https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain1.html
---

# Task 1.2 — Identify and remediate issues

**Official skills:** 1.2.1 analyze performance and automate remediation with AWS services; 1.2.2 route/enrich/deliver EventBridge events and troubleshoot rules; 1.2.3 run or create Systems Manager Automation runbooks, including SDK/script-backed workflows.

## Study / do

- Use an evidence loop: define impact/window, compare healthy and failing paths, inspect signals, form competing hypotheses, and choose a discriminating test.
- Trace an event producer → bus/rule match → target permission/delivery → target outcome. Identify evidence at each boundary.
- For an automated action, specify preconditions, least-privilege role, idempotency, blast-radius guard, stop/rollback condition, and success signal.

## Check

An enabled EventBridge rule did not invoke its target. Give four ordered checks spanning event arrival, pattern match, target delivery/permissions, and target execution. Name evidence that supports each conclusion.

**Look for:** investigate producer/bus and actual event before pattern, then delivery authorization and target-side result; do not start by recreating the rule.
