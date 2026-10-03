# Lab 01 evidence — not yet run

Status: **not yet run**. Replace this line as evidence is recorded.

Redact account IDs to the last four characters. Never record ARNs, access keys,
session tokens, or instance IDs that you would not want published.

## Session

- Date:
- AWS profile used:
- Region:
- Account ID (last 4 only): `....`

## Step 3 — OpenTofu path chosen

- [ ] Recreate (destroy CLI resources, apply from empty state)
- [ ] Import (`tofu import` each resource, then expect a no-op plan)

Reasoning, written **before** running the chosen path:

## Step 3 — Plan reading

`tofu plan` summary line:

| Resource | Planned operation | Why |
|---|---|---|
|  |  |  |

What I expected before running plan, and whether I was right:

## Step 3 — State

- `tofu state list` after the chosen path:
- Anything in state that surprised me:

## Alarm work

- Field I changed deliberately:
- State I predicted **before** the change:
- State that actually resulted:
- What the change did *not* change:

## Teardown

Paste the final verification block from `cli/99-teardown.sh`. It must print `clean`.

## Surprises

Anything unexpected is a study item. Write it here and raise it in the next session.
