---
id: "rds"
kind: "service"
domains: [1, 2]
services: ["rds"]
sources:
  - title: "What is Amazon RDS?"
    url: "https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Welcome.html"
  - title: "Configuring and managing a Multi-AZ deployment for Amazon RDS"
    url: "https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.MultiAZ.html"
  - title: "Working with DB instance read replicas"
    url: "https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_ReadRepl.html"
  - title: "Amazon CloudWatch metrics for Amazon RDS"
    url: "https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/rds-metrics.html"
  - title: "AWS Certified CloudOps Engineer - Associate: Domain 1"
    url: "https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain1.html"
  - title: "AWS Certified CloudOps Engineer - Associate: Domain 2"
    url: "https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain2.html"
last_verified: 2026-10-04
---

# Amazon RDS

## In one paragraph

Amazon RDS is a managed relational-database service that manages common administration tasks such as backups, software patching, failure detection, and recovery. The customer still owns database design, query tuning, access configuration, and interpreting workload-specific performance evidence.

## Behavior and boundaries

- A Multi-AZ DB instance deployment uses a synchronous standby for failover, not read traffic; a Multi-AZ DB cluster has reader instances that can serve reads.
- DB instance read replicas are read-only copies updated asynchronously from their source and are intended for read scaling or recovery designs that account for replica lag.
- Multi-AZ failover support and read-replica scaling are separate mechanisms; select the one that addresses the stated availability or read-demand requirement.

## Operational signals

- Inspect `CPUUtilization`, `DatabaseConnections`, `FreeableMemory`, `FreeStorageSpace`, `ReadLatency`, and `WriteLatency` to identify resource pressure before changing capacity.
- For a read replica, use `ReplicaLag` to establish how far its applied data trails the source; it is not a measure of primary-database availability.

## Common confusion

- Multi-AZ is a read-scaling feature -> A Multi-AZ DB instance standby provides failover support and does not serve read traffic.
- A read replica provides synchronous failover -> DB instance read replicas use asynchronous replication and can be stale.

## Exam mapping

- [Domain 1](../../../domains/01-monitoring-logging-analysis-remediation-performance-optimization/README.md): Task 1.3, Skill 1.3.5 (monitor RDS metrics and improve performance efficiency).
- [Domain 2](../../../domains/02-reliability-business-continuity/README.md): Task 2.1, Skill 2.1.3 (managed-database scaling); Task 2.2, Skill 2.2.2 (Multi-AZ); Task 2.3, Skill 2.3.2 (database restore choices).
