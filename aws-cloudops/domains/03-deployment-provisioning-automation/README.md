# Domain 3 — Deployment, Provisioning, and Automation

**Exam weight:** 22% of scored content  
**Status:** Learning  
**Official objective:** [AWS Domain 3 guide](https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain3.html) (scope checked 2026-10-03)

## What this domain is about

Provision and maintain cloud resources reliably, diagnose deployment failures, and automate repeatable operational work. The official objective includes AWS-native tools such as CloudFormation/CDK and operational automation, as well as third-party infrastructure-as-code tools such as Terraform. Our hands-on Terraform learning will use OpenTofu where appropriate, while keeping the exam objective broader than any one tool.

## Official task areas and study guides

| Official task | What to study | Task guide |
|---|---|---|
| **3.1 — Provision and maintain cloud resources** | Image pipelines, CloudFormation/CDK, deployment failure analysis, cross-account/Region sharing, deployment strategies, and third-party IaC including Terraform. The hands-on path here uses OpenTofu and distinguishes Terragrunt's composition role. | [Provision and maintain](01-task-3-1-provision-maintain.md) |
| **3.2 — Automate the management of existing resources** | Systems Manager operational workflows and event-driven automation using services such as Lambda, S3 notifications, and EventBridge. | [Operational automation](02-task-3-2-automation.md) |

Use the [Domain 3 contexts index](contexts/README.md) for reusable deployment and automation scenarios. The task guides provide practice and checks; learner results remain in the progress notes below and [`PROGRESS.md`](../../../PROGRESS.md).

## Services

The service and tool list follows the [official Domain 3 objectives](https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain3.html); examples are exam-scope coverage, not an exhaustive AWS catalog.

- **Images and infrastructure provisioning:** EC2 Image Builder, Amazon Machine Images (AMIs), container images, AWS CloudFormation, AWS CDK, AWS Resource Access Manager (AWS RAM), and CloudFormation StackSets.
- **Deployment and operations automation:** AWS Systems Manager, AWS Lambda, Amazon S3 Event Notifications, Amazon EventBridge, and AWS DevOps Agent.
- **Third-party delivery tools:** Terraform and Git. In this study repository, OpenTofu is the hands-on Terraform-compatible tool and Terragrunt composes configurations; these distinctions support learning but do not narrow the exam's stated scope.

### Cross-service impacts

Provisioning can fail because of IAM permissions, subnet capacity, or service constraints, so deployment diagnosis crosses into [Domain 4](../04-security-compliance/README.md) and [Domain 5](../05-networking-content-delivery/README.md). Automation acts on resources across all domains and should emit observable evidence (see [Domain 1](../01-monitoring-logging-analysis-remediation-performance-optimization/README.md)); reliability depends on repeatable replacement and recovery workflows (see [Domain 2](../02-reliability-business-continuity/README.md)). Treat these as operational dependencies to investigate, not automatic effects of using an IaC tool.

## Learning targets

- Compare imperative CLI operations with declarative templates and understand desired state, plans, state, drift, dependencies, and repeatability.
- Read deployment errors systematically: identify the failed resource, underlying API/permission/constraint, and safe correction.
- Understand what Terraform/OpenTofu manages versus AWS service behavior; recognize why state and reviewable plans matter.
- Recognize AWS-native deployment and operations services even when using OpenTofu for labs.

## Practice and evidence

For one small isolated architecture, follow the user's preferred sequence:

1. Create it with AWS CLI and save the commands/outputs needed to understand what changed.
2. Inspect the created resources and relationships in the AWS Console.
3. Recreate the same design in OpenTofu from a clean state, reviewing `plan` before apply.
4. Compare intended configuration, plan, state, and observed resources; then verify cleanup.

- **Demonstrated when:** explain what each tool did, identify how OpenTofu knows what exists, interpret a plan, and diagnose a changed or failed resource without blindly reapplying.

### Progress notes

- Status: Learning — approach selected, lab not yet executed
- Evidence: User proposed CLI creation → Console verification → Terraform recreation; account reconnaissance completed.
- Phase 0 diagnostic baseline (2026-10-03): 5/5. Correctly defined an OpenTofu plan as proposed changes from configuration and current state, state locking as concurrency protection, Terragrunt as environment-stack composition, manual live changes as drift, and plan review as the primary pre-apply safeguard. This is recall evidence; no hands-on configuration/state/plan cycle has been completed.
- Mistakes and corrections: None assessed yet
- Next action: Choose a small, isolated, low-cost lab and define cleanup checks before provisioning.
