variable zones {
  type = list(number)
  default = [ 1, 2, 3 ]
}

resource "random_string" "fqdn" {
  count = length(var.zones)

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

resource "azurerm_network_security_group" "vmgroup" {
  name                = "vmss-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = var.application_port
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "vmgroup" {
  subnet_id                 = azurerm_subnet.internal.id
  network_security_group_id = azurerm_network_security_group.vmgroup.id
}

resource "azurerm_public_ip" "vmgroup" {
  count = length(var.zones)

  name                         = join("-", [ var.name, "pip", count.index ])
  location                     = var.location
  resource_group_name          = var.resource_group_name
  allocation_method            = "Static"
  domain_name_label            = random_string.fqdn[count.index].result
  sku                          = "Standard"
   zones = [ var.zones[count.index] ]
}

resource "azurerm_lb" "vmgroup" {
  count = length(var.zones)
  sku                          = "Standard"

 name                = join("-", [ var.name, "lb", count.index ])
 location            = var.location
 resource_group_name = var.resource_group_name

 frontend_ip_configuration {
   name                 = join("-", [ var.name, "fe" ])
   public_ip_address_id = azurerm_public_ip.vmgroup[ count.index ].id
 }
}

resource "azurerm_lb_backend_address_pool" "vmgroup" {
  count = length(var.zones)

 resource_group_name = var.resource_group_name
 loadbalancer_id     = azurerm_lb.vmgroup[ count.index ].id
 name                = join("-", ["BackEndAddressPool", count.index])
}

resource "azurerm_lb_probe" "vmgroup" {
  count = length(var.zones)

 resource_group_name = var.resource_group_name
 loadbalancer_id     = azurerm_lb.vmgroup[count.index].id
 name                = "http-probe"
 port                = var.application_port
}

resource "azurerm_lb_rule" "lbnatrule" {
  count = length(var.zones)

   resource_group_name            = var.resource_group_name
   loadbalancer_id                = azurerm_lb.vmgroup[count.index].id
   name                           = "http"
   protocol                       = "Tcp"
   frontend_port                  = var.application_port
   backend_port                   = var.application_port
   backend_address_pool_id        = azurerm_lb_backend_address_pool.vmgroup[count.index].id
   frontend_ip_configuration_name = join("-", [ var.name, "fe"])
   probe_id                       = azurerm_lb_probe.vmgroup[count.index].id
}

resource "azurerm_user_assigned_identity" "vmgroup" {
  count = length(var.zones)

  resource_group_name = var.resource_group_name
  location            = var.location
  name                = join("-", ["id", random_string.fqdn[count.index].result])
}

resource "azurerm_linux_virtual_machine_scale_set" "vmgroup" {
  count = length(var.zones)
  zones = [ var.zones[count.index] ]

  name                            = join("-", [ var.name, "vmss", count.index ])
  resource_group_name             = var.resource_group_name
  location                        = var.location
  sku                             = "Standard_DS1_v2"
  instances                       = var.instances
  disable_password_authentication = false
  admin_username                  = var.admin_user
  admin_password                  = var.admin_password
  computer_name_prefix            = "vmlab"
  custom_data                     = base64encode(file("modules/vmgroup/web.conf"))
 
  identity {
    type          = "SystemAssigned, UserAssigned"
    identity_ids  = [azurerm_user_assigned_identity.vmgroup[count.index].id]
  }

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
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.vmgroup[count.index].id]
      primary = true
    }
  }
}

resource "azurerm_virtual_machine_scale_set_extension" "vmgroup" {
  count                        = length(var.zones)
  name                         = join("-", ["vmss-health-check", count.index])
  virtual_machine_scale_set_id = azurerm_linux_virtual_machine_scale_set.vmgroup[count.index].id
  publisher                    = "Microsoft.ManagedServices"
  type                         = "ApplicationHealthLinux"
  type_handler_version         = "1.0"
  settings = jsonencode({
    "port" = 80,
    "protocol" = "http",
    "requestPath" = "/"
  })
}