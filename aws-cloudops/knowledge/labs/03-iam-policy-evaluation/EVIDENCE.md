# Lab 03 evidence — not yet run

Status: **not yet run**. Replace this line as evidence is recorded.

Redact account IDs to the last four characters. Never record ARNs in full or any
credential material.

## Session

- Date:
- AWS profile used:
- Region:

## Step 2 — Prediction before testing

With an inline `Allow` on `s3:ListAllMyBuckets`, an attached policy with an
explicit `Deny` on `s3:*`, and a boundary that denies everything, my prediction
for `s3:ListAllMyBuckets` is:

## Step 2 — Simulator vs reality

| | Result |
|---|---|
| Simulator `EvalDecision` |  |
| Matched statement source policy |  |
| Real call outcome |  |
| Error code / message shape |  |

Did the simulator match reality? If not, what did the simulator not know about?

## Step 3 — Removing one layer at a time

| Step | Layer removed | Predicted outcome | Actual outcome | Prediction correct? |
|---|---|---|---|---|
| 1 | explicit Deny detached |  |  |  |
| 2 | boundary removed |  |  |  |
| 3 | boundary reattached but scoped to allow the action |  |  |  |

The order that surprised me, and what it taught me about evaluation order:

## Step 4 — KMS

Two-layer explanation of "the application cannot read the encrypted S3 object":

Evidence that distinguishes an S3 authorization failure from a KMS decryption failure:

## Teardown

Paste the final verification block from `cli/99-teardown.sh`. It must print `clean`.

## Surprises
