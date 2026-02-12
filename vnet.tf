resource "azurerm_virtual_network" "example" {
  name                = "vnet-postgresql-apps-australiaeast"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}
