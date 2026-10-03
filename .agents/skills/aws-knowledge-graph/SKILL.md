---
name: aws-knowledge-graph
description: Maintain the AWS CloudOps study repository as a linked Markdown knowledge graph. Use when adding or updating AWS service/concept notes, cross-service relationships, exam scenarios, labs, cheatsheets, or links between those materials and the SOA-C03 domains or quiz.
---

# AWS Knowledge Graph

## Workflow

1. Read `aws-cloudops/knowledge/README.md`, the relevant domain page, and any existing canonical node before editing.
2. Put each service or concept explanation in one canonical page under `aws-cloudops/knowledge/`: named AWS services belong in `services/`, and cross-service principles belong in `concepts/`. Add edges as labeled links/metadata; do not duplicate the explanation in a domain page or cheatsheet.
3. Map every node and scenario to SOA-C03 domain(s). Use the current official exam guide for scope and official AWS documentation for service behavior; include source URLs and `last_verified` for mutable facts. Verify before writing, following [`../aws-source-research/SKILL.md`](../aws-source-research/SKILL.md).
4. Use the supplied templates. Prefer relative Markdown links. Draw a Mermaid diagram only when it clarifies a meaningful multi-node flow.
5. Keep scenarios original. Explain the correct reasoning and why plausible alternatives fail; do not copy exam dumps, paid questions, or another repository's prose.
6. Link quiz questions to stable node IDs so a missed answer can point to the concept to review. Record learner answers, corrections, strengths, and mastery evidence in `PROGRESS.md` and the relevant domain page—not as unverified claims in the graph.
7. For labs, preserve the documented sequence: explain and show the exact command/config first; then CLI, output interpretation, learner-led Console inspection, OpenTofu comparison, cleanup, and verification. State cost and scope before AWS mutations. Never store credentials or sensitive account identifiers/output.
8. Follow [`../reference/writing-voice.md`](../reference/writing-voice.md) for prose. Run the transplant test on any sentence that reads as filler.

## Scope the page

Architecture is fixed; content is adaptive. Use the smallest structure that preserves the knowledge.

- Do not manufacture a section. If a topic has no networking surface, omit networking.
- Keep pricing concise unless it changes an operational decision.
- Do not split a simple service across fifteen files to satisfy a template.
- Create a new page when the context genuinely differs, not to restate an existing node.

## Edge vocabulary

Use these `relation` values in front matter and as link labels. A typed edge beats an unlabeled "related" link, because it tells the learner what kind of dependency to expect.

| Relation | Use it when |
| --- | --- |
| `depends-on` | the target must exist or be configured first |
| `integrates-with` | the two interoperate directly |
| `commonly-used-with` | frequent pairing, no ordering requirement |
| `troubleshoots-with` | the target's signals explain the source's failures |
| `secured-by` | the target supplies the security control |
| `monitored-by` | the target supplies metrics, logs, or alarms |
| `automated-by` | the target performs an operational action |
| `scales-with` | capacity of the source follows the target |
| `fails-over-to` | the target takes over on failure |

Cross-service context belongs in `aws-cloudops/knowledge/relationships/`, not duplicated into either parent page. Domain pages are knowledge maps that link out; they do not restate service behavior.

## Answer shapes

**Exam trap.** Use the three-part form for `## Common confusion`, so the learner gets the misbelief, the correction, and the payoff in one pass:

- **Common mistake** — the plausible wrong assumption.
- **Actual AWS behavior** — what AWS documents, with a citation.
- **Why it matters** — which scenario decides on this, or which domain objective it maps to.

**Numbers and defaults.** Split limits into two tiers so review time is spent correctly:

- **Must remember** — the figures the exam tests directly.
- **Good to know** — real operational context that is not likely to be examined.

Include a source URL and `last_verified` for every figure.

**Callouts.** Use `> [!IMPORTANT]`-style blockquotes for must-remember material. Each must stand alone: name the concept, say why it matters for SOA-C03, state the consequence of getting it wrong.

## Before finishing

- Update the relevant category index and links when adding a page.
- Check links, node IDs, domain mappings, Mermaid syntax, and source accuracy.
- Keep the five-domain coverage balanced; do not reorder the tutoring plan solely because a topic is interesting.
- Do not mark a learner topic as mastered because a note was written or a lab ran once.
