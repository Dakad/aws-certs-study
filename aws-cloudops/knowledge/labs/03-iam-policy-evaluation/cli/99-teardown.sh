#!/usr/bin/env bash
# Lab 03 teardown - remove every IAM object this lab created, then prove it.
#
# IAM is free, so nothing here accrues cost. Leftover roles with trust
# policies are still a hygiene problem, so finish the cleanup regardless.
#
set -euo pipefail

PREFIX="soa-c03-lab03"
ROLE_NAME="${PREFIX}-role"
BOUNDARY_NAME="${PREFIX}-boundary"
DENY_POLICY_NAME="${PREFIX}-explicit-deny"

# iam get-policy and iam delete-policy take --policy-arn, not --policy-name.
# Customer-managed policies created by this lab have no path, so their ARN is
# built directly rather than looked up.
ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
policy_arn() { echo "arn:aws:iam::${ACCOUNT_ID}:policy/$1"; }

echo "== 1. Removing the instance profile =="
for p in $(aws iam list-instance-profiles \
    --query "InstanceProfiles[?starts_with(InstanceProfileName, '${PREFIX}')].InstanceProfileName" \
    --output text); do
  [[ -z "$p" ]] && continue
  for r in $(aws iam get-instance-profile --instance-profile-name "$p" \
      --query 'InstanceProfile.Roles[].RoleName' --output text); do
    [[ -z "$r" ]] && continue
    aws iam remove-role-from-instance-profile --instance-profile-name "$p" --role-name "$r" || true
  done
  aws iam delete-instance-profile --instance-profile-name "$p"
  echo "  deleted $p"
done

echo
echo "== 2. Deleting the role and its policies =="
if aws iam get-role --role-name "$ROLE_NAME" >/dev/null 2>&1; then
  aws iam delete-role-policy --role-name "$ROLE_NAME" --policy-name allow-s3-list 2>/dev/null || true

  for pn in $(aws iam list-attached-role-policies --role-name "$ROLE_NAME" \
      --query 'AttachedPolicies[].PolicyName' --output text); do
    [[ -z "$pn" ]] && continue
    aws iam detach-role-policy --role-name "$ROLE_NAME" \
      --policy-arn "arn:aws:iam::aws:policy/${pn}" 2>/dev/null \
      || aws iam detach-role-policy --role-name "$ROLE_NAME" \
           --policy-arn "$(policy_arn "$pn")" 2>/dev/null || true
  done

  aws iam delete-role --role-name "$ROLE_NAME"
  echo "  deleted role $ROLE_NAME"
else
  echo "  role not found"
fi

echo
echo "== 3. Deleting customer-managed policies =="
for p in "$BOUNDARY_NAME" "$DENY_POLICY_NAME"; do
  P_ARN="$(policy_arn "$p")"
  if aws iam get-policy --policy-arn "$P_ARN" >/dev/null 2>&1; then
    ATTACHED="$(aws iam list-entities-for-policy --policy-arn "$P_ARN" \
      --query 'PolicyRoles[].RoleName' --output text)"
    [[ "$ATTACHED" != "None" && -n "$ATTACHED" ]] && \
      echo "  WARNING: $p still attached to: $ATTACHED"
    aws iam delete-policy --policy-arn "$P_ARN"
    echo "  deleted $p"
  else
    echo "  $p not found"
  fi
done

echo
echo "== 4. Optional: any leftover KMS key from Step 4 =="
for k in $(aws kms list-aliases \
    --query "Aliases[?starts_with(AliasName, 'alias/${PREFIX}')].TargetKeyId" \
    --output text 2>/dev/null); do
  [[ -z "$k" ]] && continue
  echo "  scheduling deletion of key $k (7-day minimum)"
  aws kms schedule-key-deletion --key-id "$k" --pending-window-in-days 7 >/dev/null || true
done

echo
echo "== 5. Verification =="
FAILED=0
check() {
  local label="$1" result="$2"
  if [[ "$result" == "None" || -z "$result" ]]; then
    printf '  %-20s empty  OK\n' "$label"
  else
    printf '  %-20s %s  STILL PRESENT\n' "$label" "$result"
    FAILED=1
  fi
}

check "roles" "$(aws iam list-roles \
  --query "Roles[?starts_with(RoleName, '${PREFIX}')].RoleName" --output text)"
check "instance profiles" "$(aws iam list-instance-profiles \
  --query "InstanceProfiles[?starts_with(InstanceProfileName, '${PREFIX}')].InstanceProfileName" --output text)"
check "local policies" "$(aws iam list-policies --scope Local \
  --query "Policies[?starts_with(PolicyName, '${PREFIX}')].PolicyName" --output text)"
check "kms aliases" "$(aws kms list-aliases \
  --query "Aliases[?starts_with(AliasName, 'alias/${PREFIX}')].AliasName" --output text 2>/dev/null || echo None)"

echo
if [[ "$FAILED" -eq 0 ]]; then
  echo "clean - no soa-c03-lab03 IAM objects remain."
else
  echo "INCOMPLETE - see the STILL PRESENT rows above."
fi
exit "$FAILED"
