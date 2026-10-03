variable "region" {
  description = "Region to create resources in. Must match the session's region."
  type        = string
  default     = "us-east-1"
}

variable "name_prefix" {
  description = "Name prefix for every resource this configuration manages."
  type        = string
  default     = "soa-c03-lab01-tofu"
}

variable "subnet_id" {
  description = "Subnet to launch into. Use a public subnet with a 0.0.0.0/0 route to an internet gateway so Session Manager works without a VPC endpoint."
  type        = string
}

variable "instance_type" {
  description = "Instance size. t4g/t4a are Graviton and require ami_arch arm64."
  type        = string
  default     = "t4g.micro"
}

variable "ami_arch" {
  description = "Amazon Linux 2023 architecture. Use x86_64 for t3/t3a/m5/c5."
  type        = string
  default     = "arm64"
}

variable "alarm_threshold" {
  description = "CPU percentage at or above which the datapoint breaches."
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

variable "alarm_datapoints_to_alarm" {
  description = "M in M-of-N: how many breaching datapoints are required to alarm."
  type        = number
  default     = 2
}

variable "sns_email" {
  description = "Optional email endpoint. The subscription stays pending until the recipient confirms it."
  type        = string
  default     = null
  nullable    = true
}
