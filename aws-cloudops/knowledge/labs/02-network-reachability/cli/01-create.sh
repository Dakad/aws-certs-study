#!/usr/bin/env bash
# Lab 02, Step 1 — build an isolated VPC whose 503 source is controllable.
#
# Creates: one VPC, two public subnets, an internet gateway, a route table,
#          an ALB security group, an ALB, a target group holding one
#          unreachable IP target, a fixed-response 503 listener, and VPC Flow
#          Logs to a CloudWatch log group.
#
# Deliberately absent: NAT gateway (~$0.045/hr plus per-GB) and EC2 instances.
# The load balancer is the only cost-bearing resource here.
#
# Review this file before running it. Everything lives in VPC_CIDR, which you
# must confirm is unused first.
#
# Required environment:
#   AWS_PROFILE   authorized playground or personal-account profile
# Optional environment:
#   AWS_REGION    default us-east-1
#   VPC_CIDR      default 10.60.0.0/16
#   ALB_PORT      default 80
#
set -euo pipefail

AWS_REGION="${AWS_REGION:-us-east-1}"
VPC_CIDR="${VPC_CIDR:-10.60.0.0/16}"
ALB_PORT="${ALB_PORT:-80}"
PREFIX="soa-c03-lab02"
TAG_KEY="soa-c03-lab02"
TAG_VALUE="true"
TAGS="Key=${TAG_KEY},Value=${TAG_VALUE}"

if [[ -z "${AWS_PROFILE:-}" ]]; then
  echo "ERROR: set AWS_PROFILE to the authorized profile before running." >&2
  exit 1
fi

echo "== Step 0: identity, region, and CIDR availability =="
aws sts get-caller-identity
echo "region: $AWS_REGION"
EXISTING="$(aws ec2 describe-vpcs --filters "Name=cidr,Values=${VPC_CIDR}" \
  --query 'Vpcs[].VpcId' --output text)"
if [[ "$EXISTING" != "None" && -n "$EXISTING" ]]; then
  echo "ERROR: $VPC_CIDR is already in use by $EXISTING." >&2
  echo "Set VPC_CIDR to an unused range before continuing." >&2
  exit 1
fi
echo "cidr $VPC_CIDR is free"

# ------------------------------------------------------------------- VPC
echo
echo "== Creating VPC =="
VPC_ID="$(aws ec2 create-vpc --cidr-block "$VPC_CIDR" \
  --tag-specifications "ResourceType=vpc,Tags=[{Key=Name,Value=${PREFIX}-vpc},{Key=${TAG_KEY},Value=${TAG_VALUE}}]" \
  --query 'Vpc.VpcId' --output text)"
aws ec2 modify-vpc-attribute --vpc-id "$VPC_ID" --enable-dns-hostnames
aws ec2 modify-vpc-attribute --vpc-id "$VPC_ID" --enable-dns-support
echo "vpc: $VPC_ID"

# --------------------------------------------------------------- subnets
echo
echo "== Creating public subnets in two AZs =="
mapfile -t AZS < <(aws ec2 describe-availability-zones \
  --filters Name=state,Values=available \
  --query 'AvailabilityZones[].ZoneName' --output text | head -2)
echo "azs: ${AZS[0]} ${AZS[1]}"

SUBNET_IDS=()
for i in 0 1; do
  SUBNET_IDS+=("$(aws ec2 create-subnet --vpc-id "$VPC_ID" \
    --cidr-block "10.60.$i.0/24" --availability-zone "${AZS[$i]}" \
    --map-public-ip-on-launch \
    --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=${PREFIX}-public-${AZS[$i]}},{Key=${TAG_KEY},Value=${TAG_VALUE}}]" \
    --query 'Subnet.SubnetId' --output text)")
  echo "subnet ${AZS[$i]}: ${SUBNET_IDS[$i]}"
done

# ------------------------------------------------------------------- IGW
echo
echo "== Creating internet gateway and public routing =="
IGW_ID="$(aws ec2 create-internet-gateway \
  --tag-specifications "ResourceType=internet-gateway,Tags=[{Key=Name,Value=${PREFIX}-igw},{Key=${TAG_KEY},Value=${TAG_VALUE}}]" \
  --query 'InternetGateway.InternetGatewayId' --output text)"
aws ec2 attach-internet-gateway --vpc-id "$VPC_ID" --internet-gateway-id "$IGW_ID"

