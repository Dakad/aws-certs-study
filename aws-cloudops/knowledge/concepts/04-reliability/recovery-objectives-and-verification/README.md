---
id: "recovery-objectives-and-verification"
kind: "concept"
domains: [2]
related:
  - relation: "commonly-used-with"
    target: "rds"
  - relation: "commonly-used-with"
    target: "s3"
  - relation: "troubleshoots-with"
    target: "cloudwatch"
sources:
  - title: "AWS Certified CloudOps Engineer - Associate: Domain 2"
    url: "https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain2.html"
  - title: "Configuring and managing a Multi-AZ deployment for Amazon RDS"
    url: "https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.MultiAZ.html"
  - title: "Working with DB instance read replicas"
    url: "https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_ReadRepl.html"
  - title: "Amazon CloudWatch metrics for Amazon RDS"
    url: "https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/rds-metrics.html"
  - title: "Retaining multiple versions of objects with S3 Versioning"
    url: "https://docs.aws.amazon.com/AmazonS3/latest/userguide/Versioning.html"
last_verified: 2026-10-04
---

# Recovery objectives and verification

Recovery design starts with two independent limits:

- **RPO** is the maximum acceptable age of the recovered data. It constrains backup cadence or the observed lag of the recovery copy.
- **RTO** is the maximum elapsed time until users can use the recovered service. It constrains the recovery path: fail over to running capacity or restore, configure, validate, and cut over.

Include detection, restoration, validation, and cutover in the RTO measurement. Domain 2 explicitly includes database restore choices and DR strategies in its backup-and-restore scope. [AWS Certified CloudOps Engineer - Associate: Domain 2](https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain2.html)

## From targets to mechanisms

| Requirement | Mechanism to assess | Evidence that proves it |
|---|---|---|
| RPO | Backup interval and the age of the newest usable recovery point; replica lag for an asynchronous recovery copy | Restore-point timestamp or measured lag at the incident/test time |
| RTO | Restore runbook, pre-provisioned recovery capacity, dependency order, validation, and cutover | Timed run from disruption to a service that passes functional checks |
| Availability during an AZ failure | Failover/HA mechanism | Failover completes and the application remains usable |

For a strict RPO of `<5 minutes`, a five-minute backup interval only bounds age to `<=5 minutes` under ideal timing. Use a shorter interval and margin for completion time, missed jobs, and the time needed to establish that the point is usable. Similarly, a replica with asynchronous lag above five minutes does not meet that target at that moment if it is the recovery copy.

> [!IMPORTANT]
> **RTO is restoration duration, not the time when recovery work begins.** For SOA-C03, measure until the workload has passed functional validation for users; a fast start to a 90-minute restore still misses a one-hour RTO. Treating the target as a start-time deadline omits the user-visible outage.

## Do not collapse the mechanisms

| Mechanism | Solves | Does not establish |
|---|---|---|
| Backup | An independently retained recovery point, chosen by age and retention | A running alternate or a tested restore duration |
| Replica | A copy that can be promoted or used in a recovery design; lag exposes data-freshness risk | A point-in-time recovery point or an RPO when lag exceeds the target |
| Failover / HA | Continued or quickly resumed service for the covered failure mode | Historical recovery from deletion, corruption, or an untested application dependency |
| Restore verification | That a selected point can become a usable workload inside the RTO | That future backups, replica lag, or failover will meet their targets without continued testing |

An RDS DB instance Multi-AZ deployment has a synchronous standby for failover, not a read endpoint; that availability choice is separate from read scaling. [Configuring and managing a Multi-AZ deployment for Amazon RDS](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.MultiAZ.html) RDS read replicas are asynchronous, so use `ReplicaLag` as evidence about a replica's data currency rather than as proof that the primary is available. [Working with DB instance read replicas](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_ReadRepl.html) [Amazon CloudWatch metrics for Amazon RDS](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/rds-metrics.html)

Retention-based recovery is also service-specific. For example, S3 Versioning retains prior object versions and uses a delete marker for a delete without a version ID; it is a recovery option for objects, not a substitute for application restore verification. [Retaining multiple versions of objects with S3 Versioning](https://docs.aws.amazon.com/AmazonS3/latest/userguide/Versioning.html)

## Verify the claim

Run a restore or recovery exercise against a representative point and record:

1. The recovered data timestamp or replica lag, compared with the RPO.
2. Elapsed time from disruption to a reachable recovery environment, then to a passing application check, compared with the RTO.
3. Functional evidence: authentication, a representative read and write, critical dependency access, data integrity, and the intended traffic path after cutover.

A successful backup job, a healthy standby, or a restored database in `available` state is infrastructure evidence. It does not prove that credentials, configuration, dependencies, data, and user requests work together.

## Common confusion

- **Common mistake** — A Multi-AZ deployment or a low-lag replica is itself a complete backup-and-recovery solution.
- **Actual AWS behavior** — An RDS Multi-AZ DB-instance standby provides failover support and does not serve read traffic; RDS read replicas update asynchronously. Neither fact supplies a historical restore point or proves an application can be restored and used. [Configuring and managing a Multi-AZ deployment for Amazon RDS](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.MultiAZ.html) [Working with DB instance read replicas](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_ReadRepl.html)
- **Why it matters** — Domain 2 scenarios state an RPO, RTO, and failure scope. Match each constraint to the mechanism and verify the complete recovery path instead of selecting a named service feature as a generic answer.

## Exam mapping

- [Domain 2](../../../../domains/02-reliability-business-continuity/README.md): Task 2.2 (fault-tolerant environments) and Task 2.3 (backup, restore, RTO/RPO, and DR strategies).
