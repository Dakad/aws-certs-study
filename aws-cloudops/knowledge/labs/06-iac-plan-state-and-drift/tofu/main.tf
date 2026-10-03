# The whole configuration is one call into the shared module. That is not
# minimalism for its own sake: it is the same module the Terragrunt stacks in
# ../../terragrunt compose, so anything you learn about reviewing this plan
# transfers directly to reviewing a per-environment stack.

module "notification" {
  source = "./modules/notification"

  name_prefix = var.name_prefix
  environment = var.environment

  metric_name = var.metric_name

  alarm_description        = var.alarm_description
  alarm_threshold          = var.alarm_threshold
  alarm_period             = var.alarm_period
  alarm_evaluation_periods = var.alarm_evaluation_periods

  tags = var.tags
}
