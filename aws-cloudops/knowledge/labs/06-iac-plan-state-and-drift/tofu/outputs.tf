output "topic_arn" {
  description = "ARN of the managed notification topic. Redact the account ID before recording it anywhere."
  value       = module.notification.topic_arn
}

output "alarm_name" {
  description = "Name of the managed CloudWatch alarm."
  value       = module.notification.alarm_name
}

output "alarm_arn" {
  description = "ARN of the managed CloudWatch alarm. Redact the account ID before recording it anywhere."
  value       = module.notification.alarm_arn
}

output "alarm_threshold" {
  description = "Threshold declared in configuration. Compare against the plan's after-threshold after Step 7."
  value       = module.notification.alarm_threshold
}

output "expected_state_addresses" {
  description = "The resource addresses a fully imported state should contain. Run `tofu state list` and diff against this; a difference means state and configuration disagree about what is managed."
  value = [
    "module.notification.aws_cloudwatch_metric_alarm.this",
    "module.notification.aws_sns_topic.this",
  ]
}

output "state_key_reminder" {
  description = "The backend key was supplied at init time, not here. Echoed back as a reminder that the key is a runtime input, never a committed literal."
  value       = "supplied via -backend-config at tofu init; see cli/01-create-state-backend.sh"
}
