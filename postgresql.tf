resource "azurerm_postgresql_flexible_server" "server" {
  name                              = "psql-postgresql-apps-australiaeast"
  resource_group_name               = data.azurerm_resource_group.rg.name
  location                          = data.azurerm_resource_group.rg.location
  version                           = "11" # "17"
  delegated_subnet_id               = azurerm_subnet.example.id
  private_dns_zone_id               = azurerm_private_dns_zone.example.id
  public_network_access_enabled     = false
  administrator_login               = "psqladmin"
  administrator_password_wo         = ephemeral.random_password.postgresql_password.result
  administrator_password_wo_version = 1
  zone                              = "1"

  storage_mb   = 32768
  storage_tier = "P4"

  sku_name   = "B_Standard_B1ms"
  depends_on = [azurerm_private_dns_zone_virtual_network_link.example]
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
