resource "random_string" "storage_suffix" {
  length  = 11
  upper   = false
  special = false
}

resource "azurerm_storage_account" "storage" {
  name                     = "stdirectus${random_string.storage_suffix.result}aue"
  resource_group_name      = data.azurerm_resource_group.rg.name
  location                 = data.azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  public_network_access_enabled = false
}

resource "azurerm_storage_account_network_rules" "storage" {
  storage_account_id         = azurerm_storage_account.storage.id
  default_action             = "Deny"
  virtual_network_subnet_ids = [azurerm_subnet.storage.id]
}
