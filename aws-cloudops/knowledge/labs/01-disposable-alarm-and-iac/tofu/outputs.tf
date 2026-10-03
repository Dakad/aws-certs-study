output "instance_id" {
  description = "Disposable instance managed by this configuration."
  value       = aws_instance.this.id
}

output "private_ip" {
  description = "Primary private address."
  value       = aws_instance.this.private_ip
}

output "alarm_name" {
  description = "Name of the CloudWatch alarm."
  value       = aws_cloudwatch_metric_alarm.cpu_high.alarm_name
}

output "alarm_arn" {
  description = "ARN of the CloudWatch alarm. Redact the account ID before recording it anywhere."
  value       = aws_cloudwatch_metric_alarm.cpu_high.arn
}

output "sns_topic_arn" {
  description = "ARN of the notification topic. Redact the account ID before recording it anywhere."
  value       = aws_sns_topic.this.arn
}

output "session_command" {
  description = "Command to open Session Manager on the instance."
  value       = "aws ssm start-session --target ${aws_instance.this.id}"
}

output "state_managed_resources" {
  description = "What OpenTofu believes it manages. Compare against `tofu state list` after import to see state's role."
  value = [
    aws_iam_role.ssm.id,
    aws_iam_role_policy_attachment.ssm_core.id,
    aws_iam_instance_profile.this.id,
    aws_instance.this.id,
    aws_sns_topic.this.id,
    aws_cloudwatch_metric_alarm.cpu_high.id,
  ]
}
