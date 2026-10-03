---
id: "secretsmanager"
kind: "service"
domains: [4]
services: ["secretsmanager"]
related:
  - relation: "encrypts-with"
    target: "kms"
  - relation: "secured-by"
    target: "iam"
  - relation: "integrates-with"
    target: "lambda"
  - relation: "integrates-with"
    target: "rds"
  - relation: "audited-by"
    target: "cloudtrail"
sources:
  - title: "AWS Secrets Manager User Guide"
    url: "https://docs.aws.amazon.com/secretsmanager/latest/userguide/intro.html"
  - title: "Rotating Your AWS Secrets Manager Secrets"
    url: "https://docs.aws.amazon.com/secretsmanager/latest/userguide/rotating-secrets.html"
  - title: "Cross-Region Replication"
    url: "https://docs.aws.amazon.com/secretsmanager/latest/userguide/replication.html"
last_verified: 2026-10-03
---

# AWS Secrets Manager

## In one paragraph

AWS Secrets Manager centrally stores, manages, and rotates secrets (database credentials, API keys, tokens) throughout their lifecycle. It encrypts secrets at rest using KMS, supports automatic rotation via Lambda functions, provides version staging labels (AWSCURRENT, AWSPENDING, AWSPREVIOUS) for safe rollout, and offers cross-region replication for disaster recovery. Native integration with RDS, DocumentDB, and Redshift simplifies database credential rotation.

## Behavior and boundaries

- **Secret storage**: Stores secret values up to 65 KB (including metadata). Each secret has metadata (name, description, tags, KMS key ID, rotation config) and one or more secret versions.
- **Automatic rotation (Lambda-based)**: Rotation runs on a schedule (cron expression or rate). Secrets Manager invokes a Lambda function that implements the 4-step rotation protocol: `createSecret`, `setSecret`, `testSecret`, `finishSecret`.
- **Rotation schedules**: Minimum rotation interval is 1 day. Schedule defined as cron (`cron(0 2 * * ? *)`) or rate (`rate(30 days)`). Rotation window can be specified.
- **Versioning (staging labels)**: Secret versions are referenced by staging labels, not version IDs directly:
  - `AWSCURRENT` — Active version returned by `GetSecretValue` (default)
  - `AWSPENDING` — Staging version being validated during rotation
  - `AWSPREVIOUS` — Previous version (for rollback)
- **Cross-region replication**: Primary secret in one region + read-only replicas in other regions. Replication is asynchronous. Each replica uses a KMS key in its region (can be AWS-managed or customer-managed). Replicas stay in sync with primary; promote replica to primary if needed.
- **Secret value encryption**: Double encryption layer — secret value encrypted with a data key, data key encrypted with KMS key. Default: AWS-managed key `aws/secretsmanager`. Customer-managed KMS key recommended for audit/control. KMS key policy must allow `secretsmanager` service principal.
- **Rotation Lambda permissions**: Lambda needs `secretsmanager:GetSecretValue`, `secretsmanager:PutSecretValue`, `secretsmanager:UpdateSecretVersionStage` on the secret; KMS `Decrypt`/`Encrypt` on the key; VPC access (subnet, SG) if rotating RDS/DocumentDB/Redshift in VPC.
- **RDS/DocumentDB/Redshift native integration**: Built-in rotation templates for MySQL, PostgreSQL, MariaDB, Oracle, SQL Server (RDS), DocumentDB, Redshift. Secrets Manager manages the Lambda function creation and permissions automatically.

## Automatic rotation

- **Built-in templates**: Provided for RDS (MySQL, PostgreSQL, MariaDB, Oracle, SQL Server), DocumentDB, Redshift. Secrets Manager creates and manages the rotation Lambda.
- **Custom Lambda**: Required for non-native services (e.g., third-party APIs, self-managed DB on EC2, external SaaS). Must implement the 4-step protocol:
  1. `createSecret` — Generate new secret value (new password/token), store as `AWSPENDING`
  2. `setSecret` — Apply new credential to target system (e.g., `ALTER USER`)
  3. `testSecret` — Validate new credential works (test connection)
  4. `finishSecret` — Move `AWSPENDING` → `AWSCURRENT`, `AWSCURRENT` → `AWSPREVIOUS`
- **Rotation schedule**: Cron (UTC) or rate. Minimum 1 day. Rotation window optional (e.g., `2:00-4:00 AM`).
- **Rotation function ARN**: Stored in secret metadata (`RotationRules`). Can be shared across secrets.

## Version staging labels

| Label | Purpose | Typical state |
|-------|---------|---------------|
| `AWSCURRENT` | Active version; returned by default `GetSecretValue` | Always exactly one |
| `AWSPENDING` | Staging version during rotation; being validated | At most one during rotation |
| `AWSPREVIOUS` | Previous version; retained for rollback | At most one |

- Version IDs are UUIDs; staging labels are mutable pointers to versions.
- `GetSecretValue` without `VersionStage` returns `AWSCURRENT`.
- Rotation flow: create `AWSPENDING` → test → `finishSecret` moves labels atomically.

