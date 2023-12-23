resource "azurerm_resource_group" "this" {
  name     = "private-azure-function"
  location = "East US"
}

resource "azurerm_storage_account" "this" {
  name                     = "privateazurefunction"
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  depends_on = [
    azurerm_resource_group.this
  ]
}

resource "azurerm_service_plan" "this" {
  name                = "private-azure-function"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  os_type             = "Linux"
  sku_name            = "EP1"

  depends_on = [
    azurerm_resource_group.this
  ]
}
