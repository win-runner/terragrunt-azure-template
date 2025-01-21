locals {
  parsed_path_regex    = ".*/(?P<root>[^/]+)/(?P<envname>[^/]+)/(?P<location>[^/]+)/(?P<count>[^/]+)/(?P<type>[^/]+)/(?P<identifier>[^/]+)$"
  parsed_path_regex_l2 = ".*/(?P<root>[^/]+)/(?P<envname>[^/]+)/(?P<location>[^/]+)/(?P<count>[^/]+)/(?P<parent_type>[^/]+)/(?P<parent_identifier>[^/]+)/(?P<type>[^/]+)/(?P<identifier>[^/]+)$"
  tags                 = read_terragrunt_config("tags.hcl").locals
  units                = read_terragrunt_config("units.hcl").locals
  versions = {
    terraform = ">= 1.10.0"
    providers = {
      azurerm = "~> 4.3"
      azapi   = "~> 2.2"
    }
  }
}
