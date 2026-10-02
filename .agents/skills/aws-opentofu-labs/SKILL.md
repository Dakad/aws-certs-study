---
name: aws-opentofu-labs
description: Design, teach, execute, or review AWS infrastructure labs that compare AWS CLI, the learner's Console inspection, and Terraform/OpenTofu. Use for hands-on CloudOps and Domain 3 exercises involving plans, state, imports, drift, dependencies, or cleanup.
---

# AWS CLI, Console, and OpenTofu labs

## Plan the lab

1. Read the current study journal/domain page and the canonical graph nodes for the services involved. Choose a small objective tied to an exam domain.
2. Prefer disposable, low-cost resources in an isolated scope. Do not use an existing workload merely because it is convenient, and do not size up because a budget alert exists.
3. Before any mutation, show the exact CLI command or HCL that will be run and explain the target, expected change, cost, possible impact, and cleanup. Do not ask generic permission to run a command; pause when scope, target, sensitive effects, or material risk is unclear.
4. Verify the AWS identity with `aws sts get-caller-identity` before changes. Use the learner's configured profile; do not add `--device-code` to SSO login by default. Never request credentials or control the learner's computer/Console.

## Teach the three representations

1. **AWS CLI:** explain each option, execute the presented command, and interpret the returned resource IDs/configuration.
2. **AWS Console:** ask the learner to inspect the same resource and optionally share a screenshot; explain what the visible fields confirm or leave uncertain.
3. **Terraform/OpenTofu:** build the equivalent desired-state configuration incrementally. Explain provider, resource, arguments, references, dependency graph, variables/outputs as they appear. Use the repo's configured tool (`tofu` for OpenTofu); clearly distinguish compatible concepts from tool-specific behavior.
4. Review `plan` and state before applying. Explain how the tool identifies existing resources and what replacement, deletion, or import would mean. Never blindly apply a second copy of a CLI-created resource: explicitly choose either safe deletion/recreation under IaC or a documented import workflow.
5. Compare configuration, plan/state, CLI observations, and Console view. Then remove temporary resources and verify cleanup; report any state still present or cost-bearing resource.

## Safety and learning evidence

- Protect state files, plans, credentials, and account-specific identifiers from Git. Use the study repo's `.gitignore`; never commit secrets or raw sensitive account output.
- Do not change production or shared AppTweak infrastructure from this personal study repo. Keep labs scoped to the authorized playground or a personal account when the learner chooses it.
- If AWS access ends on October 15, 2026, finish playground cleanup before then; do not assume later access.
- Link the lab to its graph nodes and exam domain. Update learner progress only from observed answers/actions; successful provisioning alone is not mastery.

For tutoring turn structure and progress tracking, follow [`../aws-cloudops-tutoring/SKILL.md`](../aws-cloudops-tutoring/SKILL.md). For canonical service/concept notes and scenario links, follow [`../aws-knowledge-graph/SKILL.md`](../aws-knowledge-graph/SKILL.md).
