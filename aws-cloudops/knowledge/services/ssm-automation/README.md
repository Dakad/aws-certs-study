---
id: "ssm-automation"
kind: "service"
domains: [1, 3]
services: ["systems-manager-automation"]
sources:
  - title: "AWS Systems Manager Automation"
    url: "https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-automation.html"
  - title: "Learn about statuses returned by Systems Manager Automation"
    url: "https://docs.aws.amazon.com/systems-manager/latest/userguide/automation-statuses.html"
  - title: "Logging Automation action output with CloudWatch Logs"
    url: "https://docs.aws.amazon.com/systems-manager/latest/userguide/automation-action-logging.html"
  - title: "AWS Certified CloudOps Engineer Associate - Domain 1"
    url: "https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain1.html"
  - title: "AWS Certified CloudOps Engineer Associate - Domain 3"
    url: "https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain3.html"
last_verified: 2026-10-04
---

# AWS Systems Manager Automation

## In one paragraph

AWS Systems Manager Automation runs predefined or custom Automation runbooks to perform repeatable maintenance, deployment, and remediation work on AWS resources. A runbook is an AWS Systems Manager document of type `Automation`, expressed in YAML or JSON as sequential steps whose actions define the work and outputs.

## Behavior and boundaries

- Automation can target operations at scale with rate controls that limit concurrency and the tolerated error threshold.
- Automation reports both overall execution status and per-step status; a step status alone does not establish the overall execution outcome.
- Automation can be an EventBridge rule target, but the runbook and its IAM permissions determine what the triggered execution can do.

## Operational signals

- Inspect the Automation execution and step statuses to locate a failed, timed-out, cancelled, or waiting step.
- EventBridge can respond to automation or action status changes.
- CloudWatch Logs can capture `aws:executeScript` action output when Automation action logging is configured; it does not provide output for runbooks without that action.

## Common confusion

- An Automation runbook is not a Run Command document: Automation documents orchestrate runbook steps against AWS resources, while the document types and schemas are distinct.

## Exam mapping

- [Domain 1](../../../domains/01-monitoring-logging-analysis-remediation-performance-optimization/README.md) - Task 1.2: create or run custom and predefined Automation runbooks for remediation.
- [Domain 3](../../../domains/03-deployment-provisioning-automation/README.md) - Task 3.2: automate management of existing resources with Systems Manager.
