# Lab 05 — Data protection, secrets, and audit evidence

**Exam domain:** [4. Security and Compliance](../../../domains/04-security-compliance/README.md) (16%)
**Task guides:** [4.2 Data and infrastructure protection](../../../domains/04-security-compliance/02-task-4-2-data-infrastructure-protection.md), [4.1 Security and compliance tools](../../../domains/04-security-compliance/01-task-4-1-security-compliance-tools.md)
**Knowledge nodes:** [AWS KMS](../../services/kms/README.md), [Amazon S3](../../services/s3/README.md), [AWS Secrets Manager](../../services/secretsmanager/README.md), [CloudTrail](../../services/cloudtrail/README.md), [AWS Config](../../services/config/README.md)
**Status:** Not yet run

## Why this lab exists

Lab 03 covered Domain 4 entirely through IAM policy evaluation, so four of the
task guide's skills had no hands-on exercise at all: encryption at rest and in
transit, secure secret storage, and interpretation of compliance findings. This
lab covers the non-IAM half of Domain 4 with resources that bill by cents, and it
is built around one recurring exam trap: **encryption configuration is not
authorization.** Seeing `aws:kms` on an object tells you nothing about whether
the caller can read it, and this lab produces the two pieces of evidence that
are needed to tell them apart.

Every observation comes from a read of a resource this lab created. Nothing here
inspects or modifies a pre-existing workload, and the existing
`codex-study-cpu-high-ec2-lab` CloudWatch alarm is not touched or referenced.

## Objective

By the end you can:

1. Prove which key encrypted a specific object, a SecureString parameter, and a
   secret, and name the command and the field for each.
2. Explain why a customer-managed KMS key needs both a key policy and an IAM
   policy, and what a grant with `GranteeServicePrincipal=aws:s3` actually
   authorizes.
3. Say what Parameter Store `SecureString` and Secrets Manager do differently in
   practice — rotation and version staging, not "which one is encrypted".
4. State what CloudTrail event history can and cannot establish for one of your
   own API calls, and name a call it does not record by default.
5. Distinguish a Config rule's state from its compliance state, and explain why
   a brand-new rule can be `ACTIVE` with no results.
6. Read a TLS certificate chain and say whose certificate you actually looked at.

## Safety, scope, and cost

**Per-day estimate: about $0.05/day for Steps 1–4.** Step 5 is separately costed
below and is the only part of this lab whose cost you cannot bound from the
scripts alone.

| Item | Target | Cost | Risk | Cleanup |
|---|---|---|---|---|
| KMS customer-managed key | `alias/soa-c03-lab05-key`, new key, disposable | **About $1.00 per key-month ≈ $0.03/day**, plus roughly $0.03 per 10,000 API calls. The only time-based charge in the lab. | Deleting it makes anything it encrypted unrecoverable. Nothing else in the account uses it. | `schedule-key-deletion`, **minimum 7 days**. **The key keeps billing for the whole window** — see below. |
| S3 bucket | `soa-c03-lab05-<account-id>-<region>` | Negligible: two objects of ~30 bytes, no versioning, no replication, no lifecycle. A handful of API requests. | None outside this lab. Contains only fake placeholder strings. | `delete-object` for both keys, then `delete-bucket`. |
| SSM SecureString + String | `soa-c03-lab05/db-password`, `soa-c03-lab05/plain-token` | Roughly $0.05 per parameter-month each on the Standard tier ≈ $0.002/day. Negligible. | None. | `delete-parameter` by path. |
| Secrets Manager secret | `soa-c03-lab05/api-credential` | Roughly $0.40 per secret-month ≈ $0.013/day, plus per-request charges. | `create-secret` takes no recovery-window argument, so a deletion uses a 7- or 30-day window. | `delete-secret --recovery-window-in-days 7`. |
| CloudTrail lookups | `lookup-events`, read-only | Management-event lookups are free. **Data events are not enabled by this lab.** | Enabling data events anywhere would change this; nothing here does. | Nothing to clean up — no trail is created or modified. |
| AWS Config rule (Step 5 only) | `soa-c03-lab05-S3_BUCKET_SSL_REQUESTS_ONLY` | **The one unbounded item.** Config bills per configuration item evaluated plus per rule evaluation, and the rates are region-dependent. The script limits scope to `AWS::S3::Bucket` and frequency to `One_Hour` to bound it. | Enabling it in a region with many buckets is more expensive than it looks. | `delete-config-rule`. The script never creates or deletes a recorder or delivery channel. |
| EC2, NAT gateway, load balancer | **None.** | $0 | Deliberate. | n/a |
| Snapshots, replication, transfer | **None.** | $0 | Deliberate. | n/a |

