terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.28.0"
    }
    azapi = {
      source = "azure/azapi"
    }
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
}