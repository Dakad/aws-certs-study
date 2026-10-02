# Domain 4 — Security and Compliance

**Exam weight:** 16% of scored content  
**Status:** Not started  
**Official objective:** [AWS Domain 4 guide](https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain4.html)

## What this domain is about

Apply and troubleshoot access controls, meet policy/compliance requirements, and protect data and infrastructure. Exam scenarios often require finding the correct control point—identity policy, resource policy, organization guardrail, network boundary, encryption configuration, or secrets service—and interpreting audit/security findings.

## Official task areas

- **4.1 — Security and compliance tools/policies:** IAM roles, federation, MFA, resource policies and conditions; access investigation with CloudTrail, IAM Access Analyzer, and policy tools; multi-account controls; Trusted Advisor; AWS Config and continuous compliance.
- **4.2 — Protect data and infrastructure:** Data classification; encryption at rest and in transit; secrets storage; interpret/remediate findings from services such as Security Hub, GuardDuty, Config, and Inspector.

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

- Status: Not started
- Questions/practice evidence: None yet
- Mistakes and corrections: None assessed yet
- Next action: Start with the policy evaluation layers and one AccessDenied investigation.
