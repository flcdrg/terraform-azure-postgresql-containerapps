resource "azurerm_log_analytics_workspace" "la" {
  name                = "log-tfdemo-australiaeast"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  sku                 = "PerGB2018"
}

resource "azurerm_application_insights" "appinsights" {
  name                = "appi-tfdemo-australiaeast"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.la.id
}