Two notes on the numbers above. The per-item and per-request rates for KMS, SSM
Parameter Store, and Secrets Manager are quoted from memory and **must be
confirmed against the current pricing pages before you rely on them**; the
ordering (the KMS key dominates) is what matters here, not the decimals. The AWS
Config rate is deliberately left as a shape rather than a figure because it
varies by region and I could not verify it locally — read it yourself before Step
5, or skip Step 5.

### The KMS deletion window

`schedule-key-deletion` accepts 7 to 30 days and defaults to 30. Seven is the
minimum. Until the window ends the key sits in `PendingDeletion`: it cannot be
used for any cryptographic operation, its aliases are not removed by KMS until
afterwards, and **it continues to accrue its monthly charge for every day of the
window**. A key created on 2026-10-15 finishes deleting no earlier than
2026-10-22. `99-teardown.sh` removes the alias immediately so nothing can still
resolve the key by name, and reports the key as *pending, not active* rather than
*clean*.

## Sequence

### Step 0 — Verify identity and check for Config

```bash
aws sts get-caller-identity
aws configservice describe-configuration-recorders \
  --configuration-recorder-names default
```

Read the account and region before creating anything. The second command is the
one that decides whether Step 5 is worth running; `01-create.sh` repeats it
read-only and prints the answer.

### Step 1 — Create

```bash
AWS_PROFILE=<your-authorized-profile> ./cli/01-create.sh
```

Read the script before running it. It creates one customer-managed KMS key, one
private S3 bucket with default SSE-KMS and all four public-access-block settings,
two objects that disagree about their encryption, one `SecureString` parameter on
that key, one plain `String` parameter as a contrast, and one Secrets Manager
secret on the same key.

It refuses to run if the bucket or the key alias already exists.

**What to observe.** The tag shorthand differs by service and will teach you
something if you read the script first: KMS takes `TagKey=/TagValue=`, SSM and
Secrets Manager take `Key=/Value=`, and the bucket takes a JSON `TagSet`. Also
note that the bucket name embeds your account ID so that the teardown can rebuild
it without a state file. That is a deliberate trade-off: it makes the lab
deterministic and leaves nothing to clean up, and in exchange the account ID is
legible in the bucket name. Do not paste that name into this repository.

### Step 2 — Prove which encryption is in effect

```bash
./cli/02-prove-encryption.sh
```

Read-only. Walk the six sections in order and note the field each one reads.

**What to observe.**

1. `describe-key` reports `KeyManager=CUSTOMER` and `Origin=AWS_KMS`, and
   `DeletionDate` is absent.
2. The key policy grants the account principal; grants exist with
   `GranteeServicePrincipal=aws:s3`, `aws:ssm`, and `aws.secretsmanager`.
3. `get-bucket-encryption` reports `aws:kms` with the lab key as
   `KMSMasterKeyID`.
4. `head-object` on the object that requested no per-object SSE reports
   `ServerSideEncryption=aws:kms` and the key id; on the object that requested
   `AES256` it reports `AES256` and no key id — the per-object header beats the
   bucket default.
5. `describe-parameters` shows `Type=SecureString` and the `KeyId`, and no
   `Value`. Reading it without `--with-decryption` fails; reading it with it
   returns a value whose length the script prints instead of the value.
6. `get-ebs-encryption-by-default` and `describe-volumes` give a read-only
   survey of EBS encryption elsewhere in the account.
7. `simulate-principal-policy` reports decisions for `s3:GetObject` and
   `kms:Decrypt` against your own principal.

**The distinction to leave with.** `s3:GetObject` is checked by S3 against the
bucket policy and your identity policies. `kms:Decrypt` is checked by KMS against
the key policy and your identity policies. An `AES256` object only needs the
first, because the AWS-managed S3 key is not yours to authorize.

### Step 3 — Secrets Manager versus a SecureString

```bash
./cli/03-secrets-compare.sh
```

**What to observe.** Neither `list-secrets` nor `describe-parameters` returns a
value; only an explicit `get` does. `get-parameter-history` shows version
numbers with no state labels, while `describe-secret`'s `VersionIdsToStages`
shows `AWSCURRENT` and `AWSPREVIOUS`. `RotationEnabled` is `False`, which means
"not configured", not "cannot rotate". After the deliberate `--overwrite`, the
parameter reports a new `Version` while any consumer that cached the old value
still holds it — a rotation failure mode with no Console indicator.

