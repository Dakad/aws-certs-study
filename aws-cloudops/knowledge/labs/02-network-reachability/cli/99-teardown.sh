#!/usr/bin/env bash
# Lab 02 teardown — remove every resource this lab created, then prove it.
#
# Order matters for cost: disable access logging and delete the load balancer
# first, because it is the only cost-bearing resource here. Everything else is
# free but must still be cleaned up.
#
set -euo pipefail

AWS_REGION="${AWS_REGION:-us-east-1}"
PREFIX="soa-c03-lab02"
TAG_KEY="soa-c03-lab02"
TAG_VALUE="true"
VPC_CIDR="${VPC_CIDR:-10.60.0.0/16}"

echo "== 1. Disabling access logs, then deleting the load balancer =="
ALB_ARN="$(aws elbv2 describe-load-balancers --names "${PREFIX}-alb" \
  --query 'LoadBalancers[0].LoadBalancerArn' --output text 2>/dev/null || echo None)"

if [[ "$ALB_ARN" != "None" && -n "$ALB_ARN" ]]; then
  aws elbv2 modify-load-balancer-attributes --load-balancer-arn "$ALB_ARN" \
    --attributes Key=access_logs.s3.enabled,Value=false >/dev/null
  aws elbv2 delete-load-balancer --load-balancer-arn "$ALB_ARN"
  echo "  deleted ALB; waiting for it to disappear"
  for _ in $(seq 1 30); do
    sleep 10
    LEFT="$(aws elbv2 describe-load-balancers --load-balancer-arns "$ALB_ARN" \
      --query 'LoadBalancers[].LoadBalancerArn' --output text 2>/dev/null || echo None)"
    [[ "$LEFT" == "None" || -z "$LEFT" ]] && break
  done
else
  echo "  no ALB found"
fi

echo
echo "== 2. Deleting target group =="
TG_ARN="$(aws elbv2 describe-target-groups --names "${PREFIX}-tg" \
  --query 'TargetGroups[0].TargetGroupArn' --output text 2>/dev/null || echo None)"
if [[ "$TG_ARN" != "None" && -n "$TG_ARN" ]]; then
  aws elbv2 delete-target-group --target-group-arn "$TG_ARN"
  echo "  deleted"
else
  echo "  none found"
fi

echo
echo "== 3. Deleting VPC Flow Logs and its IAM role =="
VPC_ID="$(aws ec2 describe-vpcs --filters "Name=cidr,Values=${VPC_CIDR}" \
  --query 'Vpcs[0].VpcId' --output text 2>/dev/null || echo None)"
if [[ "$VPC_ID" != "None" && -n "$VPC_ID" ]]; then
  FLOW_IDS="$(aws ec2 describe-flow-logs --resource-id "$VPC_ID" \
    --query 'FlowLogs[].FlowLogId' --output text)"
  for f in $FLOW_IDS; do
    [[ -z "$f" ]] && continue
    echo "  deleting flow log $f"
    aws ec2 delete-flow-logs --flow-log-ids "$f"
  done
fi

aws logs delete-log-group --log-group-name "/aws/vpc/flowlogs/${PREFIX}" 2>/dev/null || true

FLOW_ROLE="${PREFIX}-flow-logs"
if aws iam get-role --role-name "$FLOW_ROLE" >/dev/null 2>&1; then
  aws iam delete-role-policy --role-name "$FLOW_ROLE" --policy-name flow-logs-write 2>/dev/null || true
  aws iam delete-role --role-name "$FLOW_ROLE"
  echo "  deleted role $FLOW_ROLE"
fi

echo
echo "== 4. Emptying and deleting the access-log bucket =="
BUCKETS="$(aws s3 ls --region "$AWS_REGION" 2>/dev/null | awk '/soa-c03-lab02-alb-logs/ {print $NF}')"
if [[ -z "$BUCKETS" ]]; then
  echo "  no soa-c03-lab02-alb-logs-* bucket found"
else
  for BUCKET in $BUCKETS; do
    echo "  emptying $BUCKET"
    aws s3 rm "s3://${BUCKET}/" --recursive --region "$AWS_REGION" >/dev/null 2>&1 || true
    if aws s3api delete-bucket --bucket "$BUCKET" --region "$AWS_REGION" >/dev/null 2>&1; then
      echo "  deleted bucket $BUCKET"
    else
      echo "  WARNING: could not delete $BUCKET — remove it by hand"
    fi
  done
fi

echo
echo "== 5. Deleting the VPC and everything in it =="
if [[ "$VPC_ID" != "None" && -n "$VPC_ID" ]]; then
  IGW_IDS="$(aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=${VPC_ID}" \
    --query 'InternetGateways[].InternetGatewayId' --output text)"
  for g in $IGW_IDS; do
    [[ -z "$g" ]] && continue
    aws ec2 detach-internet-gateway --vpc-id "$VPC_ID" --internet-gateway-id "$g"
    aws ec2 delete-internet-gateway --internet-gateway-id "$g"
    echo "  deleted igw $g"
  done
  echo "  deleting VPC $VPC_ID (cascades subnets, route tables, security groups)"
  aws ec2 delete-vpc --vpc-id "$VPC_ID"
else
  echo "  no VPC found for $VPC_CIDR"
fi

echo
echo "== 6. Verification =="
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

check "vpcs" "$(aws ec2 describe-vpcs --filters "Name=cidr,Values=${VPC_CIDR}" \
  --query 'Vpcs[].VpcId' --output text)"
check "load balancers" "$(aws elbv2 describe-load-balancers --names "${PREFIX}-alb" \
  --query 'LoadBalancers[].LoadBalancerArn' --output text 2>/dev/null || echo None)"
check "target groups" "$(aws elbv2 describe-target-groups --names "${PREFIX}-tg" \
  --query 'TargetGroups[].TargetGroupArn' --output text 2>/dev/null || echo None)"
check "vpc flow logs" "$(aws ec2 describe-flow-logs --filters "Name=resource-id,Values=${VPC_ID}" \
  --query 'FlowLogs[].FlowLogId' --output text 2>/dev/null || echo None)"
check "cw log groups" "$(aws logs describe-log-groups \
  --log-group-name-prefix "/aws/vpc/flowlogs/${PREFIX}" \
  --query 'logGroups[].logGroupName' --output text 2>/dev/null || echo None)"
check "log buckets" "$(aws s3 ls --region "$AWS_REGION" 2>/dev/null \
  | awk '/soa-c03-lab02-alb-logs/ {print $NF}' || true)"
check "iam roles" "$(aws iam list-roles \
  --query "Roles[?starts_with(RoleName, '${PREFIX}')].RoleName" --output text)"

echo
if [[ "$FAILED" -eq 0 ]]; then
  echo "clean — no soa-c03-lab02 resources remain."
else
  echo "INCOMPLETE — see the STILL PRESENT rows above."
fi
exit "$FAILED"
