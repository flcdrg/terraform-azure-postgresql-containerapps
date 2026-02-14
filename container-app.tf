resource "azurerm_container_app_environment" "example" {
  name                               = "cae-postgresql-apps-australiaeast"
  location                           = data.azurerm_resource_group.rg.location
  resource_group_name                = data.azurerm_resource_group.rg.name
  log_analytics_workspace_id         = azurerm_log_analytics_workspace.example.id
  logs_destination                   = "log-analytics"
  public_network_access              = "Enabled"
  infrastructure_subnet_id           = azurerm_subnet.containerapp.id
  infrastructure_resource_group_name = "rg-postgresql-apps-infra-australiaeast" # Set this explicitly, otherwise Azure will create a new resource group with a random name and you will need to tell Terraform to ignore it

  workload_profile {
    name                  = "Consumption"
    workload_profile_type = "Consumption"
    minimum_count         = 0
    maximum_count         = 0
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app
resource "azurerm_container_app" "aspnetapp" {
  name                         = "ca-postgresql-apps-australiaeast"
  container_app_environment_id = azurerm_container_app_environment.example.id
  resource_group_name          = data.azurerm_resource_group.rg.name
  revision_mode                = "Single"
  workload_profile_name        = "Consumption"

  identity {
    identity_ids = [azurerm_user_assigned_identity.aspnetapp.id]
    type         = "UserAssigned"
  }

  secret {
    name                = "MySecret"
    key_vault_secret_id = azurerm_key_vault_secret.first.versionless_id
    identity            = azurerm_user_assigned_identity.aspnetapp.id
  }

  template {
    container {
      name   = "examplecontainerapp"
      image  = "mcr.microsoft.com/dotnet/samples:aspnetapp-chiseled"
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name        = "MY_ENV"
        secret_name = "MySecret"
      }
    }
  }

  ingress {
    transport                  = "http"
    target_port                = 8080
    allow_insecure_connections = false
    external_enabled           = true
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}

# https://directus.io/docs/tutorials/self-hosting/deploy-directus-to-azure-web-apps
# https://directus.io/docs/configuration/files#azure-azure

# resource "azurerm_container_app" "directus" {
#   name                         = "ca-postgresql-apps-directus-australiaeast"
#   container_app_environment_id = azurerm_container_app_environment.example.id
#   resource_group_name          = data.azurerm_resource_group.rg.name
#   revision_mode                = "Single"
#   workload_profile_name        = "Consumption"

#   template {
#     container {
#       name   = "directus"
#       image  = "directus/directus:10.9"
#       cpu    = var.container_app.cpu
#       memory = var.container_app.memory

#       env {
#         name  = "ADMIN_EMAIL"
#         value = var.directus.admin_email
#       }

#       env {
#         name  = "ADMIN_PASSWORD"
#         value = azurerm_key_vault_secret.directus_password.value
#       }

#       env {
#         name  = "DB_CLIENT"
#         value = "pg"
#       }

#       env {
#         name  = "DB_HOST"
#         value = "${azurerm_postgresql_flexible_server.db.name}.postgres.database.azure.com"
#       }

#       env {
#         name  = "DB_PORT"
#         value = "5432"
#       }

#       env {
#         name  = "DB_DATABASE"
#         value = azurerm_postgresql_flexible_server_database.db.name
#       }

#       env {
#         name  = "DB_USER"
#         value = azurerm_postgresql_flexible_server.db.administrator_login
#       }

#       env {
#         name  = "DB_PASSWORD"
#         value = azurerm_key_vault_secret.db_password.value
#       }

#       env {
#         name  = "DB_SSL"
#         value = "true"
#       }

#       env {
#         name  = "STORAGE_LOCATIONS"
#         value = "azure"
#       }

#       env {
#         name  = "STORAGE_AZURE_DRIVER"
#         value = "azure"
#       }

#       env {
#         name  = "STORAGE_AZURE_ACCOUNT_NAME"
#         value = azurerm_storage_account.storage.name
#       }

#       env {
#         name  = "STORAGE_AZURE_ACCOUNT_KEY"
#         value = azurerm_storage_account.storage.primary_access_key
#       }

#       env {
#         name  = "STORAGE_AZURE_CONTAINER_NAME"
#         value = azurerm_storage_container.directus_files.name
#       }

#       env {
#         name  = "STORAGE_AZURE_ENDPOINT"
#         value = "https://${azurerm_storage_account.storage.name}.blob.core.windows.net"
#       }

#       env {
#         name  = "KEY"
#         value = var.directus.key
#       }

#       env {
#         name  = "SECRET"
#         value = var.directus.secret
#       }
#     }
#   }
#   ingress {
#     target_port                = 8055
#     allow_insecure_connections = false
#     external_enabled           = true
#     traffic_weight {
#       percentage      = 100
#       latest_revision = true
#     }
#   }
# }
