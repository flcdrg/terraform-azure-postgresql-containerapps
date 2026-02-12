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
      image  = "mcr.microsoft.com/dotnet/samples:aspnetapp-chiseled"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }

  ingress {
    transport                  = "http"
    target_port                = 443
    exposed_port = 8080
    allow_insecure_connections = false
    external_enabled           = true
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}
