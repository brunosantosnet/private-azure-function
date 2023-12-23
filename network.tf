resource "azurerm_virtual_network" "this" {
  name                = "private-azure-function"
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.10.0.0/16"]
  location            = azurerm_resource_group.this.location

  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
  }

  depends_on = [
    azurerm_resource_group.this
  ]
}

resource "azurerm_subnet" "vm" {
  name                 = "private-azure-function-vm"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.10.1.0/24"]

  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
  }

  depends_on = [
    azurerm_resource_group.this,
    azurerm_virtual_network.this
  ]
}

resource "azurerm_subnet" "app" {
  name                 = "private-azure-function-app"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.10.2.0/24"]

  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
  }

  depends_on = [
    azurerm_resource_group.this,
    azurerm_virtual_network.this
  ]
}

resource "azurerm_private_dns_zone" "this" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = azurerm_resource_group.this.name

  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
  }

  depends_on = [
    azurerm_resource_group.this
  ]
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  name                  = "private-azure-function-app"
  resource_group_name   = azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.this.name
  virtual_network_id    = azurerm_virtual_network.this.id
}

resource "azurerm_private_endpoint" "this" {
  name                = "private-azure-function"
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = azurerm_subnet.app.id
  location            = azurerm_resource_group.this.location

  private_service_connection {
    name                           = "private-azure-function"
    private_connection_resource_id = azurerm_linux_function_app.this.id
    is_manual_connection           = false
    subresource_names              = ["sites"]
  }

  private_dns_zone_group {
    name = "private-azure-function"
    private_dns_zone_ids = [
      azurerm_private_dns_zone.this.id
    ]
  }

  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
  }

  depends_on = [
    azurerm_resource_group.this,
    azurerm_subnet.app,
    azurerm_linux_function_app.this,
    azurerm_private_dns_zone.this
  ]
}

resource "azurerm_public_ip" "this" {
  name                = "private-azure-function"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method = "Dynamic"

  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
  }

  depends_on = [
    azurerm_resource_group.this
  ]
}

resource "azurerm_network_interface" "this" {
  name                = "private-azure-function"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vm.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.this.id
  }

  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
  }

  depends_on = [
    azurerm_resource_group.this,
    azurerm_subnet.vm,
    azurerm_public_ip.this
  ]
}

resource "azurerm_network_security_group" "this" {
  name                = "private-azure-function"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
  }

  depends_on = [
    azurerm_resource_group.this
  ]
}

resource "azurerm_network_interface_security_group_association" "this" {
  network_interface_id      = azurerm_network_interface.this.id
  network_security_group_id = azurerm_network_security_group.this.id

  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
  }

  depends_on = [
    azurerm_network_interface.this,
    azurerm_network_security_group.this
  ]
}
