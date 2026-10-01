resource "azurerm_private_dns_zone" "example" {
  name                = "psql-postgresql-apps-australiaeast.private.postgres.database.azure.com"
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "example" {
  name                = "psql-postgresql-apps-australiaeast"
  private_dns_zone_id = azurerm_private_dns_zone.example.id
  virtual_network_id  = azurerm_virtual_network.example.id
  depends_on          = [azurerm_subnet.example]
}
