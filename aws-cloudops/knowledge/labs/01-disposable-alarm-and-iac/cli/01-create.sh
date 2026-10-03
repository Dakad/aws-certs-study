#!/usr/bin/env bash
# Lab 01, Step 1 — create the disposable study target with the AWS CLI.
#
# Creates: one SSM instance role, one EC2 instance, one SNS topic,
#          one optional SNS email subscription, one CloudWatch alarm.
#
# Review this file before running it. Nothing here touches a shared or
# production account, and every resource is tagged soa-c03-lab01=true so
# teardown can be verified by tag instead of by remembered ID.
#
# Required environment:
#   AWS_PROFILE   authorized playground or personal-account profile
# Optional environment:
#   AWS_REGION              default us-east-1
#   INSTANCE_TYPE           default t4g.micro  (Graviton -> needs arm64)
#   AMI_ARCH                default arm64      (x86_64 for t3/t3a/m5/c5)
#   SNS_EMAIL               if set, adds a pending email subscription
#   LAB_SUBNET_ID           if set, uses this subnet instead of the default
#
set -euo pipefail

AWS_REGION="${AWS_REGION:-us-east-1}"
INSTANCE_TYPE="${INSTANCE_TYPE:-t4g.micro}"
AMI_ARCH="${AMI_ARCH:-arm64}"
TAG_KEY="soa-c03-lab01"
TAG_VALUE="true"
NAME="soa-c03-lab01-disposable"

if [[ -z "${AWS_PROFILE:-}" ]]; then
  echo "ERROR: set AWS_PROFILE to the authorized profile before running." >&2
  exit 1
fi

echo "== Step 0: identity and region =="
aws sts get-caller-identity
echo "region: $AWS_REGION"
echo
echo "Record the account ID from the output above in your own notes, not in this repo."

# ---------------------------------------------------------------- subnet
if [[ -z "${LAB_SUBNET_ID:-}" ]]; then
  echo "== Resolving a subnet from the default VPC =="
  # A public subnet with a 0.0.0.0/0 route to an IGW is required so the
  # instance can reach the SSM endpoints without a VPC endpoint. If your
  # default subnets are private, pass LAB_SUBNET_ID explicitly and expect
  # to add an ssmmessages endpoint instead.
  SUBNET_ID="$(aws ec2 describe-subnets \
    --filters Name=default-for-az \
    --query 'Subnets[0].SubnetId' --output text)"
  VPC_ID="$(aws ec2 describe-subnets --subnet-ids "$SUBNET_ID" \
    --query 'Subnets[0].VpcId' --output text)"
else
  SUBNET_ID="$LAB_SUBNET_ID"
  VPC_ID="$(aws ec2 describe-subnets --subnet-ids "$SUBNET_ID" \
    --query 'Subnets[0].VpcId' --output text)"
fi
echo "vpc: $VPC_ID  subnet: $SUBNET_ID"

# ------------------------------------------------------------------- AMI
# Resolve through the SSM public parameter instead of hardcoding an AMI ID,
# so the script does not silently rot when Amazon Linux is rebuilt.
SSM_PARAM="/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-${AMI_ARCH}"
echo
echo "== Resolving AMI from $SSM_PARAM =="
AMI_ID="$(aws ssm get-parameter --name "$SSM_PARAM" \
  --query 'Parameter.Value' --output text)"
echo "ami: $AMI_ID ($AMI_ARCH)"

# ----------------------------------------------------------- instance role
# Session Manager access needs an instance profile carrying the SSM core
# policy. This is the AWS-native alternative to an inbound SSH rule and a
# key pair, and the role is itself Domain 3 material.
echo
echo "== Creating SSM instance role =="
ROLE_NAME="${NAME}-role"
aws iam create-role \
  --role-name "$ROLE_NAME" \
  --assume-role-policy-document '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"ec2.amazonaws.com"},"Action":"sts:AssumeRole"}]}' \
  --tags "Key=${TAG_KEY},Value=${TAG_VALUE}" \
  --description "SOA-C03 lab 01 disposable instance profile" >/dev/null

aws iam attach-role-policy \
  --role-name "$ROLE_NAME" \
  --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore >/dev/null

