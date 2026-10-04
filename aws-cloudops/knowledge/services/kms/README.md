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

- **Key policy vs IAM policy for cross-account** — IAM policy in Account B allowing `kms:Encrypt` on Account A's key *does nothing* unless Account A authorizes Account B's principal with a key policy or grant.
- **Rotation eligibility** — Symmetric multi-Region keys with `AWS_KMS` origin support automatic and on-demand rotation from the primary key; rotation is synchronized across the related keys.
- **Deletion is irreversible** — After 7–30 day window, key material is destroyed. No recovery. Ciphertexts encrypted under that key become permanently undecryptable.
- **Grants vs policies** — Grants are temporary, service-friendly, and can authorize same-account or cross-account principals. Policies are durable, human-managed controls.
- **Multi-region key independence** — Replicas share key material and key ID but have regional ARNs and *independent* policies, grants, and aliases. Rotation is shared; a primary key cannot be deleted until all replicas are deleted.
- **External key store / CloudHSM** — `Unavailable` state means KMS cannot reach HSM. Operations fail. Not the same as `Disabled`.

## Exam mapping

- [Domain 4: Security and Compliance](../../../domains/04-security-compliance/README.md) — Task 4.2 (Data protection: encryption at rest/in transit, key management, KMS)

## Must-remember numbers

| Figure | Value |
|--------|-------|
| Deletion waiting window | 7–30 days (configurable per key) |
| Key policy max size | 32 KB |
| Grants per key | 50,000 |
| Max key policy statements | No fixed limit (bounded by 32 KB) |
| Encrypt/Decrypt payload limit | 4 KB (symmetric), varies by algorithm (asymmetric) |
| GenerateDataKey output | 256-bit (AES-256) plaintext + encrypted DEK |
| Automatic rotation interval | ~365 days (annual) |
| Multi-Region key ARN | `arn:aws:kms:region:account-id:key/key-id`; related keys have different regional ARNs but share key ID/material |

(End of file)
