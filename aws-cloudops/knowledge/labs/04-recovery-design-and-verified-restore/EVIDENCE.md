# Lab 04 evidence — not yet run

Status: **not yet run**. Replace this line as evidence is recorded.

Redact account IDs to the last four characters. Never record ARNs, access keys,
session tokens, or instance IDs that you would not want published.

## Session

- Date:
- AWS profile used:
- Primary region:
- DR region:
- Account ID (last 4 only): `....`

## Step 1 — Primary creation

- Instance class used:
- Backup window set:
- Maintenance window set:
- `LatestRestorableTime` after creation:
- Any surprises:

## Step 2 — Seed

- Rows seeded:
- Checksum (sum payload):
- Newest good row timestamp:
- Canary query PASS/FAIL:

## Step 3 — Manual snapshot

- Snapshot identifier:
- `SnapshotCreateTime` (UTC):
- Snapshot age at step 5 T0 (to be filled after step 5):
- First automated backup finished? (Y/N, from events):

## Step 4 — Poison write

- `LAB_BAD_WRITE_TIME` (UTC):
- Rows deleted: 1–5
- Poison row id: 9001
- Canary query after poison — good rows / poison rows / checksum / first-5-rows:

## Step 5 — Snapshot restore timed

- `LAB_RESTORE_REQUEST_EPOCH` (T0):
- T0 → available (control plane): **____s**
- T0 → answers query (usable): **____s**
- Snapshot age at T0 (RPO): **____s**
- Restored endpoint:
- Canary verdict (PASS/FAIL):
- Observations:

## Step 6 — Point-in-Time Recovery

- PITR target time (UTC): `LAB_BAD_WRITE_TIME` minus **____s** lead
- `LAB_PITR_REQUEST_EPOCH` (T0):
- T0 → available (control plane): **____s**
- T0 → answers query (usable): **____s**
- Data gap at target (RPO): **____s**
- PITR endpoint:
- Canary verdict (PASS/FAIL):
- Observations:

## Step 7 — Cross-Region replica

- DR region:
- Provisioning time (request → usable): **____s**
- Initial `ReplicaLag` (CloudWatch, 5-min avg):
- Replica endpoint:
- Canary verdict on replica (PASS/FAIL):
- Observations:

## Step 8 — Replication lag under load

- Burst rows: **____**
- Burst start time (UTC):
- Lag caught-up time (UTC):
- Replication lag duration (RPO exposure): **____s**
- Rows replicated on replica / burst rows:
- Final `ReplicaLag`:
- Observations:

## RTO / RPO Summary

| Recovery path | RPO (data freshness) | RTO (T0→usable) | Verified? |
|---|---|---|---|
| Manual snapshot (step 5) | | | |
| PITR automated backup (step 6) | | | |
| Cross-Region replica (step 8) | | | |

Which path meets your RTO claim? Which meets your RPO claim? Where is the gap?

## Teardown

Paste the final verification block from `cli/99-teardown.sh`. It must print `clean`.

## Surprises

Anything unexpected is a study item. Write it here and raise it in the next session.