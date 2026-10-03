# Inputs for the shared notification module.
#
# Every variable is typed. Terragrunt passes inputs as TF_VAR_ environment
# variables, which are untyped strings, so an untyped `list` or `map` input
# would arrive as a string and fail in the module. Types are not optional
# decoration here.

variable "name_prefix" {
  description = "Prefix for the topic and alarm names. Must match the prefix cli/02-create-cli-managed-alarm.sh was run with, or the post-import plan will not be a no-op."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{2,40}$", var.name_prefix))
    error_message = "name_prefix must be 3-41 characters of lowercase letters, digits, or hyphens, starting with a letter or digit."
  }
}

variable "environment" {
  description = "Value of the alarm's Environment dimension. Distinguishes lab targets that share a namespace and metric name."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,20}$", var.environment))
    error_message = "environment must be 2-21 characters of lowercase letters, digits, or hyphens."
  }
}

variable "metric_name" {
  description = "Custom metric name inside the lab namespace. Nothing publishes to it."
  type        = string
  default     = "SyntheticLoad"
}

variable "alarm_description" {
  description = "Human-readable description stored on the alarm."
  type        = string
  default     = "SOA-C03 lab 06 plan/state/drift target"
}

variable "alarm_threshold" {
  description = "Percentage at or above which the datapoint breaches. Step 7 drifts this out-of-band and then chooses which side is wrong."
  type        = number
  default     = 80

  validation {
    condition     = var.alarm_threshold > 0 && var.alarm_threshold <= 100
    error_message = "alarm_threshold is a CPU percentage and must be greater than 0 and at most 100."
  }
}

variable "alarm_period" {
  description = "Datapoint period in seconds."
  type        = number
  default     = 300

  validation {
    condition     = var.alarm_period >= 60 && var.alarm_period <= 3600
    error_message = "alarm_period must be between 60 and 3600 seconds."
  }
}

variable "alarm_evaluation_periods" {
  description = "N in M-of-N: the size of the evaluation window."
  type        = number
  default     = 2

  validation {
    condition     = var.alarm_evaluation_periods >= 1
    error_message = "alarm_evaluation_periods must be at least 1."
  }
}

variable "tags" {
  description = "Tags applied to both resources. cli/02 must create the same tags, because a tag that exists in AWS but not in configuration is drift like any other attribute."
  type        = map(string)
  default     = {}
}
