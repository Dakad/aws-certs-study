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
  - title: "Enable automatic key rotation"
    url: "https://docs.aws.amazon.com/kms/latest/developerguide/rotating-keys-enable.html"
  - title: "Multi-Region keys in AWS KMS"
    url: "https://docs.aws.amazon.com/kms/latest/developerguide/multi-region-keys-overview.html"
  - title: "Delete an AWS KMS key"
    url: "https://docs.aws.amazon.com/kms/latest/developerguide/deleting-keys.html"
  - title: "AWS KMS keys: ownership and identifiers"
    url: "https://docs.aws.amazon.com/kms/latest/developerguide/concepts.html"
  - title: "Default key policy"
    url: "https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html"
  - title: "Allowing users in other accounts to use a KMS key"
    url: "https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-modifying-external-accounts.html"
  - title: "Permissions boundaries for IAM entities"
    url: "https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_boundaries.html"
  - title: "IAM policy evaluation logic"
    url: "https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_evaluation-logic.html"
  - title: "Using server-side encryption with AWS KMS keys (SSE-KMS)"
    url: "https://docs.aws.amazon.com/AmazonS3/latest/userguide/UsingKMSEncryption.html"
  - title: "Protecting data in transit with encryption"
    url: "https://docs.aws.amazon.com/AmazonS3/latest/userguide/UsingEncryptionInTransit.html"
  - title: "Logging AWS KMS API calls with AWS CloudTrail"
    url: "https://docs.aws.amazon.com/kms/latest/developerguide/logging-using-cloudtrail.html"
  - title: "Generate data keys"
    url: "https://docs.aws.amazon.com/kms/latest/developerguide/data-keys.html"
  - title: "KMS key stores"
    url: "https://docs.aws.amazon.com/kms/latest/developerguide/key-store-overview.html"
  - title: "Encrypt API reference"
    url: "https://docs.aws.amazon.com/kms/latest/APIReference/API_Encrypt.html"
  - title: "GenerateDataKeyPair API reference"
    url: "https://docs.aws.amazon.com/kms/latest/APIReference/API_GenerateDataKeyPair.html"
  - title: "ReEncrypt API reference"
    url: "https://docs.aws.amazon.com/kms/latest/APIReference/API_ReEncrypt.html"
  - title: "Creating a key policy"
    url: "https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-overview.html"
  - title: "AWS KMS resource quotas"
    url: "https://docs.aws.amazon.com/kms/latest/developerguide/resource-limits.html"
  - title: "Key states of AWS KMS keys"
    url: "https://docs.aws.amazon.com/kms/latest/developerguide/key-state.html"
  - title: "SOA-C03 Domain 4: Security and Compliance"
    url: "https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain4.html"
last_verified: 2026-10-04
---

# AWS Key Management Service (KMS)

## In one paragraph