aws iam create-instance-profile \
  --instance-profile-name "${ROLE_NAME}-profile" \
  --tags "Key=${TAG_KEY},Value=${TAG_VALUE}" >/dev/null
aws iam add-role-to-instance-profile \
  --instance-profile-name "${ROLE_NAME}-profile" \
  --role-name "$ROLE_NAME" >/dev/null
echo "role: $ROLE_NAME"

# ------------------------------------------------------------------- EC2
echo
echo "== Launching instance =="
INSTANCE_ID="$(aws ec2 run-instances \
  --image-id "$AMI_ID" \
  --instance-type "$INSTANCE_TYPE" \
  --subnet-id "$SUBNET_ID" \
  --associate-public-ip-address \
  --iam-instance-profile "Name=${ROLE_NAME}-profile" \
  --metadata-options HttpTokens=required,HttpEndpoint=enabled \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${NAME}},{Key=${TAG_KEY},Value=${TAG_VALUE}}]" \
  --block-device-mappings '[{"DeviceName":"/dev/xvda","Ebs":{"VolumeSize":1,"VolumeType":"gp3","Encrypted":true,"DeleteOnTermination":true}}]' \
  --query 'Instances[0].InstanceId' --output text)"

echo "instance: $INSTANCE_ID"
echo "waiting for running + SSM registration (up to 5 minutes)..."
aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"
aws ec2 wait instance-status-ok --instance-ids "$INSTANCE_ID"

PUBLIC_IP="$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" \
  --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)"
echo "public ip: $PUBLIC_IP"

# ------------------------------------------------------------------- SNS
echo
echo "== Creating SNS topic =="
TOPIC_ARN="$(aws sns create-topic --name "${NAME}-alarms" \
  --tags "Key=${TAG_KEY},Value=${TAG_VALUE}" \
  --query 'TopicArn' --output text)"
echo "topic: $TOPIC_ARN"

if [[ -n "${SNS_EMAIL:-}" ]]; then
  aws sns subscribe --topic-arn "$TOPIC_ARN" --protocol email \
    --notification-endpoint "$SNS_EMAIL" >/dev/null
  cat <<EOF

  The subscription is PENDING until you confirm it.
  An email from AWS with subject "Confirm subscription" has been sent to
  ${SNS_EMAIL}. Until you click Confirm, the alarm action is authorized but
  delivers nothing. That gap is a real, common failure mode: the alarm
  transitions to ALARM, SNS has a subscription, and no human is told.
EOF
fi

# ----------------------------------------------------------------- alarm
# Deliberately mirrors the read-only study alarm so the two are comparable:
# 5-minute Average, >= 80, 2 of 2 datapoints, missing data not breaching.
echo
echo "== Creating CloudWatch alarm =="
ALARM_NAME="${NAME}-cpu-high"
aws cloudwatch put-metric-alarm \
  --alarm-name "$ALARM_NAME" \
  --alarm-description "SOA-C03 lab 01 disposable CPU alarm" \
  --namespace AWS/EC2 \
  --metric-name CPUUtilization \
  --dimensions Name=InstanceId,Value="$INSTANCE_ID" \
  --statistic Average \
  --period 300 \
  --evaluation-periods 2 \
  --datapoints-to-alarm 2 \
  --threshold 80 \
  --comparison-operator GreaterThanOrEqualToThreshold \
  --treat-missing-data notBreaching \
  --alarm-actions "$TOPIC_ARN" \
  --tags "Key=${TAG_KEY},Value=${TAG_VALUE}" >/dev/null
echo "alarm: $ALARM_NAME"

cat <<EOF

== Created. Next steps from the lab README ==
  Step 2  inspect in the Console, then take screenshots
  Step 2b open a session and drive CPU to prove the alarm fires:
           aws ssm start-session --target "$INSTANCE_ID"
           timeout 700 sh -c 'while :; do :; done'
  Step 3  tofu init && tofu plan   (read the plan, do not apply yet)

  Session access:
    aws ssm start-session --target "$INSTANCE_ID"

  Teardown:
    ./cli/99-teardown.sh
EOF
