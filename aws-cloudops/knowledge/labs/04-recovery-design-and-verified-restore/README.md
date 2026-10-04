# Lab 04 — Recovery Design and Verified Restore

**Exam domains:** [2. Reliability and business continuity](../../../domains/02-reliability-business-continuity/README.md) (20%) and [4. Security and compliance](../../../domains/04-security-compliance/README.md) (18%)
**Task guides:** [2.2 High availability & resilience](../../../domains/02-reliability-business-continuity/02-task-2-2-high-availability-resilience.md), [2.3 Backup & restore](../../../domains/02-reliability-business-continuity/03-task-2-3-backup-restore.md), [4.2 Data & infrastructure protection](../../../domains/04-security-compliance/02-task-4-2-data-infrastructure-protection.md)
**Status:** Not yet run

## Why this lab exists

Recovery is not "the backup job finished." A restore is only proven when the database answers a query *and* the data matches the pre-incident state. This lab makes that distinction concrete by:

1. Creating a known dataset with a verifiable checksum.
2. Taking a manual snapshot and recording its exact age.
3. Corrupting the data silently (a bad write with no alarm).
4. Timing a snapshot restore against an RTO claim — separately measuring control-plane "available" vs. usable query response.
5. Performing point-in-time recovery to a timestamp before the bad write, proving the automated backup window's RPO.
6. Creating a cross-Region read replica and measuring its replication lag under load, exposing the RPO of async replication.

No step assumes a green backup job means anything. Every step proves or disproves a claim with data.

## Objective

By the end you can:

1. Distinguish RPO (data freshness at recovery) from RTO (time to usable) and measure both.
2. Explain what a manual snapshot restores to (its `SnapshotCreateTime`) and what it cannot restore (writes after that time).
3. Explain what point-in-time recovery restores to (the requested timestamp) and what limits it (earliest/latest restorable time, automated backup completion).
4. Time a restore end-to-end and report two numbers: T0→available and T0→answers-query.
5. Create a cross-Region read replica, measure its replication lag under burst write load, and state the RPO that lag represents.
6. Verify a restored copy with a canary query (counts, checksum, newest good row, poison row absence) rather than trusting `available`.
7. Clean up every resource in dependency order and verify by tag query that nothing remains.

## Safety, scope, and cost

| Item | Note |
|---|---|
| Scope | The authorized playground or a personal account. Never a shared or production account. |
| Identity | Confirm with `aws sts get-caller-identity` before the first mutation and re-confirm if the session fails mid-lab. |
| Primary instance | `db.t3.micro`, single-AZ, PostgreSQL 17, `gp3` 20 GiB, publicly accessible, **no** Multi-AZ. On-demand in us-east-1 is roughly $0.023/hour instance + $0.003/hour storage = ~$0.62/day. |
| Cross-Region replica | Same class in `LAB_DR_REGION` (default `us-west-2`). Roughly doubles the instance cost while running. |
| PITR instance | Same class, billed from creation until deleted. |
| Snapshot restore instance | Same class, billed from creation until deleted. |
| Manual snapshot | Storage cost only after creation (~$0.095/GB-month in us-east-1). 20 GiB ≈ $1.90/month. |
| KMS key | Not created by default (uses AWS managed key). If you create one, `schedule-key-deletion` has a 7-day minimum and the key bills until deletion completes. |
| Automated backups | Enabled with 1-day retention (step 01). No extra charge for the first backup's storage equal to allocated storage; additional backups bill at snapshot rates. |
| Data transfer | Cross-Region replication traffic bills at inter-region rates (~$0.02/GB us-east-1 → us-west-2). The 10k-row burst in step 08 is negligible. |
| Expected total | Under $2.00/day while all instances run. Delete each instance when its step is done; do not leave them running overnight. |
| Blast radius | Up to four DB instances (primary, snapshot restore, PITR, cross-Region replica), two security groups, one manual snapshot, all tagged `soa-c03-lab04=true`. Nothing shared. |

**Every resource carries the tag `soa-c03-lab04=true` and a run-specific suffix so teardown can be verified by tag rather than by remembering an ID.**

## Prerequisites

