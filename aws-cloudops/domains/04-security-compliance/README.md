# Domain 4 — Security and Compliance

**Exam weight:** 16% of scored content  
**Status:** Practiced — access-control scenarios; Lab 03 pending  
**Official objective:** [AWS Domain 4 guide](https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain4.html) (scope checked 2026-10-03)

## What this domain is about

Apply and troubleshoot access controls, meet policy/compliance requirements, and protect data and infrastructure. Exam scenarios often require finding the correct control point—identity policy, resource policy, organization guardrail, network boundary, encryption configuration, or secrets service—and interpreting audit/security findings.

## Official task areas and study guides

| Official task | What to study | Task guide |
|---|---|---|
| **4.1 — Implement and manage security and compliance tools and policies** | IAM features, access auditing, multi-account controls, Trusted Advisor security checks, and continuous compliance monitoring. | [Security and compliance tools](01-task-4-1-security-compliance-tools.md) |
| **4.2 — Implement strategies to protect data and infrastructure** | Data classification, encryption at rest/in transit, secret storage, and findings from security services such as Security Hub, GuardDuty, Config, and Inspector. | [Data and infrastructure protection](02-task-4-2-data-infrastructure-protection.md) |

Use the [Domain 4 contexts index](contexts/README.md) for reusable scenarios, the graph-native [AWS IAM node](../../knowledge/services/iam/README.md), and the existing [imported IAM notes](../../knowledge/services/13-security-identity-compliance/01-iam/README.md) for additional service detail. The task guides provide practice and checks; learner results remain in the progress notes below and [`PROGRESS.md`](../../../PROGRESS.md).

## Services

The service list follows the [official Domain 4 objectives](https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain4.html); examples are exam-scope coverage, not an exhaustive AWS catalog.

- **Identity and governance:** [AWS Identity and Access Management (IAM)](../../knowledge/services/iam/README.md), [AWS CloudTrail](../../knowledge/services/cloudtrail/README.md), [IAM Access Analyzer](../../knowledge/services/access-analyzer/README.md), IAM policy simulator, [AWS Organizations and service control policies (SCPs)](../../knowledge/services/organizations/README.md), IAM Identity Center, and AWS Trusted Advisor.
- **Compliance and findings:** [AWS Config](../../knowledge/services/config/README.md) (including conformance packs), [AWS Security Hub](../../knowledge/services/securityhub/README.md), [Amazon GuardDuty](../../knowledge/services/guardduty/README.md), [Amazon Inspector](../../knowledge/services/inspector/README.md), and AWS Security Agent.
- **Data and infrastructure protection:** [AWS Key Management Service (AWS KMS)](../../knowledge/services/kms/README.md), AWS Certificate Manager (ACM), and AWS secret-storage services such as [AWS Secrets Manager](../../knowledge/services/secretsmanager/README.md) and Systems Manager Parameter Store.

### Cross-service impacts

IAM roles and policies constrain provisioning and operational automation (see [Domain 3](../03-deployment-provisioning-automation/README.md)); CloudTrail, Config, and security findings feed monitoring and remediation workflows (see [Domain 1](../01-monitoring-logging-analysis-remediation-performance-optimization/README.md)). Encryption and secret access affect storage, databases, backups, and recovery (see [Domain 2](../02-reliability-business-continuity/README.md)); WAF, Shield, DNS Firewall, and Network Firewall connect security choices to network paths (see [Domain 5](../05-networking-content-delivery/README.md)). The effective result depends on the specific identity, resource, organization, and network policies—not merely on enabling a security service.

## Learning targets

- Diagnose access by separating identity-based permissions, resource policies, session/organization boundaries, and explicit denies.
- Choose least-privilege roles and understand federation and temporary credentials.
- Explain KMS encryption, TLS, secrets handling, and the difference between encryption and authorization.
- Treat findings as evidence to investigate, not automatic proof of exploitability or compliance.

## Practice and evidence

- **CLI:** inspect identity, policy/configuration, and audit evidence with read-only commands first.
- **Console:** trace a finding or access-denied event to the relevant principal, policy, resource, and context.
- **IaC:** express a narrowly scoped role/policy or encryption setting in a disposable lab; avoid touching existing production resources.
- **Demonstrated when:** independently locate the effective permission boundary in a new access scenario and propose a least-privilege correction with verification.

### Progress notes

- Status: Practiced — initial diagnostic and five access-control scenarios completed; no hands-on policy investigation yet. Phase 5 remains pending; broader Domain 4 mastery is not established.
- Questions/practice evidence (2026-10-03): 4/4. Correctly applied explicit-deny precedence, the `AccessDenied` investigation sequence, Secrets Manager for runtime secrets, and CloudTrail for AWS API audit history.
- Explicit-deny evaluation (2026-10-03): Correctly concluded that an SCP explicit deny of `s3:GetObject` on `*` overrides an EC2 role identity-policy allow for `reports/*`. This supports the baseline finding; continue with permissions boundaries and resource-policy interactions.
- Permissions-boundary evaluation (2026-10-03): Correctly concluded that a boundary allowing only `s3:GetObject` blocks an identity-policy `s3:PutObject` allow. Future Domain 4 practice should use operational, multi-control scenarios rather than single-rule recall.
- Next action: Read-only review of [Lab 03](../../knowledge/labs/03-iam-policy-evaluation/README.md) policies and cleanup scripts before creation. During the lab, state expected positive, negative, and regression outcomes before running tests.

#### 2026-10-04 — S3/KMS access-control block

- **Progress:** 5/5 scenarios reviewed, 0 remaining; four guided cases followed by one independent combined case. This is block completion, not a perfect score. Lab 03 is not started; no AWS tests or changes were performed.
- **Terminology:** After explanation, correctly identified customer-managed key administration. The initial unfamiliar term reflected a tutor sequencing issue, not a learner misconception. See the canonical [KMS notes](../../knowledge/services/kms/README.md).
- **Boundary mismatch:** Correctly proposed extending K2 decryption coverage and keeping encryption denied; the tutor specified the boundary as the correction target and added actual S3 download verification.
- **Key-policy investigation:** Correctly chose the key policy as the next check when identity and boundary permissions were sufficient. This was a diagnostic hypothesis, not a confirmed root cause.
- **Transport restriction:** Correctly identified HTTP as the blocked request context and HTTPS as the fix. The tutor supplied the missing HTTP-denial negative test.
- **Cross-account case:** Correctly proposed adding `kms:Decrypt` to the caller role IAM policy and an encryption test. The tutor corrected unnecessary key-policy modification because its permission was already established, scoped the IAM allow to K3's full key ARN, and specified expected test outcomes.
- **Independent combined case:** Correctly separated the HTTP restriction and K2 boundary gap, proposed HTTPS plus a scoped boundary correction, and selected HTTPS/HTTP/encryption tests. The tutor completed expected success/denial outcomes and added the K1 regression check. Fix order was not scored as a mistake.
- **Evidence limits:** One independent combined diagnosis is evidence of applying the taught rules, not whole-domain mastery. Verification completeness and hands-on evidence remain follow-ups; learner-proposed tests are not executed results.
- **Tutor process:** Reconciled this README and [PROGRESS.md](../../../PROGRESS.md) after the learner pointed out the missing repository updates. Keep both current during active tutoring and show the finite block counter before subsequent scenarios.
