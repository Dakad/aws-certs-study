---
title: Task 2.3 - Backup and restore
domain: 2
official_task: 2.3
last_verified: 2026-10-03
sources:
  - title: AWS SOA-C03 Content Domain 2
    url: https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain2.html
---

# Task 2.3 — Backup and restore

**Official skills:** 2.3.1 automate backups/snapshots for EC2, RDS, EBS, S3, DynamoDB; 2.3.2 restore databases including point-in-time recovery to RTO/RPO/cost; 2.3.3 use storage versioning; 2.3.4 follow backup/restore, pilot-light, warm-standby, or active/active DR practices.

## Study / do

- Convert requirements to RTO/RPO, including detection and validation time. Identify the newest confirmed usable recovery point.
- Map each resource to backup frequency, retention, encryption/access, restore target, and application-level validation.
- Compare DR strategies by recovery time, data freshness, cost, and test burden; replication is not automatically a point-in-time backup.
- Write restore steps: select point, isolate, restore dependencies in order, check integrity, validate application, cut over, and clean up test resources.

## Check

Requirement: RTO 45 minutes, RPO 5 minutes. The newest confirmed usable backup may be 20 minutes old, and restore has not been tested recently. Is compliance proven? What would you validate next?

**Look for:** no—the RPO is not demonstrated; configured schedule is not proof of a usable recovery point. Run and time a restore, then verify data and application behavior.
