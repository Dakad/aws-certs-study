#!/usr/bin/env bash
# Lab 03, Step 2 - predict, simulate, then produce the real denial.
#
# Order matters: the simulator states a decision without an API call, then the
# real call proves what actually happens. Comparing the two is the lesson.
#
set -euo pipefail

PREFIX="soa-c03-lab03"
ROLE_NAME="${PREFIX}-role"
ACTION="${ACTION:-s3:ListAllMyBuckets}"

if [[ -z "${AWS_PROFILE:-}" ]]; then
  echo "ERROR: set AWS_PROFILE to the authorized profile before running." >&2
  exit 1
fi

ROLE_ARN="$(aws iam get-role --role-name "$ROLE_NAME" --query 'Role.Arn' --output text)"
BOUNDARY_ARN="$(aws iam get-role --role-name "$ROLE_NAME" \
  --query 'Role.PermissionsBoundary.PermissionsBoundaryArn' --output text)"

echo "== Layer inventory =="
echo "role:     $ROLE_NAME"
echo "boundary: ${BOUNDARY_ARN:-none}"
echo
echo "inline policies:"
aws iam list-role-policies --role-name "$ROLE_NAME" --query 'PolicyNames' --output text
echo
echo "attached policies:"
aws iam list-attached-role-policies --role-name "$ROLE_NAME" \
  --query 'AttachedPolicies[].PolicyName' --output text

echo
echo "== Simulator decision for $ACTION =="
SIM_ARGS=(--policy-source-arn "$ROLE_ARN" --action-names "$ACTION")
if [[ "$BOUNDARY_ARN" != "None" && -n "$BOUNDARY_ARN" ]]; then
  SIM_ARGS+=(--permissions-boundary-policy-arn "$BOUNDARY_ARN")
fi
aws iam simulate-principal-policy "${SIM_ARGS[@]}" \
  --query 'EvaluationResults[].{Action:EvalActionName,Decision:EvalDecision,Matched:MatchedStatements[].SourcePolicyId}' \
  --output json || echo "(simulator unavailable)"

cat <<'GUIDE'
  implicitDeny = nothing allowed it
  explicitDeny = something denied it outright; no Allow can fix that
  The boundary must be passed explicitly; the simulator will not apply it for you.
GUIDE

echo
echo "== Real call as the assumed role =="
CREDS_FILE="$(mktemp)"
if aws sts assume-role --role-arn "$ROLE_ARN" --role-session-name soa-c03-lab03 --query 'Credentials' --output json > "$CREDS_FILE" 2>/dev/null; then
  export AWS_ACCESS_KEY_ID="$(jq -r '.AccessKeyId' "$CREDS_FILE")"
  export AWS_SECRET_ACCESS_KEY="$(jq -r '.SecretAccessKey' "$CREDS_FILE")"
  export AWS_SESSION_TOKEN="$(jq -r '.SessionToken' "$CREDS_FILE")"

  echo "assumed the role:"
  aws sts get-caller-identity --query '{Arn:Arn}' --output json

  echo
  echo "attempting $ACTION"
  set +e
  aws s3 ls > /tmp/lab03_out 2> /tmp/lab03_err
  RC=$?
  set -e
  if [[ "$RC" -eq 0 ]]; then
    echo "  SUCCEEDED (exit 0)"
    head -5 /tmp/lab03_out
  else
    echo "  DENIED (exit $RC)"
    grep -oE '(AccessDenied|AccessDeniedException|UnauthorizedOperation|not authorized)[^.]*' \
      /tmp/lab03_err | head -3 || head -5 /tmp/lab03_err
  fi
  rm -f /tmp/lab03_out /tmp/lab03_err
  unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
else
  echo "  could not assume the role, so the failure is at the trust-policy layer."
  echo "  that is a different failure from an action denial. Note which one you got."
fi
rm -f "$CREDS_FILE"

echo
echo "== What the error message can and cannot tell you =="
cat <<'GUIDE'
  An action denial names the action and the resource but not the layer that
  decided it. "not authorized to perform s3:ListAllMyBuckets" reads the same
  whether the cause was an explicit Deny, a permissions boundary, an SCP, or a
  missing resource policy. The message alone cannot separate those. That is
  what the simulator, the boundary ARN on the role, and CloudTrail are for.

  If the role assumed successfully and only the action failed, the trust
  policy and the session are not the problem. That one split removes half the
  layers before you start reading policies.

  Step 3 of the lab README removes one layer at a time. Predict before each
  removal, because the surprise is the lesson.
GUIDE
