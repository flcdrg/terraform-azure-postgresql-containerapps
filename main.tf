terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.10.0, < 5.0.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-tfdemo-state-australiaeast"
    storage_account_name = "sttfdemostateausteast"
    container_name       = "postgresql-containerapps-tfstate"
    key                  = "terraform.tfstate"
  }
  required_version = ">= 1.2.3"
}

provider "azurerm" {
  subscription_id = "b4b2e7e9-66e7-46b5-a56b-cce2b50011d4"
  features {}
}

data "azurerm_resource_group" "rg" {
  name = "rg-postgresql-apps-australiaeast"
}