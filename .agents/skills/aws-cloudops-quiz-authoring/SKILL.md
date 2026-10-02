---
name: aws-cloudops-quiz-authoring
description: Create, review, or revise original AWS CloudOps Engineer Associate practice questions and quiz content. Use when building question banks, diagnosing answer quality, writing distractors/rationales, or linking quiz results to the study knowledge graph.
---

# AWS CloudOps quiz authoring

## Workflow

1. Read `AWS-CLOUDOPS-STUDY.md`, the relevant domain page, and `aws-cloudops/knowledge/README.md`. Verify scope against the current official SOA-C03 exam guide; do not reuse an older SOA-C02 blueprint as current scope.
2. Write original operational scenarios from verified AWS behavior. Never copy exam dumps, paid questions, or another repository's prose. Cite official AWS documentation for answer-critical claims.
3. Give each item a stable ID, domain(s), topic/service tags, graph node IDs, difficulty, and source URLs. Use `aws-cloudops/knowledge/templates/scenario.md` as the content structure.
4. Make the prompt answerable from the stated facts. Specify single-answer versus multiple-answer format; include only constraints that affect the decision. Avoid trick wording or two defensible answers.
5. Make distractors plausible and diagnostically useful. Explain why the best option fits and why each alternative fails under the stated requirements.
6. Add a follow-up question that tests transfer to a changed condition, not recall of the same sentence.
7. Keep domain coverage aligned with official exam weights. Track a learner's score only in the study journal with date, source, timing, and domain breakdown; update mistakes/strengths from observed responses, not from question creation.

## Question review checklist

- Is the skill/objective identifiable and mapped to the right domain?
- Does the stem include all facts needed to select one best answer?
- Is every technical claim verified by an official source, including exceptions and service limits?
- Are distractors wrong for a specific, explainable reason rather than merely unfamiliar?
- Does the rationale teach the relevant graph relationship and link to canonical nodes?
- Is the question original and free of copied answer-bank material?

Coordinate with [`../aws-knowledge-graph/SKILL.md`](../aws-knowledge-graph/SKILL.md) for node/edge structure and [`../aws-cloudops-tutoring/SKILL.md`](../aws-cloudops-tutoring/SKILL.md) for presenting one question at a time and recording learner evidence.