Also compare the three error shapes: wrong secret id, wrong parameter name, and a
pinned version that does not exist.

### Step 4 — Audit evidence and encryption in transit

```bash
./cli/04-audit-evidence.sh
```

Read-only, including the TLS part.

**What to observe.** Six CloudTrail lookups. Three should find events for the
bucket, the parameter, and the secret. `PutObject` and `GetObject` most likely
find **nothing**, because S3 object-level calls are data events and are not in
event history unless data events are enabled. That empty result is the point of
the step: "CloudTrail shows no GetObject" does not mean "nobody read the object".

Then `openssl s_client` reads the certificate chain of the S3 endpoint for your
region. Read the framing carefully: that is Amazon's certificate, not yours, and
its expiry is not your problem. It demonstrates the handshake, not your
certificate lifecycle.

Finally the script lists ACM read-only. If the account has no certificates — the
likely case — it says so and prints the fields you would inspect instead, without
pretending you observed them.

### Step 5 — AWS Config compliance evidence (optional, costed separately)

```bash
./cli/05-config-compliance.sh
```

If no configuration recorder is running, the script explains why compliance
results are impossible here, prints the rule it would have created, and exits
`clean` without creating anything. It will not create a recorder or a delivery
channel: those are account-level, bill while they exist, and may be shared.

If a recorder is running, the script creates one managed rule scoped to
`AWS::S3::Bucket` at `One_Hour` frequency and reads back three separate things:
`ConfigRuleState` (is it running), `ComplianceType` (what it concluded), and the
per-resource `EvaluationResults` with `ResultRecordedTime`.

`put-config-rule` may exit non-zero if the managed-rule identifier does not exist
or is not enabled in your region. The script prints the command to re-run by hand
so you can read the message, and accepts an override:

```bash
CONFIG_RULE_ID=ACM_CERTIFICATE_EXPIRY_CHECK ./cli/05-config-compliance.sh
```

Confirm the identifier on the official AWS Config managed-rules list before using
an override; this lab does not assume any identifier exists.

### Step 6 — Teardown and verification

```bash
./cli/99-teardown.sh
```

Idempotent, and safe after a partial create. It deletes the Config rules first,
then the secret, then the SSM parameters, then the bucket objects and the bucket,
then schedules KMS key deletion. Finally it re-queries everything and prints
`clean` only when nothing active remains. Anything still active is a
`STILL PRESENT` row and the script **exits non-zero**. Resources already inside a
deletion window are reported as *pending, not active* and do not fail the run,
because otherwise a second teardown could never succeed.

Confirm the same state in the Console before calling the lab finished:

```bash
aws kms list-aliases \
  --query "Aliases[?starts_with(AliasName, 'alias/soa-c03-lab05')].AliasName"
aws ssm describe-parameters \
  --parameter-filters Key=Name,Option=BeginsWith,Values=soa-c03-lab05 \
  --query 'Parameters[].Name'
aws secretsmanager list-secrets --include-planned-deletion \
  --query "SecretList[?starts_with(Name, 'soa-c03-lab05')].Name"
```

## Relation to Lab 03, and how the two combine

[Lab 03 — IAM policy evaluation and the AccessDenied trace](../03-iam-policy-evaluation/README.md)
is the *authorization* half of Domain 4; this lab is the *data protection* half.
Together they answer the one question the Task 4.2 check asks: an application
cannot read an encrypted S3 object — which layer refused?

| Question | Lab 03 | Lab 05 |
|---|---|---|
| What was requested, by whom, against what? | `simulate-principal-policy`, real denial | `lookup-events`, `describe-key` |
| Did identity or resource policy allow it? | explicit deny, boundary, SCP, resource policy | bucket policy and key policy, read separately |
| Was the ciphertext even readable? | not covered | `get-object` succeeds or does not |
| What did the evidence prove? | which policy layer decided | which key encrypted it, and whether that key was usable |

The two labs join at Step 7 above and at Lab 03 Step 4. Lab 03 leaves the KMS
case as a reading exercise; this lab produces the `describe-key`, key-policy, and
`list-grants` output that settles it, and Step 2 deliberately reaches the same
`simulate-principal-policy` limitation Lab 03 warns about — the simulator applies
a permissions boundary but not a KMS key policy, so its `kms:Decrypt` answer is
incomplete by construction. Run them back to back and the full two-layer answer
to Task 4.2 has evidence behind every clause.

