# prod stack — same module, same backend, different key, different inputs.
#
# The only structural difference from dev is the directory it lives in.
# path_relative_to_include() turns that into a distinct state key, so the two
# stacks land on
#   envs/dev/terraform.tfstate
#   envs/prod/terraform.tfstate
# in one shared bucket. One backend, two isolated states — which is the whole
# reason to keep them in separate directories rather than passing an
# environment variable to one shared stack.

include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../tofu/modules/notification"
}

inputs = {
  name_prefix = "soa-c03-lab06-tg-prod"
  environment = "prod"

  # prod is not. This is the kind of difference that is per-environment *policy*
  # rather than per-environment *infrastructure*, which is the argument for
  # having environment values live in the stack and not in the module.
  alarm_threshold = 70
}
