resource "azurerm_postgresql_flexible_server" "server" {
  name                          = "psql-postgresql-apps-australiaeast"
  resource_group_name           = data.azurerm_resource_group.rg.name
  location                      = data.azurerm_resource_group.rg.location
  version                       = "17"
  delegated_subnet_id           = azurerm_subnet.example.id
  private_dns_zone_id           = azurerm_private_dns_zone.example.id
  public_network_access_enabled = false
  administrator_login           = "psqladmin"
  administrator_password        = "H@Sh1CoR3!"
  zone                          = "1"

  storage_mb   = 32768
  storage_tier = "P4"

  sku_name   = "B_Standard_B1ms"
  depends_on = [azurerm_private_dns_zone_virtual_network_link.example]
}
