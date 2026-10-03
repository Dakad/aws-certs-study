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
last_verified: 2026-10-03
---

# AWS Key Management Service (KMS)

## In one paragraph

AWS KMS is a managed service for creating, controlling, and using cryptographic keys. It integrates with AWS services to encrypt data at rest and in transit, and provides a FIPS 140-2 Level 2/3 validated HSM-backed key store. KMS keys never leave the service unencrypted; all cryptographic operations occur within KMS.

## Behavior and boundaries

- **Symmetric vs asymmetric keys**: Symmetric (AES-256) for encrypt/decrypt, GenerateDataKey; asymmetric (RSA/ECC) for sign/verify, encrypt/decrypt, and key agreement. Symmetric keys support envelope encryption; asymmetric do not.
- **Key policies vs IAM policies**: Key policy is the *only* way to allow cross-account access. IAM policy alone cannot grant cross-account KMS permissions. Key policy + IAM policy both evaluated (AND logic) for same-account calls.
- **Grants**: Temporary, granular permissions (e.g., `kms:Decrypt`, `kms:GenerateDataKey`) issued by key owner to principals or AWS services. Used by services like S3, RDS, EBS for encryption. Up to 50,000 grants per key. Retire or revoke to remove.
- **Key rotation**:
  - *Automatic* (annual): Only for symmetric KMS-generated keys (`EnableKeyRotation=true`). AWS manages old key material; ciphertexts decrypt with current or prior key version.
  - *Manual*: `EnableKeyRotation=false`. Create new key, update alias, re-encrypt data. Required for imported key material, asymmetric keys, and multi-region keys.
- **Key states**: `Enabled` (usable), `Disabled` (not usable, reversible), `PendingDeletion` (scheduled, irreversible), `PendingImport` (awaiting imported material), `Unavailable` (external key store disconnected).
- **Deletion**: `ScheduleKeyDeletion` with 7–30 day wait window. Irreversible after window. Key enters `PendingDeletion` state; all operations fail. Alias deleted immediately. Cannot cancel after window.
- **Multi-region keys**: Primary key + replicas in other regions. Same key material (shared key ID), independent policies/grants/rotation. Replicas readable/writable. `UpdatePrimaryRegion` promotes replica. Deleting primary schedules deletion of all replicas after window.
- **External key store**: Keys stored in external HSM (CloudHSM or external key manager via XKS proxy). KMS never sees plaintext key material. `Unavailable` state if connectivity lost.
- **CloudHSM integration**: Custom key store backed by CloudHSM cluster. Keys generated/stored in HSM; KMS forwards operations. Supports symmetric and asymmetric.

## Key policy vs IAM policy distinction (exam-critical)

- **Key policy is mandatory** — Every KMS key has exactly one key policy (max 32 KB). It is the *resource policy*.
- **Cross-account access** — Only possible via key policy (`Principal` with external account ARN). IAM policy in the external account *alone* is insufficient; the key policy must explicitly allow the external principal.
- **Same-account calls** — Both key policy and caller's IAM policy must allow the action (implicit AND).
- **Default key policy** — Allows root user full access; delegates to IAM policies via `"Sid": "Allow access for Key Administrators"` and `"Sid": "Allow use of the key"`.

## Grant mechanism

- **Purpose**: Temporary, fine-grained permissions without editing key policy.
- **Issued by**: Key owner (or principal with `kms:CreateGrant`).
- **Used by**: AWS services (S3, RDS, EBS, Lambda, etc.) for envelope encryption operations on your behalf.
- **Operations**: `CreateGrant`, `RetireGrant` (by grantee or token), `RevokeGrant` (by key admin), `ListGrants`, `ListRetirableGrants`.
- **Constraints**: 50,000 grants per key. Grantee principal must be in same account (or assumable role). Grants survive key policy changes; revoking is immediate.

## Key rotation detail

| Type | Applies to | Mechanism | Ciphertext compatibility |
|------|------------|-----------|--------------------------|
| Automatic | Symmetric KMS-generated keys only | Annual, AWS-managed key versions | Decrypt works with any version |
| Manual | Imported keys, asymmetric, multi-region | Create new key, update alias, re-encrypt | Old key must remain for decryption |

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

- **Key policy vs IAM policy for cross-account** — IAM policy in Account B allowing `kms:Encrypt` on Account A's key *does nothing* unless Account A's key policy allows Account B's principal.
- **Rotation only for symmetric AWS-managed keys** — Asymmetric, imported, and multi-region keys cannot use automatic rotation.
- **Deletion is irreversible** — After 7–30 day window, key material is destroyed. No recovery. Ciphertexts encrypted under that key become permanently undecryptable.
- **Grants vs policies** — Grants are temporary, service-friendly, and survive key policy changes. Policies are permanent, human-managed, and support cross-account.
- **Multi-region key independence** — Replicas share key material but have *independent* policies, grants, aliases, and rotation state. Deleting primary schedules deletion of all replicas.
- **External key store / CloudHSM** — `Unavailable` state means KMS cannot reach HSM. Operations fail. Not the same as `Disabled`.

## Exam mapping

- [Domain 4: Security and Compliance](../domains/04-security-compliance/README.md) — Task 4.2 (Data protection: encryption at rest/in transit, key management, KMS)

## Must-remember numbers

| Figure | Value |
|--------|-------|
| Deletion waiting window | 7–30 days (configurable per key) |
| Key policy max size | 32 KB |
| Grants per key | 50,000 |
| Multi-region key replicas | Up to 10 (1 primary + 9 replicas) |
| Max key policy statements | No fixed limit (bounded by 32 KB) |
| Encrypt/Decrypt payload limit | 4 KB (symmetric), varies by algorithm (asymmetric) |
| GenerateDataKey output | 256-bit (AES-256) plaintext + encrypted DEK |
| Automatic rotation interval | ~365 days (annual) |
| Key ID / ARN format | `arn:aws:kms:region:account-id:key/key-id` (global for multi-region) |

## Related nodes

- [IAM](../services/iam/README.md) — secured-by (key policies, IAM policies, grants)
- [Secrets Manager](../services/secretsmanager/README.md) — encrypts-for (uses KMS for secret encryption)
- [S3](../services/s3/README.md) — encrypts-for (SSE-KMS, bucket keys)
- [RDS](../services/rds/README.md) — encrypts-for (storage encryption, KMS key per instance)
- [CloudTrail](../services/cloudtrail/README.md) — audited-by (KMS API calls logged)

(End of file)