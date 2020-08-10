module "database" {
  source  = "Azure/database/azurerm"
  version = "1.1.0"
  # insert the 4 required variables here
  resource_group_name = var.resource_group_name
  location            = var.location
  db_name             = var.name
  sql_admin_username  = "mradministrator"
  sql_password        = "P@ssw0rd12345!"
}
