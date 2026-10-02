# AWS CloudOps Engineer Associate study

Personal study workspace for the AWS Certified CloudOps Engineer – Associate (SOA-C03) exam, targeted for October 31, 2026.

Start with the [study journal](AWS-CLOUDOPS-STUDY.md) for the schedule, overall progress, session notes, strengths, mistakes, and next actions. Each exam domain has its own page:

- [1. Monitoring, Logging, Analysis, Remediation, and Performance Optimization](aws-cloudops/domain-1-monitoring.md)
- [2. Reliability and Business Continuity](aws-cloudops/domain-2-reliability.md)
- [3. Deployment, Provisioning, and Automation](aws-cloudops/domain-3-deployment.md)
- [4. Security and Compliance](aws-cloudops/domain-4-security.md)
- [5. Networking and Content Delivery](aws-cloudops/domain-5-networking.md)

The [knowledge graph](aws-cloudops/knowledge/README.md) connects canonical AWS service and concept notes to relationships, exam domains, scenarios, and labs. It is Markdown-first; no graph database or app is required.

Repo-local agent guidance is indexed in [`.agents/skills/`](.agents/skills/README.md): one skill maintains the knowledge graph, and another governs tutoring sessions and progress updates.

The study method is balanced across all five domains, with modest extra practice for networking and investigation. For hands-on topics, compare AWS CLI creation, Console inspection, and OpenTofu recreation. Review exact commands and cost/cleanup implications before AWS changes; never store credentials or sensitive account output here.
