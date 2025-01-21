locals {
  # Self-developed and customized avm modules
  custom = {
    resourcegroup = {
      prefix  = "rg"
      source  = "git::https://github.com/win-runner/terraform-azapi-resource-group.git"
      version = "v0.1.0"
      mock_outputs = {
        name         = "rg-mock-001"
        rescource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-mock-001"
      }
    }

  }

  # Azure verified modules
  avm = {}
}
