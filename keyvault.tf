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
  public_network_access_enabled = true
  purge_protection_enabled      = false # Only for demo purposes, consider enabling this for production environments

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    certificate_permissions = [
      "Backup",
      "Create",
      "Delete",
      "DeleteIssuers",
      "Get",
      "GetIssuers",
      "Import",
      "List",
      "ListIssuers",
      "ManageContacts",
      "ManageIssuers",
      "Purge",
      "Recover",
      "Restore",
      "SetIssuers",
      "Update"
    ]

    key_permissions = [
      "Create",
      "Decrypt",
      "Delete",
      "Encrypt",
      "Get",
      "Import",
      "List",
      "Purge",
      "Recover",
      "Restore",
      "Sign",
      "UnwrapKey",
      "Update",
      "Verify",
      "WrapKey",
      "Release",
      "Rotate",
      "GetRotationPolicy",
      "SetRotationPolicy"
    ]

    secret_permissions = [
      "Backup",
      "Delete",
      "Get",
      "List",
      "Purge",
      "Recover",
      "Restore",
      "Set"
    ]

    storage_permissions = [
      "Backup",
      "Delete",
      "DeleteSAS",
      "Get",
      "GetSAS",
      "List",
      "ListSAS",
      "Purge",
      "Recover",
      "RegenerateKey",
      "Restore",
      "Set",
      "SetSAS",
      "Update"

    ]
  }
}

# Allow time for role assignment to propagate before trying to create secrets, otherwise we may get a "Forbidden" error
resource "time_sleep" "wait_for_key_vault" {
  depends_on = [
    azurerm_key_vault.kv
  ]
  create_duration = "30s"
}

resource "random_password" "directus_admin" {
  special = true
  length  = 16
}

resource "azurerm_key_vault_secret" "directus_admin_password" {
  name             = "directus-admin-password"
  value_wo         = random_password.directus_admin.result
  value_wo_version = 1
  key_vault_id     = azurerm_key_vault.kv.id
  depends_on       = [time_sleep.wait_for_key_vault]
}

resource "random_password" "directus_secret" {
  special = true
  length  = 32
}

resource "azurerm_key_vault_secret" "directus_secret" {
  name             = "directus-secret"
  value_wo         = random_password.directus_secret.result
  value_wo_version = 1
  key_vault_id     = azurerm_key_vault.kv.id
  depends_on       = [time_sleep.wait_for_key_vault]
}

resource "random_password" "postgresql_password" {
  special = true
  length  = 15
}

resource "azurerm_key_vault_secret" "db_password" {
  name             = "postgresql-password"
  value_wo         = random_password.postgresql_password.result
  value_wo_version = 1
  key_vault_id     = azurerm_key_vault.kv.id
  depends_on       = [time_sleep.wait_for_key_vault]
}
