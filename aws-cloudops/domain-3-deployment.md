# Domain 3 — Deployment, Provisioning, and Automation

**Exam weight:** 22% of scored content  
**Status:** Learning  
**Official objective:** [AWS Domain 3 guide](https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain3.html)

## What this domain is about

Provision and maintain cloud resources reliably, diagnose deployment failures, and automate repeatable operational work. The official objective includes AWS-native tools such as CloudFormation/CDK and operational automation, as well as third-party infrastructure-as-code tools such as Terraform. Our hands-on Terraform learning will use OpenTofu where appropriate, while keeping the exam objective broader than any one tool.

## Official task areas

- **3.1 — Provision and maintain resources:** Manage images; create resource stacks; troubleshoot permissions, subnet sizing, and deployment errors; understand multi-account/Region sharing and deployment strategies; use third-party IaC such as Terraform and Git.
- **3.2 — Automate management:** Use Systems Manager for operational workflows and event-driven automation such as Lambda, S3 notifications, and EventBridge.

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
- Mistakes and corrections: None assessed yet
- Next action: Choose a small, isolated, low-cost lab and define cleanup checks before provisioning.
