---
id: "s3"
kind: "service"
domains: [1, 2, 3]
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

## Common confusion

- Strong consistency makes a multi-object update transactional -> The guarantee is key-based; S3 has no atomic update across keys.
- Enabling versioning automatically removes prior versions -> Versioning keeps versions until an explicit lifecycle or deletion action manages them.

## Exam mapping

- [Domain 1](../../../domains/01-monitoring-logging-analysis-remediation-performance-optimization/README.md): Task 1.3, Skill 1.3.3 (S3 performance and lifecycle strategies).
- [Domain 2](../../../domains/02-reliability-business-continuity/README.md): Task 2.3, Skills 2.3.1 and 2.3.3 (S3 backup and versioning).
- [Domain 3](../../../domains/03-deployment-provisioning-automation/README.md): Task 3.2, Skill 3.2.2 (S3 event notifications in event-driven automation).
