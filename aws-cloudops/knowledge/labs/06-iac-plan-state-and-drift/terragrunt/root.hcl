# Root Terragrunt configuration for lab 06 (optional).
#
# This file is INCLUDED by every stack under envs/. It is where the shared
# concerns live: which backend the stacks use, and what every stack gets as
# input. A stack under envs/ contains only what is genuinely per-environment.
#
# Terragrunt is a wrapper around OpenTofu, not a replacement for it. It does two
# things for you that OpenTofu deliberately does not:
#
#   * it composes a root module into many stacks, one per environment, each with
#     its own inputs and its own state key, and
#   * it generates the boilerplate a root module would otherwise have to carry —
#     here, the backend block and the provider block.
#
# What it does NOT replace:
#   * plan review. `terragrunt plan` still produces a plan you must read.
#   * state discipline. Each stack still has its own state file, still needs
#     locking, and still drifts. Terragrunt does not detect or reconcile drift.
#   * import. `terragrunt import` wraps `tofu import`; it does not decide whether
#     importing is the right response to drift.
#   * the AWS provider, the backend, or the lock table. Those still have to
#     exist, and something other than this configuration has to own them.
#
# Required environment (cli/01 prints the first two):
#   AWS_PROFILE, LAB_STATE_BUCKET
# Optional environment:
#   LAB_LOCK_TABLE   adds DynamoDB locking on top of S3-native locking
#   AWS_REGION       default us-east-1

locals {
  region       = get_env("AWS_REGION", "us-east-1")
  state_bucket = get_env("LAB_STATE_BUCKET", "")
  lock_table   = get_env("LAB_LOCK_TABLE", "")

  # Every input must be a typed variable in the module, because Terragrunt
  # passes inputs as TF_VAR_ environment variables and OpenTofu will otherwise
  # hand the module a string where it expected a list or a map.
  common_tags = {
    soa-c03-lab06 = "true"
  }
}

# disable_init = true is load-bearing. Without it Terragrunt is willing to create
# the S3 bucket and the DynamoDB table for you if they are missing. This lab
# creates them with the CLI so the learner can see every setting, and the lab's
# teardown has to be able to find them by name. Terragrunt must not also be
# creating things nothing will clean up.
remote_state {
  backend     = "s3"
  disable_init = true

  config = {
    bucket       = local.state_bucket
    key          = "${path_relative_to_include()}/terraform.tfstate"
    region       = local.region
    encrypt      = true
    use_lockfile = true

    # Uncomment to lock with DynamoDB as well. With both set, OpenTofu must
    # acquire both locks before it proceeds, which is the vendor-documented
    # migration path off DynamoDB locking. cli/04-hold-state-lock.sh
    # LAB_LOCK_MODE=dynamodb plants the item this would contend with.
    # dynamodb_table = local.lock_table
  }
}

# Written into the stack's copy of the module before OpenTofu runs. The module
# itself has no backend block, which is correct: a reusable module must not
# decide where its caller's state lives.
generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"

  contents = <<-EOF
    terraform {
      backend "s3" {}
    }
  EOF
}

# The shared module has no provider block either, so one is generated here. This
# is the single most useful thing to put in a root config: every stack gets an
# identical provider, and there is exactly one place to change it.
#
# A production root config would also pin allowed_account_ids here, so a run with
# the wrong credentials fails at plan time instead of creating a second copy of
# everything in an account you did not mean. This lab leaves it out because the
# account ID must not be committed to this repository, and get_env cannot fail
# loudly on a missing value. Add it, sourced from your CI secret store, when you
# use this pattern for real.
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"

  contents = <<-EOF
    provider "aws" {
      region = "${local.region}"
    }
  EOF
}

inputs = {
  region = local.region
  tags   = local.common_tags
}
