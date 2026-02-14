# Terraform Azure - PostgreSQL and Azure Container Apps

## Overview

This Terraform config provisions a resource group-scoped Azure stack with:

- Azure Database for PostgreSQL Flexible Server with private networking
- Azure Container Apps environment plus two apps (sample ASP.NET app and [Directus](https://directus.io/docs/getting-started/overview))
- Azure Key Vault and container app secrets
- User-assigned managed identities for app access
- Azure Storage account and container for Directus file storage
- VNET, subnets, private DNS, and Log Analytics workspace
- Azure Pipelines are used to the deploy the Terraform

Container Apps pull sensitive values from Key Vault and inject them as secrets into the app configuration, while user-assigned managed identities are used for app access. Terraform ephemeral resources and write-only arguments are used for password generation and injection so those values are not stored in state or plan files.

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