## Cross-region replication

- **Primary + replicas**: One primary region, multiple replica regions. Replicas are read-only.
- **Replication uses regional KMS keys**: Each replica encrypted with KMS key in its region. Specify KMS key per replica or use AWS-managed.
- **Async replication**: Changes to primary propagate to replicas (typically seconds to minutes). Not strongly consistent.
- **Promote replica**: `RemoveRegionsFromReplication` + `ReplicateSecretToRegions` to fail over. Primary becomes replica, promoted replica becomes primary.
- **Deletion**: Delete replicas first, then primary. Or use `ForceDeleteWithoutRecovery` on primary (deletes all).

## Access control

- **Resource-based policies**: Attach policy directly to secret (like S3 bucket policy). Controls who can `GetSecretValue`, `PutSecretValue`, `DeleteSecret`, etc. Supports `Principal`, `Condition` (e.g., `aws:SourceVpce`, `aws:PrincipalOrgID`).
- **IAM policies**: Identity-based permissions on users/roles. Actions: `secretsmanager:GetSecretValue`, `DescribeSecret`, `ListSecrets`, `CreateSecret`, `RotateSecret`, `DeleteSecret`, `PutResourcePolicy`, `TagResource`.
- **KMS key policies (double encryption layer)**: Secret value encrypted with data key → data key encrypted with KMS key. KMS key policy must allow `secretsmanager` service principal for `GenerateDataKey`, `Decrypt`, `Encrypt`. Principal using secret needs `kms:Decrypt` on the key.
- **VPC endpoints**: Interface VPC endpoint (`com.amazonaws.region.secretsmanager`) for private access without internet gateway.

## Pricing

- **Per secret per month**: $0.40 per secret per month (prorated hourly).
- **Per 10,000 API calls**: $0.05 per 10,000 API requests (`GetSecretValue`, `PutSecretValue`, `DescribeSecret`, `ListSecrets`, `RotateSecret`, etc.).
- **Rotation Lambda**: Standard Lambda pricing applies (invocations, duration, memory).
- **Cross-region replication**: Charged per replica secret (same per-secret pricing) + data transfer for replication.

## Common confusion

- **Rotation Lambda vs built-in** — Built-in templates create/manage Lambda automatically for RDS/DocumentDB/Redshift. Custom Lambda required for everything else; you write and manage it.
- **Version labels vs versions** — Versions are immutable (UUID). Labels (`AWSCURRENT`, `AWSPENDING`, `AWSPREVIOUS`) are mutable pointers. Rotation manipulates labels, not version IDs.
- **Replication is async** — Replica may lag primary by seconds to minutes. Do not assume immediate consistency for failover.
- **KMS key policy must allow `secretsmanager`** — The service principal `secretsmanager.amazonaws.com` needs `kms:GenerateDataKey`, `kms:Decrypt`, `kms:Encrypt` on the KMS key. Missing this breaks secret creation/rotation.
- **Rotation requires VPC access for RDS** — Rotation Lambda must run in same VPC as RDS (subnet + SG allowing outbound to DB port). Secrets Manager does not manage this automatically for custom rotations.
- **Minimum rotation interval is 1 day** — Cannot rotate more frequently than once per day.
- **Secret value size limit 65 KB** — Includes JSON structure if storing structured data. Exceeding requires splitting or external storage (S3 + reference in secret).

## Exam mapping

- **Domain 4: Security and Compliance** — Task 4.2 (Implement and manage secrets handling, rotation, and auditing)
  - Secret lifecycle: create, rotate, version, replicate, delete
  - Rotation: schedule, Lambda protocol, built-in vs custom
  - Access: resource policies, IAM, KMS key policies
  - Auditing: CloudTrail logs (`GetSecretValue`, `RotateSecret`, `PutResourcePolicy`)
  - DR: Cross-region replication, promote replica

## Must-remember numbers

| Figure | Value |
|--------|-------|
| Secret value max size | 65 KB |
| Minimum rotation interval | 1 day |
| Max replicas per secret | Limited by enabled regions (practically ~20+) |
| Pricing: per secret/month | $0.40 |
| Pricing: per 10k API calls | $0.05 |
| Staging labels per secret | 3 (AWSCURRENT, AWSPENDING, AWSPREVIOUS) |
| Rotation protocol steps | 4 (createSecret, setSecret, testSecret, finishSecret) |

## Related nodes

- [KMS](../services/kms/README.md) — encrypts-with (secret value encryption, cross-region KMS keys)
- [IAM](../services/iam/README.md) — secured-by (identity policies, resource policies on secrets)
- [Lambda](../services/lambda/README.md) — integrates-with (rotation function execution, VPC config)
- [RDS](../services/rds/README.md) — integrates-with (native rotation templates, credential management)
- [CloudTrail](../services/cloudtrail/README.md) — audited-by (secret access, rotation, policy changes logged)