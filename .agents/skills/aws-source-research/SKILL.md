---
name: aws-source-research
description: Research and verify AWS facts before writing study content. Use when creating or updating a concept or service page, answering a question whose answer may have changed, checking AWS service behavior, limits, quotas, or pricing, or deciding whether a claim needs an official citation.
---

# AWS source research

Verification discipline for mutable AWS facts. Run this before writing any page that asserts service behavior, and before answering a technical question from memory.

## The principle

Do not merely document the service. Understand five things first, then build the page around that understanding:

1. **How the service behaves** — from current official documentation, not memory.
2. **What the exam expects** — from the current SOA-C03 guide, not an older blueprint.
3. **What operational problems people actually hit** — from practitioner sources; these tell you what to go verify.
4. **How it relates to other services and concepts** — the edges you will draw.
5. **Whether the evidence holds up** — cross-checked, classified, and dated.

A page written from documentation alone will be accurate and useless. A page written from understanding will answer the question the learner actually has.

## Research before writing

Do not write AWS service behavior from model knowledge alone. Identify what is being asserted, then verify it. If a claim cannot be verified, either omit it or mark it explicitly as unverified in the page and in `AWS-CLOUDOPS-STUDY.md`.

## Source hierarchy

Use the highest tier that answers the question, and say which tier a claim came from.

1. **Official AWS documentation** — authority for service behavior, API semantics, and limits. Service docs, the API Reference, and the quotas reference for hard numbers.
2. **Current SOA-C03 exam guide** — authority for scope. Never treat an older blueprint (SOA-C02 or a prior SOA-C03 revision) as current.
3. **AWS Well-Architected Framework and reference architectures** — authority for supported design patterns and the reasoning behind them.
4. **Practitioner sources** — AWS blogs, re:Post, release notes, and conference talks. Use these to discover real operational problems, surprising defaults, and misconceptions. They do not override tier 1 when the two disagree; they tell you what to go verify.

## Cross-validation

- Verify every mutable or answer-critical claim: behavior, numeric limits, quotas, defaults, service availability, and pricing.
- Numeric limits and quotas need a dated citation to the official quotas or limits page.
- If official documentation and a practitioner source disagree, trust the official source and note the discrepancy rather than smoothing it over.
- Re-verify anything older than six months before reusing it in a rewritten page.

## Classify what you found

Label the substance of a claim, not the source's marketing:

- **Official AWS fact** — stated in current AWS documentation.
- **Certification requirement** — named in the current exam guide.
- **Operational practice** — what practitioners report doing in production.
- **Community observation** — anecdotal, unconfirmed, worth testing.
- **Interpretation** — your own inference. Never present it as documented fact.

Interpretation is the one that gets mislabeled. A causal story about *why* AWS behaves a certain way, when AWS only documents *what* it does, is interpretation. Say so.

## Prohibitions

- No exam dumps, leaked questions, answer keys, or "this exact question will appear" claims. See [`../aws-knowledge-graph/SKILL.md`](../aws-knowledge-graph/SKILL.md).
- No invented citations. Never record a source URL you did not open, and never record a `last_verified` date for a page you did not check.

## Record the result

In the page front matter, add each load-bearing source to `sources:` with its `title` and `url`, and set `last_verified` to the date you actually checked. Keep the citation at the narrowest page that needs it.

## Completeness check before finishing

- Is every behavioral claim backed by a tier 1 or tier 2 source?
- Are all numbers, limits, and defaults dated and cited?
- Is current exam scope confirmed against the current guide?
- Is anything labeled interpretation actually marked as such?
- Are the page's cross-links to other nodes present and resolvable?

Then write the page, following [`../aws-knowledge-graph/SKILL.md`](../aws-knowledge-graph/SKILL.md) for structure and [`../reference/writing-voice.md`](../reference/writing-voice.md) for prose.