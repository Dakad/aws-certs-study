#!/usr/bin/env bash
# Lab 03, Step 1 — create an IAM role that looks allowed and is not.
#
# Creates: one role, one customer-managed policy holding an explicit Deny,
#          one permissions boundary that permits nothing, one instance profile.
#
# IAM is free and nothing here can accrue a cost.
#
# Review this file before running it. The trust policy is scoped to your own
# principal so this role cannot be assumed by anyone else.
#
# Required environment:
#   AWS_PROFILE   authorized playground or personal-account profile
#
set -euo pipefail

PREFIX="soa-c03-lab03"
ROLE_NAME="${PREFIX}-role"
BOUNDARY_NAME="${PREFIX}-boundary"
DENY_POLICY_NAME="${PREFIX}-explicit-deny"

if [[ -z "${AWS_PROFILE:-}" ]]; then
  echo "ERROR: set AWS_PROFILE to the authorized profile before running." >&2
  exit 1
fi

echo "== Step 0: identity =="
CALLER_ARN="$(aws sts get-caller-identity --query Arn --output text)"
ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
echo "caller principal: $CALLER_ARN"
echo "(do not copy this ARN into any file in this repository)"

# ----------------------------------------------------------- boundary
# A boundary that permits nothing. Attaching this alone denies everything,
# regardless of what any identity or resource policy allows.
echo
echo "== Creating the deny-everything permissions boundary =="
aws iam create-policy \
  --policy-name "$BOUNDARY_NAME" \
  --description "SOA-C03 lab 03 boundary that permits no actions" \
  --policy-document '{"Version":"2012-10-17","Statement":[{"Sid":"NoPermissions","Effect":"Deny","Action":"*","Resource":"*"}]}' \
  --tags "Key=soa-c03-lab03,Value=true" >/dev/null
echo "boundary: $BOUNDARY_NAME"

# ------------------------------------------------------- explicit deny
# An explicit Deny in an identity policy overrides every Allow. The role will
# carry this, so "adding another Allow" will have no effect until it is removed.
echo
echo "== Creating the explicit-Deny policy =="
aws iam create-policy \
  --policy-name "$DENY_POLICY_NAME" \
  --description "SOA-C03 lab 03 explicit deny on s3" \
  --policy-document '{"Version":"2012-10-17","Statement":[{"Sid":"DenyS3","Effect":"Deny","Action":"s3:*","Resource":"*"}]}' \
  --tags "Key=soa-c03-lab03,Value=true" >/dev/null
echo "policy: $DENY_POLICY_NAME"

# --------------------------------------------------------------- role
echo
echo "== Creating the role =="
aws iam create-role \
  --role-name "$ROLE_NAME" \
  --description "SOA-C03 lab 03 policy evaluation role" \
  --assume-role-policy-document "$(jq -cn --arg principal "$CALLER_ARN" '{
    Version: "2012-10-17",
    Statement: [{
      Effect: "Allow",
      Principal: { AWS: $principal },
      Action: "sts:AssumeRole"
    }]
  }')" \
  --permissions-boundary "arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):policy/${BOUNDARY_NAME}" \
  --tags "Key=soa-c03-lab03,Value=true" >/dev/null

# The Allow. This is the statement that makes the scenario look permitted.
aws iam put-role-policy --role-name "$ROLE_NAME" --policy-name allow-s3-list \
  --policy-document '{"Version":"2012-10-17","Statement":[{"Sid":"AllowS3List","Effect":"Allow","Action":"s3:ListAllMyBuckets","Resource":"*"}]}' >/dev/null

aws iam attach-role-policy --role-name "$ROLE_NAME" \
  --policy-arn "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore" >/dev/null
aws iam attach-role-policy --role-name "$ROLE_NAME" \
  --policy-arn "arn:aws:iam::${ACCOUNT_ID}:policy/${DENY_POLICY_NAME}" >/dev/null

aws iam create-instance-profile --instance-profile-name "${ROLE_NAME}-profile" \
  --tags "Key=soa-c03-lab03,Value=true" >/dev/null
aws iam add-role-to-instance-profile --instance-profile-name "${ROLE_NAME}-profile" \
  --role-name "$ROLE_NAME" >/dev/null

echo "role: $ROLE_NAME"
echo
echo "== Effective configuration =="
aws iam get-role --role-name "$ROLE_NAME" \
  --query 'Role.{Name:RoleName,Boundary:PermissionsBoundary.PermissionsBoundaryArn}' --output table
aws iam list-attached-role-policies --role-name "$ROLE_NAME" \
  --query 'AttachedPolicies[].PolicyName' --output text
aws iam list-role-policies --role-name "$ROLE_NAME" \
  --query 'PolicyNames' --output text

cat <<EOF

== Created. Next steps from the lab README ==
  Step 2  PREDICT first, then: ./cli/02-evaluate.sh
  Step 3  remove one layer at a time and predict before each removal
  Step 4  the same shape on a customer-managed KMS key

  Three constraints are in place and they interact:
    inline Allow       s3:ListAllMyBuckets
    attached policy    explicit Deny on s3:*
    boundary           Deny on everything

  Teardown: ./cli/99-teardown.sh
EOF
