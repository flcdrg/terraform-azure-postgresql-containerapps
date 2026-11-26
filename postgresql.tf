
# begin-snippet: PostgreSQLServer
resource "azurerm_postgresql_flexible_server" "server" {
  name                              = "psql-postgresql-apps-australiaeast"
  resource_group_name               = data.azurerm_resource_group.rg.name
  location                          = data.azurerm_resource_group.rg.location
  version                           = "18" # Was originally 11 to demonstrate upgrading, but that will now trigger paid extended support
  delegated_subnet_id               = azurerm_subnet.example.id
  private_dns_zone_id               = azurerm_private_dns_zone.example.id
  public_network_access_enabled     = false
  administrator_login               = "psqladmin"
  administrator_password_wo         = ephemeral.random_password.postgresql_password.result
  administrator_password_wo_version = 1
  zone                              = "1"

  storage_mb   = 32768
  storage_tier = "P4"

  # https://azure.microsoft.com/en-us/pricing/details/postgresql/flexible-server/
  # Burstable are being retired
  # The name of the SKU, follows the tier + name pattern
  sku_name   = "GP_Standard_D2s_v3"
  depends_on = [azurerm_private_dns_zone_virtual_network_link.example]
}
# end-snippet

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
