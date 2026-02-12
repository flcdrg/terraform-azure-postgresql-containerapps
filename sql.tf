variable "mssql_azuread_administrator_object_id" {
  type        = string
  description = "Object ID of AAD User that will be the Azure SQL Administrator"
  nullable    = false
}

variable "mssql_administrator_login" {
  type = string
}

variable "mssql_administrator_password" {
  type      = string
  sensitive = true
}

resource "azurerm_mssql_server" "mssql" {
  name                         = "sql-tfdemo-australiaeast"
  resource_group_name          = data.azurerm_resource_group.rg.name
  location                     = data.azurerm_resource_group.rg.location
  minimum_tls_version          = "1.2"
  version                      = "12.0"
  administrator_login          = var.mssql_administrator_login
  administrator_login_password = var.mssql_administrator_password

  identity {
    type = "SystemAssigned"
  }

  azuread_administrator {
    login_username = "AzureAD Admin"
    object_id      = var.mssql_azuread_administrator_object_id
  }
}

resource "azurerm_mssql_database" "database" {
  name           = "sqldb-tfdemo-australiaeast"
  server_id      = azurerm_mssql_server.mssql.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  sku_name       = "Basic"
  max_size_gb    = 1
  zone_redundant = false
}

resource "azurerm_mssql_firewall_rule" "azure_services" {
  name             = "AllowAllWindowsAzureIps"
  server_id        = azurerm_mssql_server.mssql.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}