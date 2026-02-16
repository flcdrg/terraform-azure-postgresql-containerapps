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
}

resource "azurerm_storage_container" "directus_files" {
  name                  = "directus-files"
  storage_account_id    = azurerm_storage_account.storage.id
  container_access_type = "private"
}