locals {
  utils       = read_terragrunt_config(find_in_parent_folders("utils.hcl")).locals
  parsed_path = regex(local.utils.parsed_path_regex_l2, get_terragrunt_dir())
  units       = local.utils.units
  this        = local.units.custom.subnet
}

terraform {
  source = "${local.units.custom.virtualnetwork.source}//modules/subnet?ref=${local.units.custom.virtualnetwork.version}"
}

inputs = {
  name = "${local.this.prefix}-${local.parsed_path.envname}-${local.parsed_path.identifier}-${local.parsed_path.location}-${local.parsed_path.count}"
  # ...
}
