variable "region" {
  description = "Region to operate in. Must be the same region the backend bucket and lock table live in."
  type        = string
  default     = "us-east-1"

  validation {
    condition     = can(regex("^[a-z]{2}(-gov)?-[a-z]+-[0-9]$", var.region))
    error_message = "region must look like us-east-1, eu-west-1, or us-gov-west-1."
  }
}

variable "name_prefix" {
  description = "Prefix for the managed topic and alarm. cli/02 must have been run with the same prefix, because these names already exist in AWS before OpenTofu knows anything about them."
  type        = string
  default     = "soa-c03-lab06"
}

variable "environment" {
  description = "Value of the alarm's Environment dimension. Must match the LAB_ENV cli/02 was run with."
  type        = string
  default     = "study"
}

variable "metric_name" {
  description = "Custom metric name inside the lab namespace."
  type        = string
  default     = "SyntheticLoad"
}

variable "alarm_description" {
  description = "Description stored on the alarm. Must match the CLI value or the post-import plan will not be a no-op."
  type        = string
  default     = "SOA-C03 lab 06 plan/state/drift target"
}

variable "alarm_threshold" {
  description = "Breach threshold. Step 7 drifts this out-of-band, then you decide whether configuration or reality is authoritative."
  type        = number
  default     = 80
}

variable "alarm_period" {
  description = "Datapoint period in seconds."
  type        = number
  default     = 300
}

variable "alarm_evaluation_periods" {
  description = "N in M-of-N: the size of the evaluation window."
  type        = number
  default     = 2
}

variable "tags" {
  description = "Tags applied to both managed resources. cli/02 creates the same tags so that Step 5's plan is a no-op."
  type        = map(string)
  default     = {}
}
