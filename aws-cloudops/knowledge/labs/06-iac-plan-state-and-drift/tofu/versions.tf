# Root configuration for the SOA-C03 lab 06 plan/state/drift exercise.
#
# The backend block is intentionally EMPTY. Bucket, key, region, and locking
# are supplied at init time with -backend-config so that no account-specific
# identifier is ever committed to this repository:
#
#   tofu init -reconfigure \
#     -backend-config="bucket=<printed by cli/01>" \
#     -backend-config="key=<printed by cli/01>" \
#     -backend-config="region=<region>" \
#     -backend-config="use_lockfile=true"
#
# That is called partial backend configuration, and the OpenTofu documentation
# recommends it: authentication and location details stay in the environment and
# in -backend-config, while the block only declares which backend type is in use.

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {}
}

provider "aws" {
  region = var.region

  # No default_tags here on purpose. Lab 01 relies on default_tags, which works
  # for a from-scratch apply. This lab imports resources the CLI created, and a
  # default tag that the live resource does not carry shows up as drift in the
  # first plan. Tags are therefore declared explicitly, on the resources, where
  # the parity requirement with the CLI is visible.
}
