# Services

Create one canonical page per AWS service. Cover purpose, core resource model, operational signals, failure behavior, security boundaries, cost considerations, and links to related concepts/relationships. Keep service-specific details here; domain pages link to them.

Use [`../templates/topic.md`](../templates/topic.md) with `kind: service`. Map each page to the relevant domain(s), and cite current official AWS documentation.

## Imported IAM study notes

The [IAM notes](13-security-identity-compliance/01-iam/README.md) are upstream-authored study material, not yet a graph-native canonical service page. Their source, permission scope, and pinned revision are recorded in [`../upstream-sources.yml`](../upstream-sources.yml). Keep the imported text distinct from any independently authored canonical service page.
