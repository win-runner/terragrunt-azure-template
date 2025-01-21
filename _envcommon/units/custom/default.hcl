# This is the CUSTOM default component. Can be used as a default for any module.
# If your module has more default inputs, it needs its own common .hcl file
locals {
  utils       = read_terragrunt_config(find_in_parent_folders("utils.hcl")).locals
  parsed_path = regex(local.utils.parsed_path_regex, get_terragrunt_dir())
  units       = local.utils.units
  this        = local.units.custom[local.parsed_path.type]
}

terraform {
  source = "${local.this.source}?ref=${local.this.version}"
}

inputs = {
  name     = "${local.this.prefix}-${local.parsed_path.envname}-${local.parsed_path.identifier}-${local.parsed_path.location}-${local.parsed_path.count}"
  location = local.parsed_path.location

  tags = {
    Environment = local.parsed_path.envname
  }
}