AWS KMS manages cryptographic keys and controls who can use them. Integrated services use KMS to protect data keys for encryption at rest; HTTPS/TLS protects the request in transit. Standard KMS keys are protected by FIPS 140-3 Security Level 3 validated HSMs and never leave KMS unencrypted. Data keys are different: authorized callers can receive plaintext data keys for encryption outside KMS. [KMS overview](https://docs.aws.amazon.com/kms/latest/developerguide/overview.html), [data keys](https://docs.aws.amazon.com/kms/latest/developerguide/data-keys.html)

> [!IMPORTANT]
> **A KMS key policy is an authorization boundary, not an optional companion to IAM.** For SOA-C03 Domain 4 data-protection decisions, a cross-account caller needs authorization from the key owner; assuming its IAM allow is sufficient produces `AccessDenied`.

## Who manages the key?

These are ownership categories, not different encryption algorithms:

- **Customer-managed key:** In your account; authorized customer principals control its policy, grants, aliases, and lifecycle, including disabling and scheduling deletion. Among these three categories, this is the one you can administer. `DescribeKey` identifies it with `KeyManager: CUSTOMER`.
- **AWS-managed key:** In your account, but an AWS service manages it. You can view its metadata and policy and audit usage, but cannot edit the policy or control its lifecycle. An alias such as `aws/s3` identifies the service; `KeyManager` is `AWS`.
- **AWS-owned key:** In an AWS service's account, not yours. You cannot administer the key or inspect its key policy and usage logs.

“Customer-managed” does not mean you can download a symmetric KMS key's plaintext material. It describes administrative control. Customer-managed keys can incur key-storage and request charges; do not create one merely to follow a written example. [AWS key categories](https://docs.aws.amazon.com/kms/latest/developerguide/concepts.html)

## Behavior and boundaries

- **Symmetric vs asymmetric keys**: Symmetric encryption keys protect data and generated data keys. Asymmetric operations depend on the key specification and usage; not every asymmetric key supports encryption. KMS data-key generation requires a symmetric encryption KMS key. [GenerateDataKeyPair](https://docs.aws.amazon.com/kms/latest/APIReference/API_GenerateDataKeyPair.html)
- **Authorization**: Check the key-side authorization path, the caller's permissions, and applicable restrictions. Same-account direct key-policy permission differs from cross-account policy authorization; see the distinction below.
- **Grants**: Scoped allow permissions on one key, created by an authorized principal. Often used by integrated services and removed by retirement or revocation; “temporary use” is not a substitute for grant cleanup. See [grant mechanism](#grant-mechanism).
- **Key rotation**:
  - *Automatic*: Opt-in for eligible customer-managed symmetric encryption keys with `AWS_KMS` origin; annual by default when enabled. Key ARN and policies stay the same; earlier material remains available for decryption. K2 as a separate key is not an automatic rotation of K1. [Automatic rotation](https://docs.aws.amazon.com/kms/latest/developerguide/rotating-keys-enable.html)
  - *Manual*: Create a new key and update the application's key reference or alias when neither automatic nor on-demand rotation is supported, such as for asymmetric, HMAC, and custom-key-store keys. Keep the old key usable for old ciphertext, or re-encrypt that data before retiring it.
- **Key states**: `Enabled` (usable), `Disabled` (not usable, reversible), `PendingDeletion` (scheduled and cancellable during the waiting period), `PendingImport` (awaiting imported material), `Unavailable` (custom key store intentionally disconnected). Backing-key failure can prevent operations without changing the KMS key state. [Key states](https://docs.aws.amazon.com/kms/latest/developerguide/key-state.html)
- **Deletion**: `ScheduleKeyDeletion` has a 7–30 day wait window. Deletion is cancellable during that window; after it expires, deletion is irreversible and removes the key's aliases. A primary multi-Region key enters `PendingReplicaDeletion` while replicas remain: schedule and delete every replica first, then the primary key's waiting period begins.
- **Multi-region keys**: Primary key + replicas in other Regions. Related keys share key ID and key material, but each ARN is regional and policies, grants, aliases, and most administration are independent. Rotation is a shared property; for symmetric keys with `AWS_KMS` origin, enable automatic rotation or initiate on-demand rotation from the primary key.
- **External key store**: A custom key store backed by a key manager outside AWS, connected through an XKS proxy. This is distinct from a CloudHSM key store; key-manager availability becomes your responsibility.
- **CloudHSM integration**: A custom key store backed by your AWS CloudHSM cluster. KMS keys in custom key stores support symmetric encryption only, even though CloudHSM itself has broader capabilities. [KMS key stores](https://docs.aws.amazon.com/kms/latest/developerguide/key-store-overview.html)

## Key policy vs IAM policy distinction (exam-critical)

Every KMS key has exactly one key policy: its resource policy. An IAM allow is not evidence that the key permits the caller to use it. [Key policies](https://docs.aws.amazon.com/kms/latest/developerguide/key-policies.html)

### Same-account authorization

A key policy can directly allow a principal, or enable the account to delegate permissions through IAM policies. Under the IAM-delegation path, the role needs an IAM allow for the requested action on the key. Grants provide another authorization path; an applicable explicit deny still overrides an allow.

For the role/IAM-delegation cases practiced here, an attached permissions boundary must also permit the action and key. A boundary is a ceiling, not a grant. Session and organization restrictions can further limit access. Direct grants to same-account role sessions have different evaluation rules; do not generalize this boundary check to every resource-policy principal form. [Key policies](https://docs.aws.amazon.com/kms/latest/developerguide/key-policies.html), [permissions boundaries](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_boundaries.html)

### What the default policy actually delegates

The default account-principal statement, commonly named `Enable IAM User Permissions`, enables IAM delegation. Its `arn:aws:iam::<account-id>:root` principal represents the account; it does not mean every IAM identity automatically receives key access.

Programmatic creation without a supplied policy gets that account-level statement. Console creation adds statements for the selected administrators and users. Administration and cryptographic use are separate permission sets; the administrator statement is not the IAM-delegation statement. [Default key policy](https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html)

### Cross-account authorization

For policy-based access to a key in account A by a role in account B, **both sides must authorize the operation**:

- Account A's key policy allows the external account or role to use the key.
- Account B's role IAM policy allows the operation on that key's full ARN.

Even an explicit external-role allow in the key policy does not replace the caller's IAM allow. Grants are an alternative authorization mechanism; the worked examples below assume none. Modify only the policy missing the required permission, not both policies by default. [Cross-account KMS access](https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-modifying-external-accounts.html)

In a key policy, `Resource: "*"` refers to the key that policy is attached to. In the caller's IAM policy, use the specific key ARN rather than `"*"` to avoid allowing unrelated keys. [Creating a key policy](https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-overview.html)

## Least-privilege decryption: worked cases

These original examples summarize the authorization reasoning from the lesson. K1, K2, and K3 are fictional customer-managed keys; they are not lab resources or executed test results.

### K1 works; K2 fails

Assume both same-account key policies enable IAM delegation, with no direct grants or other restrictions. The role IAM policy permits `kms:Decrypt` on K1 and K2, but its boundary permits that action only on K1. The K2 request is blocked by missing boundary coverage, not by a missing IAM allow.

The correction is to add `kms:Decrypt` on K2's specific ARN to the boundary while retaining K1. Do not detach the boundary or expand to `kms:*`. If IAM and boundary permissions already cover K2, inspect its key policy and any applicable conditions next instead of adding duplicate allows. [IAM evaluation](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_evaluation-logic.html)

### The external role is named in K3's policy; decryption still fails

K3 belongs to account A. Its key policy already permits `ReportsReader` in account B to decrypt; the boundary permits it too, but the role IAM policy contains no KMS permission. Add the following identity-policy statement in account B. Leave K3's already-sufficient key policy unchanged.

```json
{
  "Effect": "Allow",
  "Action": "kms:Decrypt",
  "Resource": "arn:aws:kms:<region>:<account-a-id>:key/<k3-key-id>"
}
```

This is an illustrative statement, not a deployable policy document: replace the placeholders and include it in the role's `Statement` array. It does not grant `kms:Encrypt` or authorize S3 access. [Key-policy and cross-account requirements](https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-overview.html)

## Operational signals and investigation

Start with the actual caller, requested operation, key ARN/account/Region, and request context. Do not diagnose a KMS policy fault from an application's generic `403` alone.

1. Identify the failed request path. For an encrypted report download, separate S3 object authorization and HTTPS requirements from the KMS operation.
2. Inspect the KMS CloudTrail event: `eventSource: kms.amazonaws.com`, operation such as `Decrypt`, caller identity, key reference, and error. A `Decrypt` event with an access-denied error establishes a KMS authorization failure for that request; it does not by itself identify the blocking policy.
3. Compare the role IAM policy and boundary, applicable session/organization restrictions, then the key policy or grant path. Check matching conditions, not just the presence of an allow statement. This is an investigation order, not an AWS policy-evaluation execution order.
4. Check key state and the reported error before changing permissions. Disabled keys, wrong key selection, and incompatible encryption context require different corrections from a missing allow.

CloudTrail also records changes such as `PutKeyPolicy`, `DisableKey`, and grant operations. Cross-account access-denied KMS requests are logged only in the caller's account; successful cross-account operations are logged in both accounts. Trails can exclude KMS events, so an absent event is not proof that KMS was unused. [KMS CloudTrail logging](https://docs.aws.amazon.com/kms/latest/developerguide/logging-using-cloudtrail.html), [key states](https://docs.aws.amazon.com/kms/latest/developerguide/key-state.html), [IAM evaluation](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_evaluation-logic.html)

### Applying the check to S3-backed readers

An ordinary SSE-KMS download needs `s3:GetObject` on the object and `kms:Decrypt` on its key. Uploads use `kms:GenerateDataKey`; multipart uploads also need `kms:Decrypt`. Therefore, denying `kms:Encrypt` alone does **not** prove that S3 uploads are impossible. Cross-account sharing of SSE-KMS objects requires a customer-managed key, not `aws/s3`. [S3 SSE-KMS permissions](https://docs.aws.amazon.com/AmazonS3/latest/userguide/UsingKMSEncryption.html)

Encryption at rest does not replace TLS. SSE-KMS GET/PUT requests must use TLS. A bucket-policy deny when `aws:SecureTransport` is `false` independently enforces HTTPS; changing KMS permissions cannot fix that deny. In the combined HTTP/K2 case, changing the client to HTTPS exposes the remaining K2 boundary failure. Keep the transport guardrail and correct the boundary separately. [SSE-KMS request requirements](https://docs.aws.amazon.com/AmazonS3/latest/userguide/UsingKMSEncryption.html), [HTTPS enforcement](https://docs.aws.amazon.com/AmazonS3/latest/userguide/UsingEncryptionInTransit.html)

### Define verification outcomes before testing

For the fictional read-only role, after the scoped corrections and assuming no other grants/restrictions, expect:

- A real HTTPS download of the K2-encrypted report succeeds and returns the expected content.
- The same valid request over HTTP remains denied.
- `kms:Encrypt` on K2 remains denied; `s3:PutObject` remains denied as a separate write-permission check.
- An existing HTTPS download of a K1-encrypted report still succeeds.

Use the application role, same object/key, and relevant request context—not administrator credentials. A direct KMS test alone does not verify the S3 path; a denied direct call may also reflect service/context conditions. These are operational test expectations, not observed lab outcomes. Learner evidence remains in [PROGRESS.md](../../../../PROGRESS.md) and the [Domain 4 record](../../../domains/04-security-compliance/README.md).

## Grant mechanism

- **Purpose**: Fine-grained allow permissions without editing the key policy for every use; often used temporarily, then retired or revoked.
- **Issued by**: A principal authorized for `kms:CreateGrant` on the key; ownership alone is not an authorization check.
- **Used by**: Integrated AWS services for authorized operations on your behalf; check the individual service's encryption documentation rather than assuming every integration uses grants.
- **Operations**: `CreateGrant`, `RetireGrant`, `RevokeGrant`, `ListGrants`, `ListRetirableGrants`. Authorized retirement or revocation deletes the grant and removes its permissions after propagation.
- **Constraints**: Grants allow supported operations on exactly one key; they cannot express a deny. A grantee can be in the same or another account. Creation, retirement, and revocation are eventually consistent; a grant token can make a new grant usable immediately. [Grants](https://docs.aws.amazon.com/kms/latest/developerguide/grants.html)

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
| Unavailable | ❌ | ✅ | — | Accepted; state change waits for availability | ✅ |

This is a summary, not a substitute for the operation-specific state rules. An enabled key still needs authorization and compatible key usage. [Key-state reference](https://docs.aws.amazon.com/kms/latest/developerguide/key-state.html)

## Cryptographic operations

| Operation | Symmetric | Asymmetric | Use case |
|-----------|-----------|------------|----------|
| `Encrypt` / `Decrypt` | ✅ | ✅ (encryption-capable keys) | Symmetric `Encrypt`: up to 4,096 plaintext bytes; asymmetric limits depend on algorithm |
| `GenerateDataKey` / `GenerateDataKeyWithoutPlaintext` | ✅ | ❌ | Envelope encryption |
| `GenerateDataKeyPair` / `GenerateDataKeyPairWithoutPlaintext` | ✅ (not custom key stores) | ❌ | Generates an external asymmetric data key pair; protects its private key with a symmetric KMS key |
| `Sign` / `Verify` | ❌ | ✅ (RSA/ECC) | Digital signatures |
| `DeriveSharedSecret` | ❌ | ✅ (ECC) | Key agreement (ECDH) |
| `ReEncrypt` | ✅ | ✅ (encryption-capable keys) | Translates KMS-compatible ciphertext between keys |

The columns describe the protecting **KMS key**, not the generated data key's type. [Encrypt](https://docs.aws.amazon.com/kms/latest/APIReference/API_Encrypt.html), [GenerateDataKeyPair](https://docs.aws.amazon.com/kms/latest/APIReference/API_GenerateDataKeyPair.html), [ReEncrypt](https://docs.aws.amazon.com/kms/latest/APIReference/API_ReEncrypt.html)

## Envelope encryption pattern

1. Call `GenerateDataKey` → returns a **plaintext data encryption key (DEK)** and an **encrypted DEK**, protected by the KMS key. `GenerateDataKeyWithoutPlaintext` returns only the encrypted DEK; obtaining its plaintext requires a later authorized `Decrypt`.
2. Use plaintext DEK locally to encrypt data (AES-GCM, etc.).
3. **Discard plaintext DEK**.
4. Store **encrypted DEK + ciphertext** together.
5. To decrypt: Call `Decrypt` on encrypted DEK → get plaintext DEK → decrypt data locally.

This pattern keeps bulk-data encryption outside KMS. KMS protects the DEK; the application or integrated service encrypts the payload. [Data-key lifecycle](https://docs.aws.amazon.com/kms/latest/developerguide/data-keys.html)

## Common confusion

**Common mistake** — An IAM allow in Account B is enough for Account B to use a KMS key owned by Account A.

**Actual AWS behavior** — Policy-based cross-account use requires both an owner-account key-policy allow and a caller-account IAM allow. Naming the external role in the key policy alone is still insufficient; grants are a separate authorization mechanism. [AWS documentation](https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-modifying-external-accounts.html)

**Why it matters** — Domain 4 Task 4.2 requires selecting the correct authorization path for encrypted data, rather than diagnosing a cross-account KMS failure as an IAM-policy-only problem.

**Common mistake** — A permissions-boundary allow grants decryption, or an IAM allow overrides a boundary that excludes K2.

**Actual AWS behavior** — Under the IAM-delegation path, the boundary limits the IAM grant; both must permit the operation on K2. A missing boundary allow is an implicit restriction, not necessarily an explicit deny statement. [AWS documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_boundaries.html)

**Why it matters** — Correct the narrow missing permission in the right layer rather than removing the boundary or adding a broader IAM allow.

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
| Direct symmetric `Encrypt` plaintext | 4,096 bytes maximum; use envelope encryption for larger data. Ciphertext input limits are different. [AWS documentation](https://docs.aws.amazon.com/kms/latest/APIReference/API_Encrypt.html) |

## Good to know

| Figure | Value |
|--------|-------|
| Key policy maximum size | 32 KB. [AWS documentation](https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-overview.html) |
| Grants per customer-managed key | Default quota: 50,000; adjustable. [AWS documentation](https://docs.aws.amazon.com/kms/latest/developerguide/resource-limits.html) |
| Automatic rotation interval | Default: 365 days when enabled; configurable for eligible customer-managed keys. [AWS documentation](https://docs.aws.amazon.com/kms/latest/developerguide/rotating-keys-enable.html) |

(End of file)
