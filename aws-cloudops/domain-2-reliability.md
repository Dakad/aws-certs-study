# Domain 2 — Reliability and Business Continuity

**Exam weight:** 22% of scored content  
**Status:** Learning  
**Official objective:** [AWS Domain 2 guide](https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain2.html)

## What this domain is about

Keep workloads available through expected demand changes and component failures, and recover data/services after disruption. Questions ask you to match scaling, redundancy, backup, and disaster-recovery choices to business requirements such as availability, recovery time objective (RTO), recovery point objective (RPO), and cost.

## Official task areas

- **2.1 — Scalability and elasticity:** Configure compute and managed-database scaling; use caching where it improves dynamic scalability.
- **2.2 — Highly available and resilient environments:** Configure or troubleshoot load balancing and Route 53 health checks; choose fault-tolerant patterns such as Multi-AZ deployments.
- **2.3 — Backup and restore:** Automate backups/snapshots, restore databases (including point-in-time recovery), use storage versioning, and select an appropriate disaster-recovery strategy.

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
- Next action: Distinguish data-loss tolerance (RPO) from time-to-restore-service (RTO) in a scenario where only one of the two targets is met.
