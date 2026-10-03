# Domain 2 — Reliability and Business Continuity

**Exam weight:** 22% of scored content  
**Status:** Learning  
**Official objective:** [AWS Domain 2 guide](https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain2.html) (scope checked 2026-10-03)

## What this domain is about

Keep workloads available through expected demand changes and component failures, and recover data/services after disruption. Questions ask you to match scaling, redundancy, backup, and disaster-recovery choices to business requirements such as availability, recovery time objective (RTO), recovery point objective (RPO), and cost.

## Official task areas and study guides

| Official task | What to study | Task guide |
|---|---|---|
| **2.1 — Implement scalability and elasticity** | Compute and managed-database scaling; use caching when it addresses the workload's scaling constraint. | [Scalability and elasticity](01-task-2-1-scalability-elasticity.md) |
| **2.2 — Implement highly available and resilient environments** | Load balancing, Route 53 health checks, fault-tolerant patterns, and Multi-AZ design. | [High availability and resilience](02-task-2-2-high-availability-resilience.md) |
| **2.3 — Implement backup and restore strategies** | Automated backups/snapshots, database restore including point-in-time recovery, storage versioning, and disaster recovery choices. | [Backup and restore](03-task-2-3-backup-restore.md) |

Use the [Domain 2 contexts index](contexts/README.md) for reusable scenarios. The task guides provide practice and a check for understanding; learner results remain in the progress notes below and [`PROGRESS.md`](../../../PROGRESS.md).

## Services

The service list follows the [official Domain 2 objectives](https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain2.html); examples are exam-scope coverage, not an exhaustive AWS catalog.

- **Scaling and caching:** compute scaling mechanisms, Amazon CloudFront, Amazon ElastiCache, Amazon RDS, and Amazon DynamoDB.
- **Availability and traffic health:** Elastic Load Balancing (ELB) and Amazon Route 53 health checks; Multi-AZ deployments are a design pattern across supported services.
- **Backup, restore, and disaster recovery:** AWS Backup and snapshots/backups for Amazon EC2, Amazon EBS, Amazon RDS, Amazon S3, and Amazon DynamoDB; Amazon FSx and Amazon S3 versioning; database point-in-time restore.

### Cross-service impacts

Scaling and health checks depend on useful metrics and logs (see [Domain 1](../01-monitoring-logging-analysis-remediation-performance-optimization/README.md)); deployment automation can create or replace the participating resources (see [Domain 3](../03-deployment-provisioning-automation/README.md)). Recovery design also depends on access controls and encryption, plus DNS, routing, and connectivity between recovery components (see [Domain 4](../04-security-compliance/README.md) and [Domain 5](../05-networking-content-delivery/README.md)). Choose among patterns using the workload's RTO, RPO, and cost requirements rather than treating a named service as a complete recovery design.

## Learning targets

- Distinguish scalability, elasticity, fault tolerance, and high availability.
- Compare backup/restore, pilot light, warm standby, and active/active against RTO, RPO, and cost.
- Know the role and limitations of health checks, load balancers, Multi-AZ, and scaling policies.
- Verify that a backup is restorable; a successful backup job alone is not proof of recovery readiness.

## Practice and evidence

- **CLI:** inspect scaling, health, snapshot, and backup metadata; do not create costly replicated systems just for practice.
- **Console:** trace a health or recovery configuration and inspect restore options.
- **IaC:** model a small, low-cost reliability component; review destroy and data-retention implications before apply.
- **Demonstrated when:** choose a design for a fresh RTO/RPO scenario and explain the availability, recovery, and cost tradeoffs.

### Progress notes

