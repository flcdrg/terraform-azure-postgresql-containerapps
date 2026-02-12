resource "azurerm_container_app_environment" "example" {
  name                       = "cae-postgresql-apps-australiaeast"
  location                   = data.azurerm_resource_group.rg.location
  resource_group_name        = data.azurerm_resource_group.rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
  logs_destination           = "log-analytics"
  public_network_access      = "Enabled"
  infrastructure_subnet_id   = azurerm_subnet.containerapp.id
}

resource "azurerm_container_app" "example" {
  name                         = "ca-postgresql-apps-australiaeast"
  container_app_environment_id = azurerm_container_app_environment.example.id
  resource_group_name          = data.azurerm_resource_group.rg.name
  revision_mode                = "Single"

  template {
    container {
      name   = "examplecontainerapp"
      image  = "mcr.microsoft.com/k8se/quickstart:latest"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }
}
