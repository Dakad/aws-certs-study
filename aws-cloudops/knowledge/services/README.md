# Services

Create one canonical page per AWS service. Cover purpose, core resource model, operational signals, failure behavior, security boundaries, cost considerations, and links to related concepts/relationships. Keep service-specific details here; domain pages link to them.

Use [`../templates/topic.md`](../templates/topic.md) with `kind: service`. Map each page to the relevant domain(s), and cite current official AWS documentation.

## Canonical service nodes

- [CloudWatch](cloudwatch/README.md) — Domain 1
- [CloudTrail](cloudtrail/README.md) — Domains 1 and 4
- [Amazon EC2](ec2/README.md) — Domains 1, 2, and 3
- [Elastic Load Balancing](elb/README.md) — Domains 1, 2, and 5
- [Amazon EventBridge](eventbridge/README.md) — Domains 1 and 3
- [Amazon S3](s3/README.md) — Domains 1, 2, 3, and 4
- [Amazon RDS](rds/README.md) — Domains 1 and 2
- [AWS Lambda](lambda/README.md) — Domains 1 and 3
- [Amazon SNS](sns/README.md) — Domain 1
- [AWS Systems Manager Automation](ssm-automation/README.md) — Domains 1 and 3
- [IAM Access Analyzer](access-analyzer/README.md) — Domain 4
- [AWS Organizations and SCPs](organizations/README.md) — Domain 4
- [AWS KMS](kms/README.md) — Domain 4
- [AWS Secrets Manager](secretsmanager/README.md) — Domain 4
- [AWS Security Hub](securityhub/README.md) — Domain 4
- [AWS IAM](iam/README.md) — Domain 4
- [AWS Config](config/README.md) — Domain 4
- [Amazon GuardDuty](guardduty/README.md) — Domain 4
- [Amazon Inspector](inspector/README.md) — Domain 4

## Imported IAM study notes

The [IAM notes](13-security-identity-compliance/01-iam/README.md) are upstream-authored study material, not yet a graph-native canonical service page. Their source, permission scope, and pinned revision are recorded in [`../upstream-sources.yml`](../upstream-sources.yml). Keep the imported text distinct from any independently authored canonical service page.
