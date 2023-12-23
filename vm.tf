resource "random_password" "this" {
  length           = 16
  special          = true
  override_special = "!#$"
}

resource "azurerm_linux_virtual_machine" "this" {
  name                = "private-azure-function"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  size                = "Standard_DS1_v2"
  admin_username      = "usr-private-azure-function"
  network_interface_ids = [
    azurerm_network_interface.this.id,
  ]

  admin_ssh_key {
    username   = "usr-private-azure-function"
    public_key = file("./private-azure-function.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  depends_on = [
    azurerm_resource_group.this,
    azurerm_network_interface.this
  ]
}
