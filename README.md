# Terraform Azure Demo

Demo repo using Terraform to deploy a simple app to Azure using GitHub Actions.

State is stored in a separate Azure Storage Account.

## Developer/environment configuration

### 1) Azure resource group

```bash
az group create --name rg-tfdemo-australiaeast --location australiaeast
```

State is stored in an Azure Storage account `sttfdemostateausteast` in a separate resource group

```bash
az group create --name rg-tfdemo-state-australiaeast --location australiaeast
```



### 2) App registration + roles for OIDC (no client secret)

```bash
# Create an app registration for GitHub Actions
az ad app create --display-name sp-tfdemo-australiaeast

# Create the service principal and assign roles needed by Terraform
APP_ID=$(az ad app list --display-name sp-tfdemo-australiaeast --query "[0].appId" -o tsv)
az ad sp create --id "$APP_ID"

SUBSCRIPTION_ID=<your-subscription-id>
SCOPE=/subscriptions/$SUBSCRIPTION_ID/resourceGroups/rg-tfdemo-australiaeast
STATE_SCOPE=/subscriptions/$SUBSCRIPTION_ID/resourceGroups/rg-tfdemo-state-australiaeast/providers/Microsoft.Storage/storageAccounts/sttfdemostateausteast

az role assignment create --assignee "$APP_ID" --role Contributor --scope $SCOPE
az role assignment create --assignee "$APP_ID" --role "Role Based Access Control Administrator" --scope $SCOPE
az role assignment create --assignee "$APP_ID" --role "Storage Blob Data Contributor" --scope $STATE_SCOPE
az role assignment create --assignee "$APP_ID" --role "Storage Account Contributor" --scope $STATE_SCOPE
```

### 3) Add a federated credential for GitHub Actions

Grant the workflow permission to request tokens via GitHub OIDC. Update the `subject` if you want additional branches or environments.

```bash
cat > credential.json <<'EOF'
{
    "name": "github-actions-main",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:flcdrg/terraform-azure-demo:ref:refs/heads/main",
    "description": "OIDC for Terraform workflow",
    "audiences": ["api://AzureADTokenExchange"]
}
EOF

az ad app federated-credential create --id "$APP_ID" --parameters credential.json
```

If you want pull requests to plan with OIDC, add another credential with a subject such as `repo:flcdrg/terraform-azure-demo:pull_request` (or a specific environment). See [GitHub OIDC subjects](https://learn.microsoft.com/azure/developer/github/connect-from-azure?tabs=azure-cli%2Cwindows#configure-federated-credentials-on-azure-ad).

### 4) Repository secrets and permissions

Set the following GitHub secrets (no client secret is required):

- `ARM_CLIENT_ID` = the app registration client ID (`$APP_ID`)
- `ARM_TENANT_ID` = your Azure AD tenant ID
- `ARM_SUBSCRIPTION_ID` = your subscription ID
- `mssql_azuread_administrator_object_id`, `mssql_administrator_login`, `mssql_administrator_password` (as before)

Ensure GitHub Actions has `id-token: write` permission (already set in the workflow) and that repository/workflow-level permissions allow it.
