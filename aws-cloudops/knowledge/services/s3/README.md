---
id: "s3"
kind: "service"
domains: [1, 2, 3, 4]
services: ["s3"]
sources:
  - title: "What is Amazon S3?"
    url: "https://docs.aws.amazon.com/AmazonS3/latest/userguide/Welcome.html"
  - title: "Retaining multiple versions of objects with S3 Versioning"
    url: "https://docs.aws.amazon.com/AmazonS3/latest/userguide/Versioning.html"
  - title: "CloudWatch metrics configurations"
    url: "https://docs.aws.amazon.com/AmazonS3/latest/userguide/metrics-configurations.html"
  - title: "Amazon S3 metrics and dimensions"
    url: "https://docs.aws.amazon.com/AmazonS3/latest/userguide/metrics-dimensions.html"
  - title: "ListBuckets API"
    url: "https://docs.aws.amazon.com/AmazonS3/latest/API/API_ListBuckets.html"
  - title: "ListObjectsV2 API"
    url: "https://docs.aws.amazon.com/AmazonS3/latest/API/API_ListObjectsV2.html"
  - title: "Controlling access from VPC endpoints with bucket policies"
    url: "https://docs.aws.amazon.com/AmazonS3/latest/userguide/example-bucket-policies-vpc-endpoint.html"
  - title: "Conditions with multiple context keys or values"
    url: "https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_condition-logic-multiple-context-keys-or-values.html"
  - title: "Condition operators"
    url: "https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_elements_condition_operators.html"
  - title: "Examples of Amazon S3 bucket policies"
    url: "https://docs.aws.amazon.com/AmazonS3/latest/userguide/example-bucket-policies.html"
  - title: "Troubleshoot access denied errors in Amazon S3"
    url: "https://docs.aws.amazon.com/AmazonS3/latest/userguide/troubleshoot-403-errors.html"
  - title: "SOA-C03 Domain 4"
    url: "https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain4.html"
  - title: "AWS Certified CloudOps Engineer - Associate: Domain 1"
    url: "https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain1.html"
  - title: "AWS Certified CloudOps Engineer - Associate: Domain 2"
    url: "https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain2.html"
  - title: "AWS Certified CloudOps Engineer - Associate: Domain 3"
    url: "https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain3.html"
last_verified: 2026-10-04
---

# Amazon S3

## In one paragraph

Amazon S3 is object storage: buckets contain objects identified by keys, with a version ID also identifying an object when versioning is enabled. It is suited to durable object storage and backup/restore workflows, not to filesystem-style, multi-object transactions.

## Behavior and boundaries

- S3 provides strong read-after-write consistency for object PUT and DELETE operations, including reads and listings after a successful write; updates are atomic only for one key.
- Concurrent writes to the same key use last-writer-wins behavior unless versioning is enabled; versioning retains object variants and can recover accidental overwrite or deletion.
- Bucket configuration changes have eventual consistency, so object consistency must not be generalized to every bucket configuration operation.

## Operational signals

- `BucketSizeBytes` and `NumberOfObjects` show storage inventory; `AllRequests`, `4xxErrors`, `5xxErrors`, and `FirstByteLatency` describe configured request traffic and its result.
- Daily storage metrics are always enabled. Request metrics require a bucket metrics configuration and are delivered on a best-effort basis, so they are not a complete request ledger.
- An enhanced `AccessDenied` error can name only one denial reason or policy type even when several apply. Removing that blocker can reveal another; the message is not an exhaustive policy assessment. [AWS S3 denial diagnostics](https://docs.aws.amazon.com/AmazonS3/latest/userguide/troubleshoot-403-errors.html)

## Authorization and request context

Bucket inventory and object listing are different permissions: `s3api list-buckets` needs `s3:ListAllMyBuckets`; listing objects with `list-objects-v2` needs `s3:ListBucket` on the bucket, not `s3:GetObject` on object ARNs. An empty successful bucket list establishes authorized inventory access, not object access. [ListBuckets](https://docs.aws.amazon.com/AmazonS3/latest/API/API_ListBuckets.html), [ListObjectsV2](https://docs.aws.amazon.com/AmazonS3/latest/API/API_ListObjectsV2.html)

For the fictional endpoint migration, modify only the existing `Deny` statement's endpoint condition to retain V1 and accept V2:

```json
"Condition": {
  "StringNotEquals": {
    "aws:SourceVpce": ["V1", "V2"]
  }
}
```

This is a fragment, not a complete policy; V1/V2 stand for actual endpoint IDs. Multiple values under `StringNotEquals` mean neither matches: the deny applies to an unapproved endpoint. A missing key also matches this negated condition, so a request outside an endpoint remains denied. An approved endpoint avoids this deny but still needs the other authorizations; adding an `Allow` cannot override the existing deny. [AWS endpoint policy example](https://docs.aws.amazon.com/AmazonS3/latest/userguide/example-bucket-policies-vpc-endpoint.html), [multi-value logic](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_condition-logic-multiple-context-keys-or-values.html), [missing-key rules](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_elements_condition_operators.html)

Retain the separate `Deny` with `Bool: {"aws:SecureTransport": "false"}`. Separate statements preserve independent transport and endpoint restrictions; combining those conditions in one statement would require both to match. [AWS HTTPS guardrail](https://docs.aws.amazon.com/AmazonS3/latest/userguide/example-bucket-policies.html), [condition logic](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_condition-logic-multiple-context-keys-or-values.html)

Operational verification for the fictional `ReportsRole`, assuming valid S3 grants/routing, only S3-mediated decrypt authorization, and no encrypt grant: HTTPS/V2/K2 report succeeds; HTTP/V2 is denied; direct K2 decrypt and encrypt stay denied; HTTPS/V1/K1 still succeeds; HTTPS through an unapproved or absent endpoint stays denied. These are expected outcomes, not executed results. The [KMS note](../kms/README.md#s3-mediated-decrypt-versus-a-direct-kms-call) explains the service-only decrypt restriction; [IAM simulator evidence and verification](../iam/README.md#simulator-evidence-and-verification) explains the evidence boundaries.

## Common confusion

- **Common mistake** — Deleting an object from a versioning-enabled bucket permanently removes its recoverable data.
- **Actual AWS behavior** — A delete without a version ID adds a delete marker as the current version instead of permanently removing the object; an overwrite creates a new version, so a prior version can be restored. [Retaining multiple versions of objects with S3 Versioning](https://docs.aws.amazon.com/AmazonS3/latest/userguide/Versioning.html)
- **Why it matters** — [Domain 2](../../../domains/02-reliability-business-continuity/README.md), Task 2.3 includes S3 versioning as a backup and restore choice.

> [!IMPORTANT]
> **S3 Versioning delete markers:** For SOA-C03, a versioned delete normally hides the current object rather than erasing its prior version; treating it as permanent deletion risks selecting an unnecessary or incorrect recovery action.

## Exam mapping

- [Domain 1](../../../domains/01-monitoring-logging-analysis-remediation-performance-optimization/README.md): Task 1.3, Skill 1.3.3 (S3 performance and lifecycle strategies).
- [Domain 2](../../../domains/02-reliability-business-continuity/README.md): Task 2.3, Skills 2.3.1 and 2.3.3 (S3 backup and versioning).
- [Domain 3](../../../domains/03-deployment-provisioning-automation/README.md): Task 3.2, Skill 3.2.2 (S3 event notifications in event-driven automation).
- [Domain 4](../../../domains/04-security-compliance/README.md): Tasks 4.1 and 4.2 (bucket-policy controls, encrypted-object authorization, and TLS enforcement).