- Status: Learning — one initial AZ-failure scenario discussed; RPO/RTO follow-up still needed.
- Questions/practice evidence (2026-09-28): Identified AZ-independent application behavior, traffic geography/cost, and whether application state can be externalized as relevant design questions.
- Strengths observed: Thought beyond “add another instance” to application portability, user geography, cost, and state placement; correctly recognized that local application state can complicate failover.
- Gap to revisit: The prompt's RPO target (<5 minutes) was not yet translated into a data-protection/replication requirement. RPO is the maximum acceptable data-loss window; RTO is the maximum acceptable service-recovery time. Clarify both before selecting an HA/DR pattern.
- Correction from follow-up exercise (2026-09-28): Asked for the longest backup interval for an RPO **under** five minutes. The learner answered five minutes, and the tutor incorrectly marked it exactly correct. Under ideal assumptions, a five-minute interval bounds backup age to **at most** five minutes, not strictly under five; choose an interval shorter than five minutes (for example, four), and in practice include completion time, failed jobs, and restore usability. This is a tutor assessment error, not a learner mistake.
- Replication-lag exercise (2026-09-28): Correctly concluded that when asynchronous replication lag exceeds the five-minute target, the RPO is not met for that replica at that moment (assuming it is the recovery copy and no fresher recovery mechanism exists). Strength: connected lag to the age of recoverable data. Terminology refinement: call this the replica/recovery copy; a backup is a distinct recovery mechanism.
- Correction: For users in multiple geographies, Region and global delivery choices address proximity/latency; AZs are separate failure zones within a Region. Multi-AZ resilience usually does not mean inter-Region replication. Cross-AZ and cross-Region data movement have different network/cost implications, so check the actual data path and pricing.
- Mistakes and corrections: No incorrect design asserted in the initial scenario; the RPO requirement was unanswered. The backup-interval follow-up needs the strict `<5` versus `<=5` distinction above.
- RTO/RPO discrimination (2026-10-03): Given "RTO of one hour," the learner ruled out both the RPO reading ("at most one hour of data can be lost") and the backup-frequency reading ("backups must run every hour"), then correctly chose that service must be restored within one hour. On the discriminating case — recovery beginning at T+10 minutes with a 90-minute restoration against a one-hour RTO — the learner answered that the RTO is **missed**, because users waited 100 minutes. This is independent recall of the RTO definition and correctly rejects the "recovery must begin within one hour" reading, which was the remaining plausible distractor.
- Strength: distinguishes RTO from RPO without prompting, and treats RTO as a bound on elapsed restoration time rather than process start time.
- Remaining follow-up: RTO is now established, but the paired `<5` versus `<=5` backup-interval distinction above is still unretrieved, and no recovery design has yet been chosen from explicit RTO *and* RPO requirements.
- Phase 0 diagnostic baseline (2026-10-03): 5/5. Correctly evaluated a lagging asynchronous replica against a strict RPO, selected Multi-AZ for failover availability rather than read scaling, defined RTO, chose functional restore verification, and identified the resilience value of multiple AZs. This is strong recall evidence, not yet a new end-to-end recovery-design scenario.
- Tutor gap (2026-10-03): A four-part recovery-design question (pick a pattern, attribute RTO and RPO to different mechanisms, then verify both) was posed after teaching only the RTO/RPO **definitions**, never the mapping from those targets to mechanisms and cost. The learner responded "no clue what is RTO and how to design that recovery design." The RTO definition itself is established (see the RTO/RPO discrimination entry above); **pattern selection is untested, not failed.** Teach the target-to-mechanism map and the pattern cost/blast-radius ladder before asking for a selection.
- Concepts now taught (2026-10-03), in this order: (1) RPO is a **data-freshness** question, so it is answered by a replication or backup *interval*; (2) RTO is a **process/infrastructure** question, so it is answered by whether something is already running to fail over to versus something that must be restored; (3) Multi-AZ is not disaster recovery — it covers AZ loss inside one Region and leaves Region loss unhandled; (4) surviving Region loss requires a cross-Region mechanism; (5) cost tracks RTO/RPO tightness because tighter targets mean more capacity standing by.
- Next action: Re-check the RPO-is-data / RTO-is-process split with a scaffolded prompt, then rebuild to a single-requirement design before returning to the full two-requirement selection.
