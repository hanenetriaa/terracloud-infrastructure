terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.100.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "6b9318b1-2215-418a-b0fd-ba0832e9b333"
  tenant_id       = "901cb4ca-b862-4029-9306-e5cd0f6d9f86"
}
