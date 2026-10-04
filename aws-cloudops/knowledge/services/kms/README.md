---
id: "kms"
kind: "service"
domains: [4]
services: ["kms"]
related:
  - relation: "secured-by"
    target: "iam"
  - relation: "encrypts-for"
    target: "secretsmanager"
  - relation: "encrypts-for"
    target: "s3"
  - relation: "encrypts-for"
    target: "rds"
  - relation: "audited-by"
    target: "cloudtrail"
sources:
  - title: "AWS Key Management Service Developer Guide"
    url: "https://docs.aws.amazon.com/kms/latest/developerguide/overview.html"
  - title: "AWS KMS Cryptographic Details"
    url: "https://docs.aws.amazon.com/kms/latest/cryptographic-details/whitepaper.html"
  - title: "Key policies in AWS KMS"
    url: "https://docs.aws.amazon.com/kms/latest/developerguide/key-policies.html"
  - title: "Grants in AWS KMS"
    url: "https://docs.aws.amazon.com/kms/latest/developerguide/grants.html"
  - title: "Rotate AWS KMS keys"
    url: "https://docs.aws.amazon.com/kms/latest/developerguide/rotate-keys.html"
  - title: "Multi-Region keys in AWS KMS"
    url: "https://docs.aws.amazon.com/kms/latest/developerguide/multi-region-keys-overview.html"
  - title: "Delete an AWS KMS key"
    url: "https://docs.aws.amazon.com/kms/latest/developerguide/deleting-keys.html"
last_verified: 2026-10-04
---

# AWS Key Management Service (KMS)

## In one paragraph

AWS KMS is a managed service for creating, controlling, and using cryptographic keys. It integrates with AWS services to encrypt data at rest and in transit, and provides a FIPS 140-2 Level 2/3 validated HSM-backed key store. KMS keys never leave the service unencrypted; all cryptographic operations occur within KMS.

> [!IMPORTANT]
> **A KMS key policy is an authorization boundary, not an optional companion to IAM.** For SOA-C03 Domain 4 data-protection decisions, a cross-account caller needs authorization from the key owner; assuming its IAM allow is sufficient produces `AccessDenied`.

## Behavior and boundaries

- **Symmetric vs asymmetric keys**: Symmetric (AES-256) for encrypt/decrypt, GenerateDataKey; asymmetric (RSA/ECC) for sign/verify, encrypt/decrypt, and key agreement. Symmetric keys support envelope encryption; asymmetric do not.
- **Key policies vs IAM policies**: A key policy can directly allow a principal. An IAM policy can allow access only when the key policy enables IAM-policy delegation; an explicit deny still wins. IAM policy alone cannot grant cross-account KMS permissions, but a grant can name a cross-account principal.
- **Grants**: Temporary, granular permissions (e.g., `kms:Decrypt`, `kms:GenerateDataKey`) issued by key owner to principals or AWS services. Used by services like S3, RDS, EBS for encryption. Up to 50,000 grants per key. Retire or revoke to remove.
- **Key rotation**:
  - *Automatic* (annual by default): Supported for symmetric encryption keys with `AWS_KMS` origin. AWS manages old key material; ciphertexts decrypt with current or prior key version.
  - *Manual*: Create a new key, update an alias, and re-encrypt data when neither automatic nor on-demand rotation is supported, such as for asymmetric, HMAC, and custom-key-store keys.
- **Key states**: `Enabled` (usable), `Disabled` (not usable, reversible), `PendingDeletion` (scheduled and cancellable during the waiting period), `PendingImport` (awaiting imported material), `Unavailable` (external key store disconnected).
- **Deletion**: `ScheduleKeyDeletion` has a 7–30 day wait window. Deletion is cancellable during that window; after it expires, deletion is irreversible and removes the key's aliases. A primary multi-Region key enters `PendingReplicaDeletion` while replicas remain: schedule and delete every replica first, then the primary key's waiting period begins.
- **Multi-region keys**: Primary key + replicas in other Regions. Related keys share key ID and key material, but each ARN is regional and policies, grants, aliases, and most administration are independent. Rotation is a shared property; for symmetric keys with `AWS_KMS` origin, enable automatic rotation or initiate on-demand rotation from the primary key.
- **External key store**: Keys stored in external HSM (CloudHSM or external key manager via XKS proxy). KMS never sees plaintext key material. `Unavailable` state if connectivity lost.
- **CloudHSM integration**: Custom key store backed by CloudHSM cluster. Keys generated/stored in HSM; KMS forwards operations. Supports symmetric and asymmetric.

## Key policy vs IAM policy distinction (exam-critical)

- **Key policy is mandatory** — Every KMS key has exactly one key policy (max 32 KB). It is the *resource policy*.
- **Cross-account access** — An IAM policy in the external account alone is insufficient. The key owner can authorize the external principal with a key policy or a grant.
- **Same-account calls** — A key policy can directly allow the caller. If it enables IAM-policy delegation, the caller's IAM allow can provide the allow; explicit deny overrides either path.
- **Default key policy** — Allows root user full access; delegates to IAM policies via `"Sid": "Allow access for Key Administrators"` and `"Sid": "Allow use of the key"`.

## Grant mechanism

- **Purpose**: Temporary, fine-grained permissions without editing key policy.
- **Issued by**: Key owner (or principal with `kms:CreateGrant`).
- **Used by**: AWS services (S3, RDS, EBS, Lambda, etc.) for envelope encryption operations on your behalf.
- **Operations**: `CreateGrant`, `RetireGrant` (by grantee or token), `RevokeGrant` (by key admin), `ListGrants`, `ListRetirableGrants`.
- **Constraints**: 50,000 grants per key. A grantee principal can be in the same account or a different account. Grants survive key policy changes; revoking is eventually consistent.

