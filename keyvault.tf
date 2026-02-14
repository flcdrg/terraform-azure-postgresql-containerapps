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
    default_action             = "Allow" # Normally you would want to set this to "Deny" and only allow specific IPs or subnets, but for demo purposes we will allow all and rely on RBAC for access control. If using Deny, then you will probably need to use self-hosted Azure DevOps agents and grant them access to the VNET
    bypass                     = "AzureServices"
    virtual_network_subnet_ids = [azurerm_subnet.kv.id]
    ip_rules                   = []
  }
}

# role assignments - https://learn.microsoft.com/en-us/azure/key-vault/general/rbac-guide?tabs=azure-cli
resource "azurerm_role_assignment" "kv_administrator_sp" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "kv_administrator_david" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = "9f9b3ec2-42af-456e-be88-d1b22d86e96b"

}

resource "azurerm_role_assignment" "kv_secrets_user_aspnetapp" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.aspnetapp.principal_id
}

resource "azurerm_role_assignment" "kv_secrets_user_directus" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.directus.principal_id
}

# Allow time for role assignment to propagate before trying to create secrets, otherwise we may get a "Forbidden" error
resource "time_sleep" "wait_for_role_assignment" {
  depends_on = [
    azurerm_role_assignment.kv_administrator_sp,
    azurerm_role_assignment.kv_administrator_david,
    azurerm_role_assignment.kv_secrets_user_aspnetapp,
    azurerm_role_assignment.kv_secrets_user_directus
  ]
  create_duration = "30s"
}

resource "azurerm_key_vault_secret" "first" {
  name         = "first-secret"
  value        = "This is a secret value"
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [time_sleep.wait_for_role_assignment]
}

ephemeral "random_password" "directus_admin" {
  special = true
  length  = 16
}

resource "azurerm_key_vault_secret" "directus_admin_password" {
  name             = "directus-admin-password"
  value_wo         = ephemeral.random_password.directus_admin.result
  value_wo_version = 1
  key_vault_id     = azurerm_key_vault.kv.id
  depends_on       = [time_sleep.wait_for_role_assignment]
}

ephemeral "random_password" "directus_secret" {
  special = true
  length  = 32
}

resource "azurerm_key_vault_secret" "directus_secret" {
  name             = "directus-secret"
  value_wo         = ephemeral.random_password.directus_secret.result
  value_wo_version = 1
  key_vault_id     = azurerm_key_vault.kv.id
  depends_on       = [time_sleep.wait_for_role_assignment]
}

ephemeral "random_password" "postgresql_password" {
  special = true
  length  = 15
}

resource "azurerm_key_vault_secret" "db_password" {
  name             = "postgresql-password"
  value_wo         = ephemeral.random_password.postgresql_password.result
  value_wo_version = 1
  key_vault_id     = azurerm_key_vault.kv.id
  depends_on       = [time_sleep.wait_for_role_assignment]
}
