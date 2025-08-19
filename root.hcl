
locals {
  tenant_id = "" # TODO: Set the tenant_id

  backend_vars  = read_terragrunt_config(find_in_parent_folders("backend.hcl"))
  backend_rg    = local.backend_vars.locals.storage_account_rg_name
  backend_sa    = local.backend_vars.locals.storage_account_name
  backend_cont  = local.backend_vars.locals.storage_container_name
  backend_subId = local.backend_vars.locals.subscription_id

  env_vars        = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
  subscription_id = local.env_vars.subscription_id != null ? local.env_vars.subscription_id : null
}

remote_state {
  backend                         = "azurerm"
  disable_dependency_optimization = true
  config = {
    subscription_id      = local.backend_subId
    key                  = "terragrunt/${path_relative_to_include()}/terraform.tfstate"
    resource_group_name  = local.backend_rg
    storage_account_name = local.backend_sa
    container_name       = local.backend_cont
    use_azuread_auth     = true
  }
  generate = {
    path      = "remote_state.tf"
    if_exists = "overwrite_terragrunt"
  }
}

terraform {

  extra_arguments "retry_lock" {
    commands = get_terraform_commands_that_need_locking()
    arguments = [
      "-lock-timeout=120m",
    ]
  }

  extra_arguments "disable_input" {
    commands = get_terraform_commands_that_need_input()

    arguments = [
      "-input=false",
    ]
  }
}

# default if not exists in module
generate "versions" {
  path      = "terraform.tf"
  if_exists = "skip"
  contents  = <<EOF
terraform {
  required_version = "${read_terragrunt_config(find_in_parent_folders("utils.hcl")).locals.versions.terraform}"
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "${read_terragrunt_config(find_in_parent_folders("utils.hcl")).locals.versions.providers.azurerm}"
    }
    azapi = {
      source = "Azure/azapi"
      version = "${read_terragrunt_config(find_in_parent_folders("utils.hcl")).locals.versions.providers.azapi}"
    }
  }  
}
  EOF
}

generate "azurerm_provider" {
  path      = "azurerm_provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "azurerm" {
  features {}
  storage_use_azuread = true
  resource_provider_registrations = "none"
  subscription_id = "${local.subscription_id != null ? local.subscription_id : null}"
  tenant_id = "${local.tenant_id}"
  use_msi = false
  use_cli = true
}
  EOF
}

retryable_errors = [
  "(?s).*Error installing provider.*tcp.*connection reset by peer.*",
  "(?s).*ssh_exchange_identification.*Connection closed by remote host.*",
  "(?s).*timeout.*",
  "(?s).*Could not read from remote repository.*",
  "(?s).*kex_exchange_identification.*Connection reset by peer.*",
  "(?s).*does not exist in MSAL token cache.*"
]

# Defines what happens when you `terragrunt catalog`. Can be used to scaffold stacks.
#catalog {
#  urls = [
#    "https://github.com/gruntwork-io/terragrunt-infrastructure-modules-example",
#    "https://github.com/gruntwork-io/terraform-aws-utilities",
#    "https://github.com/gruntwork-io/terraform-kubernetes-namespace"
#  ]
#}


# ---------------------------------------------------------------------------------------------------------------------
# GLOBAL PARAMETERS
# These variables apply to all configurations in this subfolder. These are automatically merged into the child
# `terragrunt.hcl` config via the include block.
# ---------------------------------------------------------------------------------------------------------------------

inputs = {
  enable_telemetry = false
  tags             = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals.tags
}
