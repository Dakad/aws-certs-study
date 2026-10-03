# AWS CloudOps study repository

This is a personal study workspace for the AWS Certified CloudOps Engineer – Associate (SOA-C03) exam. Keep SOA-C03 learning material and learner progress distinct from supplemental question banks for other certifications.

## Start here

- For tutoring or progress updates, read `AWS-CLOUDOPS-STUDY.md` and the relevant `aws-cloudops/domain-*.md` page first. Resume the next action recorded in the journal.
- Read `.agents/skills/README.md` and follow the relevant detailed skill: tutoring, knowledge graph, quiz authoring, or AWS/OpenTofu labs. These skills contain the workflows; this file sets repo-wide boundaries.
- Keep study across all five SOA-C03 domains. Give networking/investigation modest extra practice, not disproportionate focus.

## Canonical agent guidance

- `.agents/` is the source of truth for repository agent guidance. Store skills in `.agents/skills/` and custom subagent definitions in `.agents/subagents/`.
- `.cursor/agents/` and `.cursor/skills/` are compatibility symlinks to `.agents/subagents/` and `.agents/skills/`. Do not maintain duplicate files under `.cursor/`.

## Learning and progress

- Teach from the learner's Senior Platform Engineer experience; focus on newer AWS CloudOps and direct Terraform/OpenTofu authoring concepts rather than re-teaching familiar Kubernetes/platform basics.
- Give specific feedback and explain with concrete examples. Preserve partially correct answers and valid alternatives; distinguish learner misconceptions from unclear tutoring or question wording.
- Track strengths, mistakes, and mastery only from observed answers or actions. A written note, generated question, or successful lab alone is not evidence of mastery.
- During an active lesson, finish with one concrete next exercise or question. Do not end with only a recap or a vague “what next?” prompt.

## AWS labs and safety

- The learner prefers AWS CLI creation, their own Console inspection, then Terraform/OpenTofu recreation. Never request AWS credentials or take control of their Console or laptop; they may share screenshots for interpretation.
- Before an AWS mutation, show the exact command or configuration and explain its target, expected change, cost, risk, and cleanup. Verify identity with `aws sts get-caller-identity`; use the configured profile and do not add `--device-code` to SSO login by default.
- Keep labs disposable and scoped to the learner's authorized playground or personal account. Do not use production or shared workloads as lab targets. A high budget alert is not blanket approval for avoidable spend.
- Review plans and state before applying. Never blindly duplicate a CLI-created resource with IaC; explain import versus safe recreation. Clean up temporary resources and verify the result.
- Do not commit credentials, state, plans, or sensitive account output.

## Content and provenance

- Keep original SOA-C03 notes, scenarios, and progress in their designated `aws-cloudops/` pages and `AWS-CLOUDOPS-STUDY.md`.
- Third-party question banks are supplemental and must stay separate from SOA-C03 coverage and scores. Import only when explicitly requested and redistribution is permitted; preserve the complete license, source, and pinned upstream revision. Do not present them as official AWS exam questions.
- The imported `jgyy/awsquiz` banks are YAML in `assets/quiz-banks/imported/jgyy-awsquiz/`. Their `accepted_correct_option_ids` is the source's answer pool; retain `answer_type` and `author_notes` when updating or transforming them.
- Never invent learner results, source provenance, AWS behavior, or exam scope. Verify mutable or answer-critical technical claims against current official sources as directed by the relevant skill.

## Repository workflow

- Use Jujutsu (`jj`) for local version control and `gh` for GitHub operations. Keep changes focused and preserve unrelated work.
- Prefer relative Markdown links. After documentation changes, validate links and any YAML/front matter you edited.
- Never store AWS credentials or sensitive account output in this repository.