- AWS CLI v2, `psql` (or Docker), `python3`, `jq` (optional but recommended for JSON parsing).
- An AWS profile with permission to create RDS, EC2 (security groups, VPC describe), KMS, CloudWatch in two regions (primary and `LAB_DR_REGION`).
- The primary region must have a default VPC (step 01 uses it). The DR region must also have a default VPC (step 07 creates a security group there).
- `AWS_PROFILE` and `AWS_REGION` (default `us-east-1`) exported. Optionally `LAB_DR_REGION` (default `us-west-2`).

## Sequence

The learner's sequence is CLI → Console inspection → verify → clean up. Do not skip ahead.

### Step 0 — Verify identity and region

```bash
aws sts get-caller-identity
aws configure get region
```

Read the output aloud: which account, which identity ARN, which region. Everything downstream uses that region. Do not write the account ID into any file in this repository.

### Step 1 — Create the primary workload

```bash
AWS_PROFILE=your-profile ./cli/01-create.sh
```

Before running it, read it. It creates a single-AZ RDS PostgreSQL instance, a security group allowing **only this machine's public IP** on 5432/tcp, and a run state file (`.env.lab04-run`, gitignored, mode 600) containing all identifiers and the master password.

**Teaching points in this step:**

- Single-AZ on purpose: Multi-AZ is a separate mechanism for a separate disaster (AZ loss), and a standby roughly doubles the instance cost. This lab is about *restore*, not *failover*.
- The backup window is computed to be minutes away, so the first automated backup lands during the session and PITR is testable now. Step 07 confirms it actually happened rather than assuming.
- No customer-managed KMS key is created. RDS encrypts at rest with the AWS managed key by default. A customer key would add a 7-day deletion window and ongoing cost — not needed here.

### Step 2 — Seed known data

```bash
./cli/02-seed.sh
```

Creates table `public.lab04_events` with 20 rows (id 1..20, kind='good', payload=id). Records the checksum (sum of payload = 210), the newest good row timestamp, and the first-5-rows checksum. This is the "known good" state every restore must match.

### Step 3 — Manual snapshot and its age

```bash
./cli/03-snapshot.sh
```

Takes a manual snapshot, waits for `available`, and prints:
- `SnapshotCreateTime` (what a restore actually restores to)
- Snapshot age now (the RPO this snapshot offers *at this instant*)

Also checks whether the first automated backup has finished by reading RDS events — step 07 needs one and cannot assume it.

### Step 4 — The incident (silent corruption)

```bash
./cli/04-poison.sh
```

Deletes rows 1–5, inserts one poison row (id=9001, kind='poison', payload=-1), and records `LAB_BAD_WRITE_TIME` (the exact instant of the commit). **No alarm, no notification, no event.** The canary query now shows 15 good rows, 1 poison row, checksum 155, first-5-rows = 0.

Key lesson: the snapshot from step 03 predates this write. Restoring from it *cannot* undo this write. Anything written between the snapshot and now is gone either way — that interval is your RPO exposure.

Step 06 instead targets `LAB_BAD_WRITE_TIME - 60s` using the automated backup's PITR window.

### Step 5 — Snapshot restore timed against RTO

```bash
./cli/05-restore-and-time.sh
```

Restores the manual snapshot to a new instance `LAB_RESTORED`. Times two separate intervals:
- **T0 → available** (control plane): when AWS reports `DBInstanceStatus=available`
- **T0 → answers query** (usable): when the instance accepts `SELECT 1`

Only the second is a candidate for an RTO. The first is often what vendors quote. The script refuses to run if `LAB_RESTORED` already exists, so repeating the measurement costs one instance's runtime, not a second one.

Verifies the restored copy with the canary query: 20 good rows, 0 poison, checksum 210, first-5-rows = 5, newest good row matches the seed timestamp.

### Step 6 — Point-in-Time Recovery to before the bad write

```bash
./cli/06-pitr.sh
```

Restores the primary to a new instance `LAB_PITR` using `restore-db-instance-to-point-in-time` with `--restore-time` set to `LAB_BAD_WRITE_TIME - 60s` (configurable via `LAB_PITR_LEAD_SECONDS`).

This demonstrates the second recovery path: automated backups provide a continuous recovery window. The RPO here is the lead time (default 60s) — the data gap between the PITR target and the bad write.

Same timing (T0→available, T0→answers-query) and same canary verification as step 05.

### Step 7 — Cross-Region read replica

```bash
./cli/07-cross-region-replica.sh
```

Creates a read replica in `LAB_DR_REGION` (default `us-west-2`). Requires:
- Automated backups enabled on primary (step 01 does this with `--backup-retention-period 1`).
- Permissions to create RDS in the DR region.
- A default VPC in the DR region (script creates a security group there).

