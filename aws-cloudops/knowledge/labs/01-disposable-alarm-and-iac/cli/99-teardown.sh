#!/usr/bin/env bash
# Lab 01 teardown — remove every resource this lab created, then prove it.
#
# Order matters: delete the alarm first so nothing fires while the instance
# is disappearing, then the instance (which terminates its EBS volumes),
# then the topic, then the IAM objects.
#
# The script prints "clean" only when every verification query is empty.
# Treat anything else as unfinished cleanup.
#
set -euo pipefail

TAG_KEY="soa-c03-lab01"
TAG_VALUE="true"
PREFIX="soa-c03-lab01"

echo "== 1. Deleting CloudWatch alarms =="
ALARMS="$(aws cloudwatch describe-alarms \
  --alarm-name-prefix "$PREFIX" \
  --query 'MetricAlarms[].AlarmName' --output text)"
if [[ "$ALARMS" == "None" || -z "$ALARMS" ]]; then
  echo "  none found"
else
  for a in $ALARMS; do
    echo "  deleting $a"
    aws cloudwatch delete-alarms --alarm-names "$a"
  done
fi

echo
echo "== 2. Terminating instances =="
INSTANCES="$(aws ec2 describe-instances \
  --filters "Name=tag:${TAG_KEY},Values=${TAG_VALUE}" \
  --filters "Name=instance-state-name,Values=pending,running,stopping,stopped" \
  --query 'Reservations[].Instances[].InstanceId' --output text)"
if [[ "$INSTANCES" == "None" || -z "$INSTANCES" ]]; then
  echo "  none found"
else
  for i in $INSTANCES; do
    echo "  terminating $i"
    aws ec2 terminate-instances --instance-ids "$i" >/dev/null
  done
  echo "  waiting for termination"
  aws ec2 wait instance-terminated --instance-ids $INSTANCES
fi

echo
echo "== 3. Deleting SNS topics =="
while read -r arn; do
  [[ -z "$arn" ]] && continue
  echo "  deleting $arn"
  aws sns delete-topic --topic-arn "$arn" >/dev/null
done < <(aws sns list-topics --query 'Topics[?ends_with(TopicArn, `'"${PREFIX}"'-alarms`)].TopicArn' --output text)

echo
echo "== 4. Deleting IAM instance profile and role =="
PROFILES="$(aws iam list-instance-profiles \
  --query "InstanceProfiles[?starts_with(InstanceProfileName, '${PREFIX}')].InstanceProfileName" --output text)"
for p in $PROFILES; do
  [[ -z "$p" ]] && continue
  for r in $(aws iam get-instance-profile --instance-profile-name "$p" \
      --query 'InstanceProfile.Roles[].RoleName' --output text); do
    [[ -z "$r" ]] && continue
    echo "  removing $r from $p"
    aws iam remove-role-from-instance-profile --instance-profile-name "$p" --role-name "$r" || true
  done
  echo "  deleting instance profile $p"
  aws iam delete-instance-profile --instance-profile-name "$p"
done

ROLES="$(aws iam list-roles \
  --query "Roles[?starts_with(RoleName, '${PREFIX}')].RoleName" --output text)"
for r in $ROLES; do
  [[ -z "$r" ]] && continue
  echo "  detaching managed policies from $r"
  for pn in $(aws iam list-attached-role-policies --role-name "$r" \
      --query 'AttachedPolicies[].PolicyName' --output text); do
    [[ -z "$pn" ]] && continue
    aws iam detach-role-policy --role-name "$r" --policy-arn "arn:aws:iam::aws:policy/$pn" || true
  done
  echo "  deleting role $r"
  aws iam delete-role --role-name "$r"
done

echo
echo "== 5. Verification =="
FAILED=0

check() {
  local label="$1" result="$2"
  if [[ "$result" == "None" || -z "$result" ]]; then
    printf '  %-22s empty  OK\n' "$label"
  else
    printf '  %-22s %s  STILL PRESENT\n' "$label" "$result"
    FAILED=1
  fi
}

check "instances" "$(aws ec2 describe-instances \
  --filters "Name=tag:${TAG_KEY},Values=${TAG_VALUE}" \
  --query 'Reservations[].Instances[].InstanceId' --output text)"
check "volumes" "$(aws ec2 describe-volumes \
  --filters "Name=tag:${TAG_KEY},Values=${TAG_VALUE}" \
  --query 'Volumes[].VolumeId' --output text)"
check "alarms" "$(aws cloudwatch describe-alarms --alarm-name-prefix "$PREFIX" \
  --query 'MetricAlarms[].AlarmName' --output text)"
check "iam roles" "$(aws iam list-roles \
  --query "Roles[?starts_with(RoleName, '${PREFIX}')].RoleName" --output text)"
check "instance profiles" "$(aws iam list-instance-profiles \
  --query "InstanceProfiles[?starts_with(InstanceProfileName, '${PREFIX}')].InstanceProfileName" --output text)"

echo
if [[ "$FAILED" -eq 0 ]]; then
  echo "clean — no soa-c03-lab01 resources remain."
  echo "Confirm in the Console too, then record the output in EVIDENCE.md."
else
  echo "INCOMPLETE — something still carries the tag or prefix above."
  echo "Resolve it before calling the lab finished; check for cost-bearing resources."
fi
exit "$FAILED"
