data "azurerm_resource_group" "rg" { name = "rg-nce_4" }

resource "azurerm_service_plan" "plan" {
  name                = "terracloud-dev-plan"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = var.app_service_sku # "B1"
  tags                = { managedBy = "terraform" }
}

resource "random_password" "appkey_raw" {
  length  = 32
  special = false
}

locals { app_key = "base64:${base64encode(random_password.appkey_raw.result)}" }

resource "azurerm_linux_web_app" "app" {
  name                = var.app_name # "terracloud-dev-wa"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.plan.id
  https_only          = true

  site_config {
    always_on = true
    application_stack { php_version = "8.2" }
    app_command_line = "bash -lc 'cd /home/site/wwwroot && [ -f index.php ] || printf \"%s\\n\" \"<?php require __DIR__.'/public/index.php';\" > index.php; mkdir -p database; [ -f database/database.sqlite ] || touch database/database.sqlite; php artisan migrate --force || true; php artisan config:cache || true; php artisan route:cache || true'"
  }

  app_settings = {
    APP_ENV                             = "production"
    APP_DEBUG                           = "false"
    APP_KEY                             = local.app_key
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "true"
    # Choisis UNE des 2 stratégies ci-dessous (A ou B) et ajuste ci-dessous :
    # A) Vendor pré-packagé dans le zip (recommandé) -> false
    # B) Laisser Oryx composer install (zip à la racine, pas de dossier parent) -> true
    SCM_DO_BUILD_DURING_DEPLOYMENT = "true"
  }

  tags = { managedBy = "terraform" }
}

output "webapp_url" { value = "https://${azurerm_linux_web_app.app.default_hostname}" }
