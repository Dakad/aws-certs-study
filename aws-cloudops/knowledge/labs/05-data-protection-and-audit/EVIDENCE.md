# Lab 05 evidence — not yet run

Status: **not yet run**. Replace this line as evidence is recorded.

**A written note, a generated file, a successfully provisioned resource, or a
script that ran without error is not evidence of mastery.** Nothing on this page
counts until you have actually run the commands, read the real output, and can
explain what the output established and what it did not. Where this page asks
for a prediction, write it before you run the step. A prediction you got wrong is
more useful here than a result you copied after the fact.

Redact account IDs to the last four characters. Never record ARNs in full, never
record a secret value, and never record a domain name from ACM.

## Session

- Date:
- AWS profile used:
- Region (`AWS_REGION`, or the default the scripts picked):
- `aws sts get-caller-identity` run before the first mutation? yes / no

## Step 1 — create

| Check | Result |
|---|---|
| KMS `KeyState` / `KeyManager` as returned | |
| Bucket default encryption algorithm | |
| Was the account ID inside the bucket name? | |
| Did `01-create.sh` refuse to run twice? | |

Which of the three tag formats caught you or surprised you (`TagKey=`, `Key=`,
and the JSON `TagSet`)?

## Step 2 — encryption at rest

Prediction, written before running `02-prove-encryption.sh`: the object that
requested `AES256` per-object will report which algorithm, and which key id?

| Object / resource | ServerSideEncryption | Key id | Matches prediction? |
|---|---|---|---|
| `rest/inherits-bucket-default.txt` | | | |
| `rest/per-object-override.txt` | | | |
| `SecureString` parameter (`KeyId` from `describe-parameters`) | | | |
| Secrets Manager secret (`KmsKeyId` from `describe-secret`) | | | |

- Which `GranteeServicePrincipal` grants exist on the key, and what does each one
  let happen without a human being involved?
- Did the SecureString read fail without `--with-decryption`? Error code:
- `iam simulate-principal-policy` decisions for `s3:GetObject` and `kms:Decrypt`:
- Why is a `kms:Decrypt` answer from that simulator incomplete on its own?

In one sentence: what is the difference between "this object is encrypted" and
"this caller can read it"?

## Step 3 — secrets versus parameters

| Question | Secrets Manager | SSM SecureString |
|---|---|---|
| Value visible from `list`/`describe`? | | |
| What the explicit get returns | | |
| How versions are labelled | | |
| Native rotation, or code you write? | | |
| Error shape for a wrong name | | |
| Error shape for a pinned missing version | | |

- After `--overwrite`, which `Version` did `get-parameter` report?
- Which reader would still be holding the *old* value after that overwrite, and
  why would nothing in the Console show it?
- `RotationEnabled` on the lab's secret was `False`. What does that tell you, and
  what does it not tell you?

Your one-line rule for choosing between the two, written in your own words:

## Step 4 — audit evidence and in transit

| Source | Question it answers | Answer from this run |
|---|---|---|
| CloudTrail by `ResourceName` (bucket) | | |
| CloudTrail by `EventName=GetSecretValue` | | |
| CloudTrail by `EventName=PutObject` | | |
| `openssl s_client` chain `notAfter` | | |

- Did any field of a `GetSecretValue` event contain the secret string? yes / no
  (record the answer, never the value).
- `userIdentity.type` and `sessionIssuer` for your own events — what do they let
  you conclude, and what do they still not tell you?
- Were there any ACM certificates in this account and region? If not, what is
  the honest statement about certificate-expiry coverage?
- The TLS certificate you inspected belongs to whom, and whose operational
  problem is its expiry?

Name one thing CloudTrail could not tell you about this lab's activity:

## Step 5 — AWS Config (optional)

- Was a configuration recorder running? yes / no
- If no: did the script refuse to create one, and did it exit `clean`?
- If yes: rule name, `ConfigRuleState`, and the `ComplianceType` reported:

| Resource | ComplianceType | ResultRecordedTime | In scope? |
|---|---|---|---|
| this lab's bucket | | | |
| anything else | | | |

- Why can a rule be `ACTIVE` and still have no evaluation results?
- Why did the script refuse to touch the recorder and the delivery channel?

## Teardown

Paste the final verification block from `cli/99-teardown.sh`. It must print
`clean` for every active resource. Record separately:

- The KMS `KeyState` after scheduling, and the date the key actually disappears.
- The secret's `DeletionDate`, and whether you believe it keeps billing in the
  recovery window (**look this up; do not assume**).

Did the teardown exit code match `clean`?

## Surprises

Anything that contradicted an assumption you wrote above, in the scripts or in the
AWS behaviour. This is the part worth keeping.