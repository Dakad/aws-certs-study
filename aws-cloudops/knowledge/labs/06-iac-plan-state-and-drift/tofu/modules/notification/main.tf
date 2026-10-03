# Shared service module for the SOA-C03 lab 06 notification target.
#
# This module is the reusable unit that both the root configuration in the
# parent directory and the Terragrunt stacks in ../../terragrunt compose. It
# deliberately contains NO provider block and NO backend block: those belong to
# whoever calls the module, because a shared module must be reusable from any
# account, region, or backend.
#
# Every value here must match what cli/02-create-cli-managed-alarm.sh creates
# with the CLI, or the first plan after `tofu import` will not be a no-op.
# That parity is the whole point of Step 5.

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

locals {
  # Kept in locals so the CLI script and this module cannot drift apart
  # silently: both derive the alarm name from name_prefix the same way.
  topic_name = "${var.name_prefix}-alarms"
  alarm_name = "${var.name_prefix}-cpu-synthetic"

  # A custom namespace that nothing ever publishes to. The alarm therefore
  # stays in a non-breaching state for the whole lab and costs nothing.
  # Publishing metric data to make it fire is Lab 01's job, not this lab's.
  namespace = "SOA-C03/Lab06"
}

resource "aws_sns_topic" "this" {
  name = local.topic_name
  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "this" {
  alarm_name        = local.alarm_name
  alarm_description = var.alarm_description

  namespace   = local.namespace
  metric_name = var.metric_name
  statistic   = "Average"
  period      = var.alarm_period

  evaluation_periods = var.alarm_evaluation_periods
  threshold          = var.alarm_threshold

  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"

  # The single dimension that distinguishes one lab target from another.
  dimensions = {
    Environment = var.environment
  }

  alarm_actions = [aws_sns_topic.this.arn]
  ok_actions    = [aws_sns_topic.this.arn]

  tags = var.tags
}
