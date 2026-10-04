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
  - title: "Rotate AWS Secrets Manager secrets"
    url: "https://docs.aws.amazon.com/secretsmanager/latest/userguide/rotating-secrets.html"
  - title: "AWS Secrets Manager quotas"
    url: "https://docs.aws.amazon.com/secretsmanager/latest/userguide/reference_limits.html"
  - title: "What's in a Secrets Manager secret?"
    url: "https://docs.aws.amazon.com/secretsmanager/latest/userguide/whats-in-a-secret.html"
  - title: "Secret encryption and decryption in AWS Secrets Manager"
    url: "https://docs.aws.amazon.com/secretsmanager/latest/userguide/security-encryption.html"
last_verified: 2026-10-04
---

# AWS Secrets Manager

## In one paragraph

AWS Secrets Manager centrally stores, manages, and rotates secrets (database credentials, API keys, tokens) throughout their lifecycle. It encrypts secrets at rest using KMS, supports managed rotation for supported service-managed secrets or Lambda rotation for other secret types, provides reserved version staging labels (`AWSCURRENT`, `AWSPENDING`, `AWSPREVIOUS`) for safe rollout, and offers cross-region replication for disaster recovery.

> [!IMPORTANT]
> **Managed rotation and Lambda rotation are different mechanisms.** For SOA-C03 Domain 4 secret-rotation decisions, choose managed rotation when the supported managed secret fits and Lambda when custom rotation is required; confusing them leads to an unnecessary function or an unimplemented rotation workflow.

## Behavior and boundaries

- **Secret storage**: Stores an encrypted secret value up to 65,536 bytes. Metadata (name, description, tags, KMS key ID, rotation configuration) is separate; each secret has one or more versions.
- **Automatic rotation**: Managed rotation for supported service-managed secrets does not use Lambda. Lambda rotation runs on a schedule and invokes a function that implements the 4-step protocol: `createSecret`, `setSecret`, `testSecret`, `finishSecret`.
- **Rotation schedules**: Minimum rotation interval is 1 day. Schedule defined as cron (`cron(0 2 * * ? *)`) or rate (`rate(30 days)`). Rotation window can be specified.
- **Versioning (staging labels)**: Secret versions are referenced by staging labels, not version IDs directly:
  - `AWSCURRENT` — Active version returned by `GetSecretValue` (default)
  - `AWSPENDING` — Staging version being validated during rotation
  - `AWSPREVIOUS` — Previous version (for rollback)
  - These are reserved labels; you can also attach custom staging labels.
- **Cross-region replication**: Primary secret in one Region + read-only replicas in other Regions. Replication is asynchronous. Each replica uses a KMS key in its Region (can be AWS-managed or customer-managed). To promote a replica, remove it from replication; it becomes a standalone secret that can be replicated independently.
- **Secret value encryption**: Double encryption layer — secret value encrypted with a data key, data key encrypted with KMS key. Default: AWS-managed key `aws/secretsmanager`. With a customer-managed key, authorize the relevant principal and KMS operations through the applicable key or IAM policy; Secrets Manager acts on behalf of the caller, so do not assume a universal service-principal allow is required.
- **Rotation Lambda permissions**: Lambda needs `secretsmanager:GetSecretValue`, `secretsmanager:PutSecretValue`, `secretsmanager:UpdateSecretVersionStage` on the secret; KMS `Decrypt`/`Encrypt` on the key; VPC access (subnet, SG) if rotating RDS/DocumentDB/Redshift in VPC.
- **RDS/DocumentDB/Redshift native integration**: Supported service-managed secrets can use managed rotation without a Lambda function. Lambda rotation remains available when a rotation function is required.

## Automatic rotation

- **Managed rotation**: For supported service-managed secrets, the service configures and manages rotation without a Lambda function.
- **Lambda rotation**: For other secret types (for example, third-party APIs, self-managed databases on EC2, or external SaaS), a Lambda function must implement the 4-step protocol:
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
- **Promote replica**: Remove the replica from replication to promote it to a standalone secret. It does not swap primary and replica roles; configure any subsequent replication from the standalone secret independently.
- **Deletion**: Delete replicas first, then primary. Or use `ForceDeleteWithoutRecovery` on primary (deletes all).

## Access control

