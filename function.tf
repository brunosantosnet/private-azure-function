resource "azurerm_linux_function_app" "this" {
  name                          = "private-azure-function"
  location                      = azurerm_resource_group.this.location
  resource_group_name           = azurerm_resource_group.this.name
  service_plan_id               = azurerm_service_plan.this.id
  storage_account_name          = azurerm_storage_account.this.name
  storage_account_access_key    = azurerm_storage_account.this.primary_access_key
  public_network_access_enabled = false

  site_config {
    application_stack {
      python_version = "3.8"
    }

  }

  depends_on = [
    azurerm_resource_group.this,
    azurerm_service_plan.this,
    azurerm_storage_account.this
  ]
}
