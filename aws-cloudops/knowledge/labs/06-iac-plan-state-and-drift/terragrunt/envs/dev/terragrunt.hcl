# dev stack — composes the shared notification module with dev inputs.
#
# `source` points at the reusable module, not at a copy of it. Terragrunt copies
# the module into .terragrunt-cache/ and runs OpenTofu there, so nothing in
# ../../../tofu/modules/notification is modified by a plan or an apply. That
# indirection is the whole reason Terragrunt exists: one module, N stacks, no
# copy-pasted configuration to drift apart.

include "root" {
  # Named explicitly so this keeps working if the root file is ever renamed.
  # Terragrunt warns against calling the root file `terragrunt.hcl`, so this
  # stack points at `root.hcl` rather than relying on the default search.
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../tofu/modules/notification"
}

inputs = {
  # Distinct per stack on purpose. If dev and prod shared a name_prefix they
  # would be fighting over the same CloudWatch alarm name, and the second stack
  # to apply would fail. Per-environment naming is a state problem before it is
  # a naming problem.
  name_prefix = "soa-c03-lab06-tg-dev"
  environment = "dev"

  # dev is allowed to be wrong cheaply.
  alarm_threshold = 90
}
