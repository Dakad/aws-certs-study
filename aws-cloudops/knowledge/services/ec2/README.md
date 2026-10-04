---
id: "ec2"
kind: "service"
domains: [1, 2, 3]
services: ["ec2"]
sources:
  - title: "Manage your Amazon EC2 resources"
    url: "https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EC2_Resources.html"
  - title: "Status checks for Amazon EC2 instances"
    url: "https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/monitoring-system-instance-status-check.html"
  - title: "Monitor your instances using CloudWatch"
    url: "https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-cloudwatch.html"
  - title: "AWS Certified CloudOps Engineer - Associate: Domain 1"
    url: "https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain1.html"
  - title: "AWS Certified CloudOps Engineer - Associate: Domain 2"
    url: "https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain2.html"
  - title: "AWS Certified CloudOps Engineer - Associate: Domain 3"
    url: "https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain3.html"
last_verified: 2026-10-04
---

# Amazon EC2

## In one paragraph

Amazon EC2 provides virtual compute capacity as instances. Its resource model includes AMIs, instances, networking, and storage-related resources; EC2 resources are scoped to a Region or Availability Zone as applicable, so operational work must use the resource's actual scope.

## Behavior and boundaries

- EC2-managed system, instance, and attached-EBS status checks run automatically; application status checks are opt-in HTTP or HTTPS checks.
- A system-check failure points to the AWS infrastructure hosting an instance, while an instance-check failure concerns the instance's software or network configuration. Neither establishes that the workload is serving its users correctly.
- CloudWatch basic monitoring publishes EC2 metrics at a different cadence from detailed monitoring; select the monitoring configuration before interpreting an alarm window.

## Operational signals

- Use `CPUUtilization` for compute demand and `StatusCheckFailed_System`, `StatusCheckFailed_Instance`, and `StatusCheckFailed_AttachedEBS` to separate host, guest, and attached-volume impairment.
- Use application status checks or application-level telemetry when the question is whether the service endpoint is healthy.

## Common confusion

- EC2 status checks prove the application is healthy -> They establish only the scope of the corresponding EC2 check; application checks are separate and opt-in.
- An AMI or instance can be used without considering location -> AMIs are Regional and instances are Availability Zone-specific.

## Exam mapping

- [Domain 1](../../../domains/01-monitoring-logging-analysis-remediation-performance-optimization/README.md): Task 1.3, Skill 1.3.6 (optimize and monitor EC2 and associated storage/networking).
- [Domain 2](../../../domains/02-reliability-business-continuity/README.md): Task 2.3, Skill 2.3.1 (snapshots and backups for EC2 resources).
- [Domain 3](../../../domains/03-deployment-provisioning-automation/README.md): Task 3.1, Skill 3.1.1 (create and manage AMIs).
