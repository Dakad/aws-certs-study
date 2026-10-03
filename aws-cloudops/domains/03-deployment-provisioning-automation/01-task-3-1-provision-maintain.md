---
title: Task 3.1 - Provision and maintain cloud resources
domain: 3
official_task: 3.1
last_verified: 2026-10-03
sources:
  - title: AWS SOA-C03 Content Domain 3
    url: https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain3.html
---

# Task 3.1 — Provision and maintain cloud resources

**Official skills:** 3.1.1 create/manage AMIs and container images, including Image Builder; 3.1.2 use CloudFormation/CDK; 3.1.3 troubleshoot deployment issues such as subnet sizing, template errors, and permissions; 3.1.4 share resources across accounts/Regions with RAM or StackSets; 3.1.5 implement deployment strategies; 3.1.6 use third-party automation such as Terraform and Git.

## Study / do

- Trace image build → versioned artifact → rollout → health validation → rollback. Identify what must be immutable to reproduce a release.
- Separate deployment failures into configuration/template, authorization, quota/capacity, and runtime-health classes; start from the first concrete error.
- Compare rolling, blue/green, and canary deployment by traffic shift, blast radius, validation signal, and rollback.
- For OpenTofu, explain provider, resource references, dependency graph, state ownership, and plan operations. Inspect replacement/deletion before any apply.
- For cross-account/Region sharing, name owner, consumer principal, resource scope, and destination before reasoning about access.

## Check

An IaC plan proposes replacing a subnet used by a workload. Explain how you would find the replacement cause, trace state and dependents, decide whether the change is safe, and verify the rollout. Name a migration or correction option.

**Look for:** inspect changed arguments and plan, identify dependents and impact, avoid blind apply, and validate workload behavior after an explicitly reviewed change.
