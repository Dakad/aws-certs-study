output "topic_arn" {
  description = "ARN of the notification topic. The alarm's alarm_actions and ok_actions both point at it, which is why importing the topic before the alarm makes the post-import plan a no-op."
  value       = aws_sns_topic.this.arn
}

output "topic_name" {
  description = "Name of the notification topic."
  value       = aws_sns_topic.this.name
}

output "alarm_name" {
  description = "Name of the CloudWatch alarm."
  value       = aws_cloudwatch_metric_alarm.this.alarm_name
}

output "alarm_arn" {
  description = "ARN of the CloudWatch alarm. Redact the account ID before recording this anywhere."
  value       = aws_cloudwatch_metric_alarm.this.arn
}

output "alarm_threshold" {
  description = "Threshold currently declared in configuration. Compare this against the plan's after value after Step 7 to see which side of the drift you decided to keep."
  value       = var.alarm_threshold
}
