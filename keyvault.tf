resource "random_string" "random_kv_suffix" {
  length  = 5
  special = false
  upper   = false
}

resource "azurerm_key_vault" "kv" {
  name                          = "kv-pgsql-apps-${random_string.random_kv_suffix.result}-aue"
  resource_group_name           = data.azurerm_resource_group.rg.name
  location                      = data.azurerm_resource_group.rg.location
  sku_name                      = "standard"
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  rbac_authorization_enabled    = true
  public_network_access_enabled = true
  purge_protection_enabled      = false # Only for demo purposes, consider enabling this for production environments

  network_acls {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    virtual_network_subnet_ids = [azurerm_subnet.kv.id]
  }
}

# role assignments - https://learn.microsoft.com/en-us/azure/key-vault/general/rbac-guide?tabs=azure-cli
resource "azurerm_role_assignment" "kv_contributor" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "kv_secrets_user_aspnetapp" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.aspnetapp.principal_id
}

resource "azurerm_key_vault_secret" "first" {
  name         = "FirstSecret"
  value        = "This is a secret value"
  key_vault_id = azurerm_key_vault.kv.id
}
