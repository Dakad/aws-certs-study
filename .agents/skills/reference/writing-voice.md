# Writing voice

Standards for AWS study content in this repository. Applies to concept pages, service pages, scenarios, quiz rationales, cheatsheets, and lesson prose.

Adapted from the documentation standard in [GabrielAlmeidaFlores/AWS-CloudOps-Engineer-Associate-Doc](https://github.com/GabrielAlmeidaFlores/AWS-CloudOps-Engineer-Associate-Doc/blob/main/AGENTS.md) §28, used under the author's personal-study permission recorded in `aws-cloudops/knowledge/upstream-sources.yml`.

## Register

Write like a senior CloudOps engineer documenting something for another engineer.

Use precise terminology, concrete examples, mechanism-level reasoning, and tables or diagrams where they improve comparison.

Avoid filler, hedging, marketing language, unnecessary repetition, and analogies.

> "CloudWatch is like a CCTV camera." — cut it.

> "Amazon CloudWatch provides the metrics, logs, alarms, and dashboards used to detect and respond to operational conditions." — keep it.

## Banned words

Replace with a concrete verb or noun, or delete.

- **Verbs**: delve, leverage, foster, ignite, empower, uncover, unleash, underscore, harness, illuminate, facilitate, refine, bolster, differentiate, navigate, elevate, unlock, streamline, optimize (when it means "just do").
- **Adjectives**: pivotal, cutting-edge, seamless, robust, scalable, transformative, revolutionary, game-changing, innovative, multifaceted, comprehensive, dynamic, unwavering. Keep one only where it carries a specific defensible technical meaning; "seamless failover" is still a buzzword, so name the mechanism instead.
- **Abstract nouns and metaphors**: realm, landscape, tapestry, testament, beacon, journey, ecosystem, symphony. Say "the VPC", not "the networking realm."
- **Hedging**: generally speaking, typically, tends to, arguably, to some extent, broadly speaking, in many ways, at some level, it could be argued that, while it is true, it is important to note. Keep a hedge only when it carries real weight, such as a compliance caveat.
- **Filler transitions and openers**: furthermore, moreover, additionally, in conclusion, ultimately, in essence, at the end of the day, at its core, that being said, let's dive in, demystify, in today's rapidly changing world, picture this.

## Voice tests

Apply either test to a sentence that reads as filler.

1. **Transplant test.** Could this sentence move unchanged into a page about a different service without anyone noticing? Then it is too generic; rewrite with specifics.
2. **Pub test.** Would you say it out loud to a colleague? "We empower users to optimize workflows" fails. "This alarm triggers a Systems Manager automation" passes.

Prefer specific nouns and active verbs over "very important", "significant impact", and "major role". State the number, the mechanism, or the consequence.

## Structure tells

Tables, headings, lists, and Mermaid diagrams are expected here and are not themselves AI tells. The voice-level tells that ride along with them are:

- lists of exactly three, for appearance;
- a bold lead-in on every bullet;
- signposting that restates the obvious ("First… Next… Finally…");
- a conclusion that only restates the introduction.

Vary sentence length: follow a long technical sentence with a short one. Use at most two em dashes per sentence.

## Callouts

Blockquoted callouts (`> [!NOTE]`, `[!TIP]`, `[!IMPORTANT]`, `[!CAUTION]`, `[!WARNING]`) flag what must be remembered. A callout must stand alone: name the concept, say why it matters for SOA-C03, and state the consequence of getting it wrong. The reader should grasp the point without the surrounding section.

Too thin:

> [!TIP]
> Deny wins.

Complete:

> [!IMPORTANT]
> An explicit `Deny` overrides every applicable `Allow`, including identity policy, resource policy, permissions boundary, and SCP. This decides most "why is access denied" questions: even with an `Allow` present, a single `Deny` anywhere in the chain blocks the action. Check boundaries and SCPs first, because that is where candidates overlook the deny.

Apply this standard everywhere. Prose must teach the concept, not gesture at it.
