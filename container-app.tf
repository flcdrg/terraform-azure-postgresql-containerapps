resource "azurerm_container_app_environment" "example" {
  name                       = "cae-postgresql-apps-australiaeast"
  location                   = data.azurerm_resource_group.rg.location
  resource_group_name        = data.azurerm_resource_group.rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
  logs_destination           = "log-analytics"
  public_network_access      = "Enabled"
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app
# https://directus.io/docs/tutorials/self-hosting/deploy-directus-to-azure-web-apps
# https://directus.io/docs/configuration/files#azure-azure

resource "azurerm_container_app" "directus" {
  name                         = "ca-directus-australiaeast"
  container_app_environment_id = azurerm_container_app_environment.example.id
  resource_group_name          = data.azurerm_resource_group.rg.name
  revision_mode                = "Single"

  template {
    container {
      name   = "directus"
      image  = "directus/directus:10.9"
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name  = "ADMIN_EMAIL"
        value = "admin@example.com"
      }

      env {
        name  = "ADMIN_PASSWORD"
        value = azurerm_key_vault_secret.directus_admin_password.name
      }

      env {
        name  = "DB_CLIENT"
        value = "pg"
      }

      env {
        name  = "DB_HOST"
        value = azurerm_postgresql_flexible_server.server.fqdn
      }

      env {
        name  = "DB_PORT"
        value = "5432"
      }

      env {
        name  = "DB_DATABASE"
        value = azurerm_postgresql_flexible_server_database.db.name
      }

      env {
        name  = "DB_USER"
        value = azurerm_postgresql_flexible_server.server.administrator_login
      }

      env {
        name  = "DB_PASSWORD"
        value = azurerm_key_vault_secret.db_password.name
      }

      env {
        name  = "DB_SSL"
        value = "true"
      }

      env {
        name  = "STORAGE_LOCATIONS"
        value = "azure"
      }

      env {
        name  = "STORAGE_AZURE_DRIVER"
        value = "azure"
      }

      env {
        name  = "STORAGE_AZURE_ACCOUNT_NAME"
        value = azurerm_storage_account.storage.name
      }

      env {
        name  = "STORAGE_AZURE_ACCOUNT_KEY"
        value = azurerm_storage_account.storage.primary_access_key
      }

      env {
        name  = "STORAGE_AZURE_CONTAINER_NAME"
        value = azurerm_storage_container.directus_files.name
      }

      env {
        name  = "STORAGE_AZURE_ENDPOINT"
        value = azurerm_storage_account.storage.primary_blob_endpoint
      }

      env {
        name  = "SECRET"
        value = azurerm_key_vault_secret.directus_secret.name
      }

      # KEY is deprecated as of v10.11.0, but required for earlier versions
      env {
        name  = "KEY"
        value = "fbc842eb-9633-418d-8382-04a5f4cddf79"
      }
    }
  }
  ingress {
    target_port                = 8055
    allow_insecure_connections = false
    external_enabled           = true
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}
