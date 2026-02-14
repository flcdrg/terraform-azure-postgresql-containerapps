terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.10.0, < 5.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.8.1"
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
  features {}
}

provider "random" {
}
