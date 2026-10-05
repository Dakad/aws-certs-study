# Domain 4 — Security and Compliance

**Exam weight:** 16% of scored content  
**Status:** Practiced — Phase 5 exit gate met on 2026-10-04; IAM-only lab cleaned up, independent verification plan demonstrated, broader domain coverage remains open
**Official objective:** [AWS Domain 4 guide](https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain4.html) (scope checked 2026-10-03)

## What this domain is about

Apply and troubleshoot access controls, meet policy/compliance requirements, and protect data and infrastructure. Exam scenarios often require finding the correct control point—identity policy, resource policy, organization guardrail, network boundary, encryption configuration, or secrets service—and interpreting audit/security findings.

## Official task areas and study guides

| Official task | What to study | Task guide |
|---|---|---|
| **4.1 — Implement and manage security and compliance tools and policies** | IAM features, access auditing, multi-account controls, Trusted Advisor security checks, and continuous compliance monitoring. | [Security and compliance tools](01-task-4-1-security-compliance-tools.md) |
| **4.2 — Implement strategies to protect data and infrastructure** | Data classification, encryption at rest/in transit, secret storage, and findings from security services such as Security Hub, GuardDuty, Config, and Inspector. | [Data and infrastructure protection](02-task-4-2-data-infrastructure-protection.md) |

Use the [Domain 4 contexts index](contexts/README.md) for reusable scenarios, the graph-native [AWS IAM node](../../knowledge/services/iam/README.md), and the existing [imported IAM notes](../../knowledge/services/13-security-identity-compliance/01-iam/README.md) for additional service detail. The task guides provide practice and checks; learner results remain in the progress notes below and [`PROGRESS.md`](../../../PROGRESS.md).

The [IAM service note](../../knowledge/services/iam/README.md#permissions-boundaries-and-effective-permissions) covers boundary/SCP scope and implicit versus explicit deny, with [simulator/live evidence](../../knowledge/services/iam/README.md#simulator-evidence-and-verification). Today's other service-specific distinctions are in [IAM role credentials](../../knowledge/services/iam/README.md#roles-sts-and-the-credentials-actually-used), [S3 endpoint/HTTPS controls](../../knowledge/services/s3/README.md#authorization-and-request-context), and [KMS service-mediated decrypt](../../knowledge/services/kms/README.md#s3-mediated-decrypt-versus-a-direct-kms-call).

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

- **Status:** Practiced. Phase 5 exit gate met on 2026-10-04; this is not whole-domain mastery.
- **Meaningful evidence:** Correctly applied explicit-deny and permissions-boundary effects. In a fresh endpoint-migration paper scenario, chose the scoped bucket-policy correction without broadening KMS permissions and supplied positive, negative, and regression tests with expected outcomes.
- **Lab 03:** IAM-only setup, policy evaluation, learner Console inspection, and authorized cleanup completed. The exact role, profile, and custom policies were deleted and verified absent. IaC recreation and KMS work were not performed; no compute, buckets, or KMS keys were created.
- **Next study:** Reinforce Domain 4 during October 22–25; retain the distinction between paper-scenario verification and executed AWS tests.