- **Resource-based policies**: Attach policy directly to secret (like S3 bucket policy). Controls who can `GetSecretValue`, `PutSecretValue`, `DeleteSecret`, etc. Supports `Principal`, `Condition` (e.g., `aws:SourceVpce`, `aws:PrincipalOrgID`).
- **IAM policies**: Identity-based permissions on users/roles. Actions: `secretsmanager:GetSecretValue`, `DescribeSecret`, `ListSecrets`, `CreateSecret`, `RotateSecret`, `DeleteSecret`, `PutResourcePolicy`, `TagResource`.
- **KMS authorization (double encryption layer)**: Secret value encrypted with data key → data key encrypted with KMS key. For a customer-managed key, allow the caller's required KMS operations through the applicable key or IAM policy. `kms:ViaService` can restrict that access to Secrets Manager requests.
- **VPC endpoints**: Interface VPC endpoint (`com.amazonaws.region.secretsmanager`) for private access without internet gateway.

## Pricing

- **Per secret per month**: $0.40 per secret per month (prorated hourly).
- **Per 10,000 API calls**: $0.05 per 10,000 API requests (`GetSecretValue`, `PutSecretValue`, `DescribeSecret`, `ListSecrets`, `RotateSecret`, etc.).
- **Rotation Lambda**: Standard Lambda pricing applies (invocations, duration, memory).
- **Cross-region replication**: Charged per replica secret (same per-secret pricing) + data transfer for replication.

## Common confusion

**Common mistake** — Every Secrets Manager rotation requires a Lambda function and the four-step rotation protocol.

**Actual AWS behavior** — Managed rotation for supported managed secrets does not use Lambda; Lambda rotation is used for other secret types and implements the rotation workflow. [AWS documentation](https://docs.aws.amazon.com/secretsmanager/latest/userguide/rotating-secrets.html)

**Why it matters** — Domain 4 Task 4.2 requires choosing the supported managed-rotation path or a custom Lambda rotation implementation for the secret type.

**Common mistake** — `AWSCURRENT`, `AWSPENDING`, and `AWSPREVIOUS` are immutable secret versions.

**Actual AWS behavior** — Secret versions are immutable, while staging labels are mutable references; `GetSecretValue` returns `AWSCURRENT` by default, and rotation moves labels between versions. [AWS documentation](https://docs.aws.amazon.com/secretsmanager/latest/userguide/whats-in-a-secret.html)

**Why it matters** — Domain 4 Task 4.2 troubleshooting depends on identifying whether the application retrieved the active version or whether rotation has left a pending version to validate.

**Common mistake** — A replica secret is synchronously current with its primary and can be promoted by swapping roles.

**Actual AWS behavior** — Replication is asynchronous, replicas are read-only, and removing a replica from replication promotes it to an independent standalone secret rather than swapping it with the primary. [AWS documentation](https://docs.aws.amazon.com/secretsmanager/latest/userguide/replication.html)

**Why it matters** — Domain 4 Task 4.2 disaster-recovery decisions must account for replica lag and the promotion procedure before directing workloads to another Region.

**Common mistake** — A customer-managed KMS key always needs a Secrets Manager service-principal allow.

**Actual AWS behavior** — Secrets Manager uses KMS on behalf of the caller, so the required KMS operations must be authorized through the applicable key or IAM policy path; a universal service-principal allow is not required. [AWS documentation](https://docs.aws.amazon.com/secretsmanager/latest/userguide/security-encryption.html)

**Why it matters** — Domain 4 Task 4.2 separates secret access authorization from encryption-key authorization when diagnosing failed `GetSecretValue` requests.

## Exam mapping

- **[Domain 4: Security and Compliance](../../../domains/04-security-compliance/README.md)** — Task 4.2 (Implement and manage secrets handling, rotation, and auditing)
  - Secret lifecycle: create, rotate, version, replicate, delete
  - Rotation: schedule, managed rotation, and Lambda protocol
  - Access: resource policies, IAM, KMS key policies
  - Auditing: CloudTrail logs (`GetSecretValue`, `RotateSecret`, `PutResourcePolicy`)
  - DR: Cross-region replication, promote replica

## Must-remember numbers

| Figure | Value |
|--------|-------|
| Minimum rotation interval | 1 day. [AWS documentation](https://docs.aws.amazon.com/secretsmanager/latest/userguide/rotating-secrets.html) |
| Lambda rotation workflow | 4 steps: `createSecret`, `setSecret`, `testSecret`, and `finishSecret`. [AWS documentation](https://docs.aws.amazon.com/secretsmanager/latest/userguide/rotating-secrets.html) |

## Good to know

| Figure | Value |
|--------|-------|
| Secret value maximum size | 65,536 bytes for the encrypted secret value. [AWS documentation](https://docs.aws.amazon.com/secretsmanager/latest/userguide/reference_limits.html) |
| Staging labels across all versions | 20. [AWS documentation](https://docs.aws.amazon.com/secretsmanager/latest/userguide/reference_limits.html) |
