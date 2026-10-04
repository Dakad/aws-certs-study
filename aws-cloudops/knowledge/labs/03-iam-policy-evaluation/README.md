# Lab 03 — IAM policy evaluation and the AccessDenied trace

**Exam domain:** [4. Security and Compliance](../../../domains/04-security-compliance/README.md) (16%)
**Task guides:** [4.1 Security and compliance tools](../../../domains/04-security-compliance/01-task-4-1-security-compliance-tools.md), [4.2 Data and infrastructure protection](../../../domains/04-security-compliance/02-task-4-2-data-infrastructure-protection.md)
**Knowledge nodes:** [AWS IAM](../../services/iam/README.md), [AWS Organizations and SCPs](../../services/organizations/README.md)
**Status:** Not yet run

## Why this lab exists

Domain 4 is the only domain that had not been started, and its central skill — deciding *why* a request was denied — is a reasoning skill, not a provisioning one. That makes it the cheapest coverage available, and it needs no disposable infrastructure.

The Domain 4 check asks: a role's identity policy allows an S3 action, yet the request is denied. Why might adding another `Allow` have no effect? This lab makes each candidate answer a thing you can actually observe, in this order:

1. an explicit `Deny` overriding an `Allow`
2. a permissions boundary removing the permission
3. a resource policy that never granted it in the first place

## Objective

By the end you can:

1. State the order in which IAM evaluates policy layers, and which layer can turn an `Allow` into a `AccessDenied`.
2. Use the policy simulator to predict a decision, then produce the real denial and match the two.
3. Explain why an SCP limits permissions without granting them.
4. Separate "S3 refused the request" from "KMS would not decrypt the object", which are different failures with different evidence.

## Design and cost

| Item | Note |
|---|---|
| Scope | The authorized playground (`sso-apptweakplayground-apptweakadmin`) or a personal account. Never a shared or production AppTweak account. |
| Cost | **Zero.** IAM is free, the policy simulator is free, and no compute, storage, or load balancer is created. There is nothing here that can accrue a bill. |
| Resources | One IAM role, one managed policy, one permissions boundary, one instance profile. All named `soa-c03-lab03-*` so they are easy to find and delete. |
| Side effects | The role's trust policy allows only your own principal to assume it, so nobody else can use it. No wildcards in any allow. |

This is the only lab that can be run without the playground's cost clock in mind, which makes it the right lab to run when the sandbox is nearly expired.

## Sequence

### Step 0 — Verify identity

```bash
aws sts get-caller-identity
```

You need your own principal ARN for the trust policy. The script reads it at runtime; do not hardcode it, and do not record it in this repository.

### Step 1 — Create the denial

```bash
AWS_PROFILE=sso-apptweakplayground-apptweakadmin ./cli/01-create.sh
```

This creates a role whose identity policy allows `s3:ListAllMyBuckets`, plus a managed policy containing an explicit `Deny` on `s3:*`. The role also gets a permissions boundary that permits nothing at all, so you can add and remove one more constraint independently.

### Step 2 — Predict, then test

**Predict before you run anything.** With all three layers in place, is `s3:ListAllMyBuckets` allowed?

Then assume the role and try:

```bash
./cli/02-evaluate.sh
```

The script runs the policy simulator first and then a real call, so you can compare a prediction with an outcome. Record both.

### Step 3 — Remove one layer at a time

This is the part that teaches something.

1. Detach the explicit `Deny`. Predict: does the call succeed? The boundary is still attached and still permits nothing, so it should not.
2. Remove the boundary. Predict: does it succeed now?
3. Put the boundary back but scope it to allow `s3:ListAllMyBuckets`. Predict: does it succeed?

If any prediction was wrong, that is the finding worth recording — the layer order is the thing to correct.

### Step 4 — The same shape on KMS

Create a customer-managed KMS key with a key policy that does not grant your principal `kms:Decrypt`, then simulate `kms:Decrypt` against it. An encrypted S3 object that cannot be read fails in one of two places: S3 authorization, or KMS decryption. Name the evidence that distinguishes them, and say which one a `s3:GetObject` denial message points at.

[Lab 05 — Data protection, secrets, and audit evidence](../05-data-protection-and-audit/README.md) carries this step out for real: it creates the customer-managed key, reads its key policy and its grants, proves which key encrypted the object, and reaches the same `simulate-principal-policy` limitation this step warns about. Run it after this lab to turn Step 4 from a reading exercise into an observation.

## Evidence to record

Copy into [EVIDENCE.md](EVIDENCE.md). Redact account IDs and never record ARNs in full.

- Your Step 2 prediction, written before running the script.
- The simulator's decision versus the real error code.
- Each Step 3 prediction and outcome, in order.
- The two-layer explanation of the KMS case from Step 4.
- The full cleanup output.

## Cleanup risk if interrupted

```bash
aws iam list-roles --query "Roles[?starts_with(RoleName,'soa-c03-lab03')].RoleName"
aws iam list-policies --scope Local \
  --query "Policies[?starts_with(PolicyName,'soa-c03-lab03')].PolicyName"
```

IAM resources do not cost anything, so an interrupted cleanup is not a billing problem — but leftover roles with trust policies are a security-hygiene problem. Finish the teardown even though nothing is accruing cost.
