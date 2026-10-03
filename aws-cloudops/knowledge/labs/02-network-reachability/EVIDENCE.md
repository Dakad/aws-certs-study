# Lab 02 evidence — not yet run

Status: **not yet run**. Replace this line as evidence is recorded.

Redact account IDs to the last four characters. Never record ARNs or the account number.

## Session

- Date:
- AWS profile used:
- Region:
- VPC CIDR used: `10.60.0.0/16`

## Step 2 — Where did the 503 come from?

Target group health at the time of the test (Reason / Description fields):

`server:` header and request ID from `curl -i`:

ALB access-log line for one failing request, with these fields called out:

| Field | Value |
|---|---|
| `elb_status` |  |
| `target_status` |  |
| `target_group_arn` |  |
| `request_processing_time` |  |

## Step 2 — Which metric moved?

| Metric | Value | Reading |
|---|---|---|
| `HTTPCode_ELB_5XX_Count` |  |  |
| `HTTPCode_Target_5XX_Count` |  |  |

Why the other metric stayed where it did:

## Step 2 — Flow Logs

Two fields present in the log format that I could read:

1.
2.

One thing Flow Logs could **not** tell me about this failure:

## Step 3 — NACL return-path break

Prediction written **before** running the check (which evidence source would move, and which would look normal):

Outcome:

## Teardown

Paste the final verification block from `cli/99-teardown.sh`. It must print `clean`.

## Surprises
