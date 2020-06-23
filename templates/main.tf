terraform {
  backend "azurerm" {
    resource_group_name   = "terraform-on-azure"
    storage_account_name  = "tstate177"
    container_name        = "tstate"
    key                   = "<access_key>"
  }
}

variable "environment" {
  type = string
  default = "none"
}

variable "location" {
  type = string
  default = "eastus"
}

variable "resource_group_name" {
  type = string
}

variable "address_space" {
  type = list(string)
}

provider "azurerm" {
    version = "~>1.32.0"
}

module "network" {
  source              = "Azure/network/azurerm"
  resource_group_name = var.resource_group_name
  vnet_name           = join("-", ["terraform", "vnet"])
  address_space       = var.address_space
  subnet_prefixes     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  subnet_names        = ["subnet1", "subnet2", "subnet3"]

  tags = {
    environment = var.environment
    costcenter  = "it"
  }
}

module "database" {
  source = "./modules/database"
  name = "terraform-sql"
  location = var.location
  resource_group_name = var.resource_group_name
}