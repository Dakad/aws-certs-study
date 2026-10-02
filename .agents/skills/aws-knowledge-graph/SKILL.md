---
name: aws-knowledge-graph
description: Maintain the AWS CloudOps study repository as a linked Markdown knowledge graph. Use when adding or updating AWS service/concept notes, cross-service relationships, exam scenarios, labs, cheatsheets, or links between those materials and the SOA-C03 domains or quiz.
---

# AWS Knowledge Graph

## Workflow

1. Read `aws-cloudops/knowledge/README.md`, the relevant domain page, and any existing canonical node before editing.
2. Put each service or concept explanation in one canonical page under `aws-cloudops/knowledge/`. Add edges as labeled links/metadata; do not duplicate the explanation in a domain page or cheatsheet.
3. Map every node and scenario to SOA-C03 domain(s). Use the current official exam guide for scope and official AWS documentation for service behavior; include source URLs and `last_verified` for mutable facts.
4. Use the supplied templates. Prefer relative Markdown links. Draw a Mermaid diagram only when it clarifies a meaningful multi-node flow.
5. Keep scenarios original. Explain the correct reasoning and why plausible alternatives fail; do not copy exam dumps, paid questions, or another repository's prose.
6. Link quiz questions to stable node IDs so a missed answer can point to the concept to review. Record learner answers, corrections, strengths, and mastery evidence in `AWS-CLOUDOPS-STUDY.md` and the relevant domain page—not as unverified claims in the graph.
7. For labs, preserve the documented sequence: explain and show the exact command/config first; then CLI, output interpretation, learner-led Console inspection, OpenTofu comparison, cleanup, and verification. State cost and scope before AWS mutations. Never store credentials or sensitive account identifiers/output.

## Before finishing

- Update the relevant category index and links when adding a page.
- Check links, node IDs, domain mappings, Mermaid syntax, and source accuracy.
- Keep the five-domain coverage balanced; do not reorder the tutoring plan solely because a topic is interesting.
- Do not mark a learner topic as mastered because a note was written or a lab ran once.