## Key rotation detail

| Type | Applies to | Mechanism | Ciphertext compatibility |
|------|------------|-----------|--------------------------|
| Automatic | Symmetric encryption keys with `AWS_KMS` origin, including eligible multi-Region keys | Annual by default, AWS-managed key versions | Decrypt works with any version |
| Manual | Keys without automatic or on-demand rotation support | Create new key, update alias, re-encrypt | Old key must remain for decryption |

## Key states and allowed operations

| State | Encrypt/Decrypt | ScheduleDeletion | CancelDeletion | Enable/Disable | DescribeKey |
|-------|-----------------|------------------|----------------|----------------|-------------|
| Enabled | ✅ | ✅ | — | ✅ Disable | ✅ |
| Disabled | ❌ | ✅ | — | ✅ Enable | ✅ |
| PendingDeletion | ❌ | ❌ | ✅ (within window) | ❌ | ✅ |
| PendingImport | ❌ | ✅ | — | ❌ | ✅ |
| Unavailable | ❌ | ✅ | — | ❌ | ✅ |

## Cryptographic operations

| Operation | Symmetric | Asymmetric | Use case |
|-----------|-----------|------------|----------|
| `Encrypt` / `Decrypt` | ✅ | ✅ (RSA) | Small payloads (<4 KB) |
| `GenerateDataKey` / `GenerateDataKeyWithoutPlaintext` | ✅ | ❌ | Envelope encryption |
| `GenerateDataKeyPair` / `GenerateDataKeyPairWithoutPlaintext` | ❌ | ✅ | Asymmetric data keys |
| `Sign` / `Verify` | ❌ | ✅ (RSA/ECC) | Digital signatures |
| `DeriveSharedSecret` | ❌ | ✅ (ECC) | Key agreement (ECDH) |
| `ReEncrypt` | ✅ | ❌ | Ciphertext translation (key rotation) |

## Envelope encryption pattern

1. Call `GenerateDataKey` (or `GenerateDataKeyWithoutPlaintext`) → returns **plaintext DEK** + **encrypted DEK** (wrapped by KMS key).
2. Use plaintext DEK locally to encrypt data (AES-GCM, etc.).
3. **Discard plaintext DEK**.
4. Store **encrypted DEK + ciphertext** together.
5. To decrypt: Call `Decrypt` on encrypted DEK → get plaintext DEK → decrypt data locally.

> This pattern avoids sending large data to KMS (4 KB limit) and reduces KMS API calls/cost.

## Common confusion

**Common mistake** — An IAM allow in Account B is enough for Account B to use a KMS key owned by Account A.

**Actual AWS behavior** — Every KMS key has a key policy, and IAM allows have no effect unless the key policy enables IAM-policy delegation; the key owner can instead authorize use with a key policy or grant. [AWS documentation](https://docs.aws.amazon.com/kms/latest/developerguide/key-policies.html)

**Why it matters** — Domain 4 Task 4.2 requires selecting the correct authorization path for encrypted data, rather than diagnosing a cross-account KMS failure as an IAM-policy-only problem.

**Common mistake** — Scheduling deletion is equivalent to a reversible disable, or expiry of the waiting period can be undone.

**Actual AWS behavior** — A pending-deletion key cannot perform cryptographic operations; cancellation is possible only before the mandatory waiting period ends, after which deletion is irreversible and encrypted data can become unrecoverable. [AWS documentation](https://docs.aws.amazon.com/kms/latest/developerguide/deleting-keys.html)

**Why it matters** — Domain 4 Task 4.2 scenarios distinguish a temporary access interruption, where disabling may fit, from irreversible key destruction that can make protected data unreadable.

**Common mistake** — Multi-Region KMS replicas are interchangeable regional copies with one shared policy and alias configuration.

**Actual AWS behavior** — Related multi-Region keys share key material and key ID, but their ARNs, policies, grants, and aliases are regional and independent; a primary cannot be deleted until its replicas are deleted. [AWS documentation](https://docs.aws.amazon.com/kms/latest/developerguide/multi-region-keys-overview.html)

**Why it matters** — Domain 4 Task 4.2 requires checking the regional key policy and replica lifecycle rather than assuming an authorization or deletion change propagates automatically.

## Exam mapping

- [Domain 4: Security and Compliance](../../../domains/04-security-compliance/README.md) — Task 4.2 (Data protection: encryption at rest/in transit, key management, KMS)

## Must-remember numbers

| Figure | Value |
|--------|-------|
| Deletion waiting window | 7-30 days, configurable per key. [AWS documentation](https://docs.aws.amazon.com/kms/latest/developerguide/deleting-keys.html) |
| Direct symmetric `Encrypt`/`Decrypt` payload | 4 KB maximum; use envelope encryption for larger data. [AWS documentation](https://docs.aws.amazon.com/kms/latest/developerguide/overview.html) |

## Good to know

| Figure | Value |
|--------|-------|
| Key policy maximum size | 32 KB. [AWS documentation](https://docs.aws.amazon.com/kms/latest/developerguide/key-policies.html) |
| Grants per key | 50,000. [AWS documentation](https://docs.aws.amazon.com/kms/latest/developerguide/grants.html) |
| Automatic rotation interval | Approximately 365 days (annual). [AWS documentation](https://docs.aws.amazon.com/kms/latest/developerguide/rotate-keys.html) |

(End of file)
