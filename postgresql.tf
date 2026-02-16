resource "azurerm_postgresql_flexible_server" "server" {
  name                   = "psql-postgresql-apps-australiaeast"
  resource_group_name    = data.azurerm_resource_group.rg.name
  location               = data.azurerm_resource_group.rg.location
  version                = "11" # "17"
  administrator_login    = "psqladmin"
  administrator_password = random_password.postgresql_password.result
  zone                   = "1"

  storage_mb   = 32768
  storage_tier = "P4"

  sku_name = "B_Standard_B1ms"
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_azure_services" {
  name             = "AzureServices"
  server_id        = azurerm_postgresql_flexible_server.server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# It would be better if we could lock this down to just the Container App IP,
# But the problem is that the Container App IP can change dynamically.
# Introducing a VNET may be a better option down the track
resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_all" {
  name             = "AllowAll"
  server_id        = azurerm_postgresql_flexible_server.server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}

resource "azurerm_postgresql_flexible_server_database" "db" {
  name      = "directus"
  server_id = azurerm_postgresql_flexible_server.server.id
  charset   = "UTF8"
  collation = "en_US.utf8"

  # Uncomment this for real (non-demo) deployments
  # lifecycle {
  #   prevent_destroy = true
  # }
}