RT_ID="$(aws ec2 create-route-table --vpc-id "$VPC_ID" \
  --tag-specifications "ResourceType=route-table,Tags=[{Key=Name,Value=${PREFIX}-public},{Key=${TAG_KEY},Value=${TAG_VALUE}}]" \
  --query 'RouteTable.RouteTableId' --output text)"
aws ec2 create-route --route-table-id "$RT_ID" --destination-cidr-block 0.0.0.0/0 \
  --gateway-id "$IGW_ID"
for s in "${SUBNET_IDS[@]}"; do
  aws ec2 associate-route-table --route-table-id "$RT_ID" --subnet-id "$s"
done
echo "igw: $IGW_ID   route table: $RT_ID"

# ------------------------------------------------------- ALB security group
echo
echo "== Creating ALB security group =="
SG_ID="$(aws ec2 create-security-group --group-name "${PREFIX}-alb-sg" \
  --description "SOA-C03 lab 02 ALB ingress" --vpc-id "$VPC_ID" \
  --tag-specifications "ResourceType=security-group,Tags=[{Key=Name,Value=${PREFIX}-alb-sg},{Key=${TAG_KEY},Value=${TAG_VALUE}}]" \
  --query 'GroupId' --output text)"
aws ec2 authorize-security-group-ingress --group-id "$SG_ID" \
  --ip-permissions "IpProtocol=tcp,FromPort=${ALB_PORT},ToPort=${ALB_PORT},IpRanges=[{CidrIp=0.0.0.0/0}]"
echo "sg: $SG_ID"

# ------------------------------------------------------------------- ALB
echo
echo "== Creating application load balancer =="
ALB_ARN="$(aws elbv2 create-load-balancer \
  --name "${PREFIX}-alb" \
  --subnets "${SUBNET_IDS[0]}" "${SUBNET_IDS[1]}" \
  --security-groups "$SG_ID" \
  --scheme internet-facing \
  --type application \
  --ip-address-type ipv4 \
  --tag-specifications "ResourceType=load-balancer,Tags=[{Key=${TAG_KEY},Value=${TAG_VALUE}}]" \
  --query 'LoadBalancers[0].LoadBalancerArn' --output text)"
ALB_DNS="$(aws elbv2 describe-load-balancers --load-balancer-arns "$ALB_ARN" \
  --query 'LoadBalancers[0].DNSName' --output text)"
echo "alb: $ALB_ARN"
echo "dns: $ALB_DNS"

# ------------------------------------------------------- ALB access logs
# Access logs go to S3, not CloudWatch Logs. The access_logs.s3.* attributes
# are the documented CLI path; CloudWatch Logs delivery for ALB logs is a
# newer vended-logs feature and is not used here on purpose.
# Bucket policy uses the logdelivery.elasticloadbalancing.amazonaws.com
# service principal, so no per-Region ELB account ID is needed.
# Verified against the official ALB access logging page, 2026-10-03.
echo
echo "== Creating access-log bucket and enabling access logs =="
ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
LOG_BUCKET="soa-c03-lab02-alb-logs-${ACCOUNT_ID}-${RANDOM}"
POLICY_FILE="$(mktemp)"

cat > "$POLICY_FILE" <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": "logdelivery.elasticloadbalancing.amazonaws.com" },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${LOG_BUCKET}/AWSLogs/${ACCOUNT_ID}/*",
      "Condition": {
        "ArnLike": {
          "aws:SourceArn": "arn:aws:elasticloadbalancing:${AWS_REGION}:${ACCOUNT_ID}:loadbalancer/*"
        }
      }
    }
  ]
}
POLICY

if [[ "$AWS_REGION" == "us-east-1" ]]; then
  aws s3api create-bucket --bucket "$LOG_BUCKET" >/dev/null
else
  aws s3api create-bucket --bucket "$LOG_BUCKET" \
    --create-bucket-configuration "LocationConstraint=${AWS_REGION}" >/dev/null
fi
aws s3api put-bucket-policy --bucket "$LOG_BUCKET" --policy "file://${POLICY_FILE}"
rm -f "$POLICY_FILE"

aws elbv2 modify-load-balancer-attributes --load-balancer-arn "$ALB_ARN" \
  --attributes "Key=access_logs.s3.enabled,Value=true" "Key=access_logs.s3.bucket,Value=${LOG_BUCKET}"
echo "bucket: $LOG_BUCKET (verify ELBAccessLogTestFile appears, then real logs follow)"

