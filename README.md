# Terraform Azure - PostgreSQL and Azure Container Apps

- Azure deployment
- Azure Database for PostgreSQL flexible server
- Azure Container Apps
- Azure Pipelines
- Azure Storage for Terraform state management

## Developer/environment configuration

### 1) Azure resource group

```bash
az group create --name rg-postgresql-apps-australiaeast --location australiaeast
```

State is stored in an Azure Storage account `sttfdemostateausteast` in a separate resource group

```bash
az group create --name rg-tfdemo-state-australiaeast --location australiaeast
```

Make sure the blob container exists in the storage account

```bash
az storage container create --name postgresql-containerapps-tfstate --account-name sttfdemostateausteast
```

### 2) Add a federated credential for Azure Pipelines

Do this via the Azure Pipelines Service Connections page

Click through to find the App Registration in Entra ID, and copy the name.

```bash
# Get the service principal and assign roles needed by Terraform
APP_ID=$(az ad app list --display-name "APP_REGISTRATION_NAME" --query "[0].appId" -o tsv)

SUBSCRIPTION_ID=<your-subscription-id>
SCOPE=/subscriptions/$SUBSCRIPTION_ID/resourceGroups/rg-postgresql-apps-australiaeast
STATE_SCOPE=/subscriptions/$SUBSCRIPTION_ID/resourceGroups/rg-tfdemo-state-australiaeast/providers/Microsoft.Storage/storageAccounts/sttfdemostateausteast

az role assignment create --assignee "$APP_ID" --role "Role Based Access Control Administrator" --scope $SCOPE
az role assignment create --assignee "$APP_ID" --role "Storage Blob Data Contributor" --scope $STATE_SCOPE
az role assignment create --assignee "$APP_ID" --role "Storage Account Contributor" --scope $STATE_SCOPE
```
