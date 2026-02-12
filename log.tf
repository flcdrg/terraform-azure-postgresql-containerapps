resource "azurerm_log_analytics_workspace" "example" {
  name                = "log-postgresql-apps-australiaeast"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}
