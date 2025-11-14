terraform {
  backend "azurerm" {
    resource_group_name  = "rg-nce_4"
    storage_account_name = "tfstatencea2024"
    container_name       = "tfstate"
    key                  = "terracloud-iaas.tfstate"
  }
}
