---
title: Task 4.2 - Data and infrastructure protection
domain: 4
official_task: 4.2
last_verified: 2026-10-03
sources:
  - title: AWS SOA-C03 Content Domain 4
    url: https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain4.html
---

# Task 4.2 — Protect data and infrastructure

**Official skills:** 4.2.1 data classification; 4.2.2 encryption at rest/KMS; 4.2.3 encryption in transit/ACM; 4.2.4 secure secret storage; 4.2.5 interpret/remediate Security Hub, GuardDuty, Config, Inspector, and related findings.

## Study / do

- Map a data classification to access, retention, encryption, backup, and disposal controls—not just a label.
- Trace encryption at rest through service configuration, KMS key policy/grants, caller permission, and key lifecycle. Encryption does not itself grant decrypt access.
- Trace TLS client → endpoint → backend; check names, certificate/chain/expiry, and plaintext segments.
- Specify secret rotation, retrieval identity, audit, caching, and failure behavior without exposing values in logs or IaC state.
- Validate a security finding and resource before selecting remediation; confirm closure for the correct reason.

## Check

An application cannot read an encrypted S3 object. Separate checks for S3 authorization and KMS decryption; list safe evidence to gather without exposing object data or secret material.

**Look for:** principal/resource conditions plus key policy/grants and caller permissions, correlated audit evidence, and no secret or object content in notes.