Measures provisioning time (request → usable) and prints initial `ReplicaLag` from CloudWatch.

### Step 8 — Replication lag under load

```bash
./cli/08-replication-lag.sh
```

Inserts 10,000 rows on the primary in batches, then polls CloudWatch `ReplicaLag` in the DR region until it drops below 1 second or a 5-minute timeout.

Prints:
- Burst start time
- Lag caught-up time
- Replication lag duration (the RPO exposure of async replication at this moment)
- Row count verification on the replica

**This is the number no alarm watches.** If the primary region fails during that window, those writes are lost.

### Step 99 — Tear down and verify

```bash
./cli/99-teardown.sh
```

Deletes in dependency order:
1. Step 08: no persistent resources
2. Step 07: cross-Region replica (in DR region), DR security group
3. Step 06: PITR instance
4. Step 05: snapshot restore instance
5. Step 04: no persistent resources
6. Step 03: manual snapshot
7. Step 02: no persistent resources
8. Step 01: primary DB instance (wait for deletion), security group, schedule KMS key deletion (7-day window), VPC (not deleted — it's the default VPC)

**Final verification:** queries RDS instances, snapshots, security groups, and KMS keys in both regions for the tag `soa-c03-lab04=true`. Prints `clean` only if zero remain; exits non-zero otherwise.

Verify the same query yourself in the Console before calling the lab finished.

## Evidence to record

Copy into [EVIDENCE.md](EVIDENCE.md) after the run. Redact account IDs to the last four characters; never record ARNs, keys, or session tokens.

- Step 5: T0→available, T0→answers-query, snapshot age at T0 (RPO), canary verdict.
- Step 6: T0→available, T0→answers-query, PITR target time, data gap (RPO), canary verdict.
- Step 7: Provisioning time (request→usable), initial ReplicaLag.
- Step 8: Replication lag duration under burst load, rows replicated.
- Teardown output showing the tag query returned `clean`.
- Anything that surprised you — those are the study items.

## Cleanup risk if interrupted

If the run stops midway, the tag query is the recovery path:

```bash
aws rds describe-db-instances --region us-east-1 \
  --filters "Name=tag:soa-c03-lab04,Values=true" \
  --query 'DBInstances[].{Id:DBInstanceIdentifier,State:DBInstanceStatus}' --output table

aws rds describe-db-instances --region us-west-2 \
  --filters "Name=tag:soa-c03-lab04,Values=true" \
  --query 'DBInstances[].{Id:DBInstanceIdentifier,State:DBInstanceStatus}' --output table

aws rds describe-db-snapshots --region us-east-1 \
  --filters "Name=tag:soa-c03-lab04,Values=true" \
  --query 'DBSnapshots[].{Id:DBSnapshotIdentifier,Status:Status}' --output table

aws ec2 describe-security-groups --region us-east-1 \
  --filters "Name=tag:soa-c03-lab04,Values=true" \
  --query 'SecurityGroups[].{Id:GroupId,Name:GroupName}' --output table

aws ec2 describe-security-groups --region us-west-2 \
  --filters "Name=tag:soa-c03-lab04,Values=true" \
  --query 'SecurityGroups[].{Id:GroupId,Name:GroupName}' --output table
```

Deleting an instance removes its automated backups unless `--delete-automated-backups` is omitted (the teardown script includes it). Delete the manual snapshot by hand if the script did not reach it. The KMS key (if created) enters a 7-day deletion window and cannot be accelerated.

## Cross-Region permission note

**Steps 07 and 08 require cross-Region permissions in `LAB_DR_REGION`.** The profile used must be able to:
- `rds:CreateDBInstanceReadReplica`, `rds:DescribeDBInstances`, `rds:DeleteDBInstance`, `rds:WaitDBInstanceDeleted` in the DR region
- `ec2:CreateSecurityGroup`, `ec2:AuthorizeSecurityGroupIngress`, `ec2:DeleteSecurityGroup`, `ec2:DescribeVpcs`, `ec2:DescribeSecurityGroups` in the DR region
- `cloudwatch:GetMetricStatistics` in the DR region

If your playground profile is region-scoped, you may need to run steps 07–08 with a different profile or in a region where the profile has permissions. Set `LAB_DR_REGION` accordingly in step 01 or export it before step 07.