## What this lab does not cover

Stated plainly, so the coverage is not overstated:

- **Certificate expiry monitoring is not exercised.** No ACM certificate is
  created, because issuance needs a domain whose DNS you control and the sandbox
  has none. Step 4 observes the field shape only, and only if the account already
  has a certificate.
- **Rotation is not executed.** `RotationEnabled` is `False` and stays `False`.
  Neither Secrets Manager's four-stage rotation nor a Parameter Store rotation
  Lambda is created, because both need a Lambda function and a consumer, which
  are the expensive part.
- **No Secrets Manager rotation or cross-account replication**, no Secrets Manager
  `ReplicaRegion`, no generated `AWSPENDING` version.
- **No data classification** (Task 4.2 skill 4.2.1) and no mapping of a
  classification to retention or disposal controls.
- **No Security Hub, GuardDuty, or Inspector findings.** Only Config compliance
  evidence, and only if a recorder already exists.
- **No Terraform/OpenTofu configuration.** Lab 03 has none either, and Domain 3
  owns the IaC loop; see
  [Lab 01 — Disposable instance, alarm, and the OpenTofu loop](../01-disposable-alarm-and-iac/README.md)
  for the plan/state/import comparison against a real existing resource.
- **Nothing about bucket keying** (`BucketKeyEnabled`) beyond reading the field.

## Assumptions to verify at run time

Each of these is version- or account-sensitive. I could not confirm them from
local `aws ... help` output, and the lab does not assert them.

1. **Pricing.** The KMS, Parameter Store, and Secrets Manager rates in the cost
   table, and the AWS Config rate shape.
2. **Config managed-rule identifier.** `S3_BUCKET_SSL_REQUESTS_ONLY` is used as
   the default and `ACM_CERTIFICATE_EXPIRY_CHECK` is offered as an alternative.
   Neither identifier was verifiable offline. Confirm on the official
   managed-rules list.
3. **`put-config-rule` shape.** In AWS CLI 2.34.57 the operation accepts only
   `--config-rule` as a JSON document plus `--tags`; the older
   `--config-rule-name`/`--source`/`--scope` shorthand is **not** accepted by this
   CLI version. On an older CLI you may need that shorthand instead.
4. **S3 data events.** That `PutObject`/`GetObject` do not appear in
   `lookup-events` depends on data-event configuration on the account's trails
   and on this bucket. If your sandbox already enables S3 data events, step 4 will
   find them and the interpretation changes.
5. **Config evaluation timing.** That a newly created rule has no
   `EvaluationResults` for a while is a documentation-level expectation, not
   something I observed. Check `ResultRecordedTime` before concluding anything.
6. **Secret and key billing during their deletion windows.** Whether an S3-style
   resource still accrues charges while scheduled for deletion is a question to
   look up per service. Verify it, do not assume it.
7. **`--body` on `put-object` requires a file path.** Both scripts write a
   temporary file and pass its path. Confirm on your CLI version rather than
   passing a bare string.

## Evidence to record

Copy into [EVIDENCE.md](EVIDENCE.md). Redact account IDs; never record ARNs in
full, secret values, or ACM domain names.

- Your Step 2 prediction about which algorithm the `AES256` object would report,
  written before you ran the script.
- The two `head-object` results side by side, with key ids redacted.
- The `GranteeServicePrincipal` list from `list-grants`.
- The Secrets Manager versus Parameter Store table, including the three error
  shapes.
- Whether `PutObject` appeared in CloudTrail, and what you concluded from that.
- The `ConfigRuleState` and `ComplianceType` from Step 5, or the reason you
  skipped it.
- The full teardown output, plus the KMS `KeyState` and the date the key actually
  disappears.

## Cleanup risk if interrupted

```bash
aws s3api head-bucket --bucket "soa-c03-lab05-$(aws sts get-caller-identity --query Account --output text)-${AWS_REGION:-us-east-1}"
aws kms list-aliases \
  --query "Aliases[?starts_with(AliasName, 'alias/soa-c03-lab05')].AliasName"
```

The KMS key is the resource to act on first if you are short on time, and it is
the one that keeps billing. Scheduling deletion stops it being usable but not
being charged; finishing the rest of the teardown is what stops the rest.
