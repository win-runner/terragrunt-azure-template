generate "main.generated.tf" {
  path      = "main.generated.tf"
  if_exists = "overwrite"
  contents  = <<EOF
variable "key_vault_resource_id" {
  type = string
}

variable "secret_names" {
  type    = list(string)
  default = []
}

data "azurerm_key_vault_secret" "main" {
  for_each     = length(var.secret_names) > 0 ? toset(var.secret_names) : toset([])
  name         = each.key
  key_vault_id = var.key_vault_resource_id
}

output "secrets" {
  value     = { for key, secret in data.azurerm_key_vault_secret.main : key => secret.value }
  sensitive = true
}

EOF
}
