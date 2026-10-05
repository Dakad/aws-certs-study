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

- **Status:** Learning. RTO/RPO discrimination is established; recovery-pattern selection remains untested.
- **Durable evidence:** Applied strict RPO to replication lag and independently applied RTO to restoration duration.
- **Next study:** Choose a recovery design from explicit RTO and RPO requirements, including recovery verification.
