resource "random_string" "fqdn" {
  length  = 6
  special = false
  upper   = false
  number  = false
}

resource "azurerm_subnet" "internal" {
  name                 = join("-", [ var.name, "subnet" ])
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = [ var.subnet_address_prefix ]
}

resource "azurerm_public_ip" "vmgroup" {
 name                         = join("-", [ var.name, "pip" ])
 location                     = var.location
 resource_group_name          = var.resource_group_name
 allocation_method            = "Static"
 domain_name_label            = random_string.fqdn.result
}

resource "azurerm_lb" "vmgroup" {
 name                = join("-", [ var.name, "lb" ])
 location            = var.location
 resource_group_name = var.resource_group_name

 frontend_ip_configuration {
   name                 = join("-", [ var.name, "fe" ])
   public_ip_address_id = azurerm_public_ip.vmgroup.id
 }
}

resource "azurerm_lb_backend_address_pool" "vmgroup" {
 resource_group_name = var.resource_group_name
 loadbalancer_id     = azurerm_lb.vmgroup.id
 name                = "BackEndAddressPool"
}

resource "azurerm_lb_probe" "vmgroup" {
 resource_group_name = var.resource_group_name
 loadbalancer_id     = azurerm_lb.vmgroup.id
 name                = "ssh-running-probe"
 port                = var.application_port
}

resource "azurerm_lb_rule" "lbnatrule" {
   resource_group_name            = var.resource_group_name
   loadbalancer_id                = azurerm_lb.vmgroup.id
   name                           = "http"
   protocol                       = "Tcp"
   frontend_port                  = var.application_port
   backend_port                   = var.application_port
   backend_address_pool_id        = azurerm_lb_backend_address_pool.vmgroup.id
   frontend_ip_configuration_name = join("-", [ var.name, "fe"])
   probe_id                       = azurerm_lb_probe.vmgroup.id
}

resource "azurerm_linux_virtual_machine_scale_set" "vmgroup" {
  name                            = join("-", [ var.name, "vmss" ])
  resource_group_name             = var.resource_group_name
  location                        = var.location
  sku                             = "Standard_DS1_v2"
  instances                       = var.instances
  disable_password_authentication = false
  admin_username                  = var.admin_user
  admin_password                  = var.admin_password
  computer_name_prefix            = "vmlab"
  custom_data                     = base64encode(file("modules/vmgroup/web.conf"))
 
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "terraformnetworkprofile"
    primary = true

    ip_configuration {
      name                                   = "IPConfiguration"
      subnet_id                              = azurerm_subnet.internal.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.vmgroup.id]
      primary = true
    }
  }
}