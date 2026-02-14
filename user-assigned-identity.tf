resource "azurerm_user_assigned_identity" "aspnetapp" {
  name                = "uai-postgresql-apps-australiaeast"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
}

resource "azurerm_user_assigned_identity" "directus" {
  name                = "uai-directus-australiaeast"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
}
