terraform {
  backend "azurerm" {
    resource_group_name   = "terraform-on-azure"
    storage_account_name  = "tstate"
    container_name        = "tstatevmss"
    key                   = "<access_key>"
  }
}

provider "azurerm" {
    features {}
    version = "2.17"

    subscription_id = var.subscription_id
    tenant_id = var.tenant_id
    client_id = var.client_id
    client_secret = var.client_secret
}

variable location {
    type = string
    default = "East US"
}

variable resource_group_name {
    type = string
    default = "complex-vmss"
}

resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "example" {
  name                = "example-network"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]
}

module "group1" {
  source                = "./modules/vmgroup"
  name                  = "group1"
  vnet_name             = azurerm_virtual_network.example.name
  location              = azurerm_resource_group.example.location
  resource_group_name   = azurerm_resource_group.example.name
  instances             = 2
  subnet_address_prefix = "10.0.0.0/24"
}

module "group2" {
  source                = "./modules/vmgroup"
  name                  = "group2"
  vnet_name             = azurerm_virtual_network.example.name
  location              = azurerm_resource_group.example.location
  resource_group_name   = azurerm_resource_group.example.name
  instances             = 2
  subnet_address_prefix = "10.0.1.0/24"
}