# ------------------------------------------------------- target group
# The target is an address inside the VPC CIDR with nothing listening on it.
# It is registered and permanently unhealthy, which is the point of the lab.
echo
echo "== Creating target group with an unreachable IP target =="
TG_ARN="$(aws elbv2 create-target-group \
  --name "${PREFIX}-tg" \
  --protocol HTTP --port "$ALB_PORT" --vpc-id "$VPC_ID" \
  --target-type ip \
  --health-check-protocol HTTP \
  --health-check-port "$ALB_PORT" \
  --health-check-path /healthz \
  --health-check-matcher 200 \
  --healthy-threshold-count 2 --unhealthy-threshold-count 2 \
  --health-check-interval-seconds 15 \
  --health-check-timeout-seconds 5 \
  --tag-keys "${TAG_KEY}" --tag-values "${TAG_VALUE}" \
  --query 'TargetGroups[0].TargetGroupArn' --output text)"

UNREACHABLE_IP="${VPC_CIDR%/*}.1.10"
aws elbv2 register-targets --target-group-arn "$TG_ARN" \
  --targets "Id=${UNREACHABLE_IP},Port=${ALB_PORT}"
echo "target group: $TG_ARN"
echo "registered target: $UNREACHABLE_IP (nothing is listening there)"

# --------------------------------------------------------------- listener
# With no healthy targets the ALB serves this fixed 503, so
# HTTPCode_ELB_5XX_Count rises and HTTPCode_Target_5XX_Count stays at zero.
echo
echo "== Creating listener with a fixed-response 503 default action =="
aws elbv2 create-listener --load-balancer-arn "$ALB_ARN" \
  --protocol HTTP --port "$ALB_PORT" \
  --default-actions 'Type=fixed-response,FixedResponseConfig={StatusCode=503,Message=lab02-no-healthy-targets,ContentType=text/plain}' \
  --query 'Listeners[0].ListenerArn' --output text >/dev/null

# -------------------------------------------------------------- flow logs
echo
echo "== Enabling VPC Flow Logs to CloudWatch Logs =="
LOG_GROUP="/aws/vpc/flowlogs/${PREFIX}"
aws logs create-log-group --log-group-name "$LOG_GROUP" 2>/dev/null || true
aws logs put-retention-policy --log-group-name "$LOG_GROUP" --retention-in-days 1

FLOW_ROLE="${PREFIX}-flow-logs"
aws iam create-role --role-name "$FLOW_ROLE" \
  --assume-role-policy-document '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"vpc-flow-logs.amazonaws.com"},"Action":"sts:AssumeRole"}]}' \
  --tags "Key=${TAG_KEY},Value=${TAG_VALUE}" \
  --description "SOA-C03 lab 02 VPC Flow Logs delivery" >/dev/null
aws iam put-role-policy --role-name "$FLOW_ROLE" --policy-name flow-logs-write \
  --policy-document "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":[\"logs:CreateLogStream\",\"logs:PutLogEvents\",\"logs:DescribeLogGroups\",\"logs:DescribeLogStreams\"],\"Resource\":\"*\"}]}" >/dev/null
FLOW_ROLE_ARN="$(aws iam get-role --role-name "$FLOW_ROLE" --query 'Role.Arn' --output text)"

aws ec2 create-flow-logs \
  --resource-type VPC --resource-id "$VPC_ID" \
  --traffic-type ALL \
  --log-destination-type cloud-watch-logs \
  --log-destination "arn:aws:logs:${AWS_REGION}:${ACCOUNT_ID}:log-group:${LOG_GROUP}" \
  --log-format '${version} ${vpc-id} ${flow-direction} ${srcaddr} ${dstaddr} ${srcport} ${dstport} ${protocol} ${packets} ${bytes} ${action}' \
  --iam-role-arn "$FLOW_ROLE_ARN" \
  --tag-specifications "ResourceType=flow-log,Tags=[{Key=${TAG_KEY},Value=${TAG_VALUE}}]" \
  --query 'FlowLogIds[0]' --output text >/dev/null
echo "log group: $LOG_GROUP   flow log enabled on the VPC (traffic ALL)"

cat <<EOF

== Created. Next steps from the lab README ==
  Step 2  ./cli/02-probe.sh          generate traffic and read four evidence sources
  Step 3  optional NACL return-path break (predict before you check)

  The 503 you get is generated by the ALB. Prove it:
    ALB     HTTPCode_ELB_5XX_Count    -> rises
    Target  HTTPCode_Target_5XX_Count -> stays 0

  URL: http://$ALB_DNS/

  Teardown: ./cli/99-teardown.sh
EOF
