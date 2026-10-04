---
id: "inspector"
kind: "service"
domains: [4]
services: ["inspector"]
sources:
  - title: "What is Amazon Inspector?"
    url: "https://docs.aws.amazon.com/inspector/latest/user/what-is-inspector.html"
  - title: "Automated scan types in Amazon Inspector"
    url: "https://docs.aws.amazon.com/inspector/latest/user/scanning-resources.html"
  - title: "SOA-C03 Domain 4"
    url: "https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain4.html"
last_verified: 2026-10-04
---

# Amazon Inspector

## In one paragraph

Amazon Inspector is a vulnerability-management service that discovers eligible EC2 instances, ECR container images, and Lambda functions, then continually scans for software vulnerabilities and unintended network exposure. It creates findings with affected-resource detail and remediation information.

## Behavior and boundaries

- Inspector scan types cover distinct resources. EC2 scanning can use the SSM Agent or EBS snapshots; ECR and Lambda scans follow their respective resource lifecycles.
- Inspector rescans eligible resources when changes can introduce risk, including package or function updates and newly published CVEs. A closed finding indicates Inspector detected remediation of that finding's condition.

## Operational signals

- Review Inspector findings with their resource, vulnerability or exposure, and remediation details to determine the affected workload and the documented remediation.

## Common confusion

- **Common mistake** — Amazon Inspector is only an EC2 vulnerability scanner.
- **Actual AWS behavior** — Inspector scans EC2 instances, ECR images, and Lambda functions, with separate scan types and resource-specific behavior.
- **Why it matters** — Domain 4 finding scenarios require selecting the service scope that matches the affected workload.

## Exam mapping

- [Domain 4, Task 4.2](../../../domains/04-security-compliance/README.md) covers configuring reports and remediating findings from Amazon Inspector and other AWS security services.
