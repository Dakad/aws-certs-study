# Relationships

Record a relationship when understanding how services or concepts interact matters. State the source node, labeled edge, target node, conditions, failure cases, and authoritative evidence. Avoid implying that two things are coupled merely because they are often used together.

Use [`../templates/relationship.md`](../templates/relationship.md). Draw the edge label from the controlled vocabulary in [`../../../.agents/skills/aws-knowledge-graph/SKILL.md`](../../../.agents/skills/aws-knowledge-graph/SKILL.md#edge-vocabulary), which owns the list and defines what each verb asserts. If no listed verb fits, the relationship is probably a use-mention rather than a dependency worth recording.

The derived [service relationship atlas](service-graph.md) visualizes typed edges from canonical service front matter in focused, readable study paths. `.mise.toml` pins the required `uv` and Graphviz tools; run `mise install` once from the repository root. Use `mise run graph:generate` to regenerate the atlas and all focused SVGs, `mise run graph:atlas` to regenerate only the Mermaid atlas, or `mise run graph:check` to verify generated sources.
