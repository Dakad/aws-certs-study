---
title: Task 4.1 - Security and compliance tools
domain: 4
official_task: 4.1
last_verified: 2026-10-03
sources:
  - title: AWS SOA-C03 Content Domain 4
    url: https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain4.html
---

# Task 4.1 — Security and compliance tools

**Official skills:** 4.1.1 IAM passwords, MFA, roles, federation, resource policies, conditions; 4.1.2 audit access with CloudTrail, Access Analyzer, policy simulator; 4.1.3 Organizations, SCPs, Identity Center; 4.1.4 remediate Trusted Advisor security checks; 4.1.5 compliance monitoring including Region/service selection and Config conformance packs.

## Study / do

- For `AccessDenied`, record principal, action, resource, and request context. Trace identity/resource policy, boundary/session policy, organization controls, and explicit denies.
- Explain what an SCP limits and why it does not itself grant access. Trace the account/OU/root attachment path.
- Compare CloudTrail API activity with Config resource/compliance evidence; state what each can and cannot establish.
- Turn a security finding into validated impact, owner, least-privilege remediation, and post-change verification.

## Check

A role identity policy allows an S3 action, yet the request is denied. Give an ordered investigation with four possible policy/context constraints and a tool/evidence source for each. Why might adding another `Allow` have no effect?

**Look for:** explicit deny, resource policy, boundary/session policy, SCP, conditions/request context, and confirmation of the actual principal/resource. One allow layer is not the full decision.
