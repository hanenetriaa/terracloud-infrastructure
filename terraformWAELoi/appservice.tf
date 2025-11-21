data "azurerm_resource_group" "rg" { name = "rg-nce_4" }

resource "azurerm_service_plan" "plan" {
  name                = "terracloud-dev-plan"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = var.app_service_sku # "B1"
  tags                = { managedBy = "terraform" }
}

resource "azurerm_linux_web_app" "app" {
  name                = var.app_name # "terracloud-dev-wa"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.plan.id
  https_only          = true

  site_config {
    always_on = true
    application_stack { php_version = "8.2" }
  }

  tags = { managedBy = "terraform" }
}

output "webapp_url" { value = "https://${azurerm_linux_web_app.app.default_hostname}" }
