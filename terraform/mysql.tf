data "azurerm_resource_group" "rg" {
  name = "rg-nce_4"
}

resource "azurerm_mysql_flexible_server" "db" {
  name                   = var.mysql_name
  resource_group_name    = data.azurerm_resource_group.rg.name
  location               = data.azurerm_resource_group.rg.location

  administrator_login    = var.mysql_admin
  administrator_password = var.mysql_password

  version   = "8.0.21"
  sku_name  = "B_Standard_B1ms"   # petit budget (dev)
  storage { size_gb = 20 }
  backup  { backup_retention_days = 7 }
  high_availability { mode = "Disabled" }

  # Accès public (simple pour démo). En prod: préférer VNet Integration.
  network { public_network_access_enabled = true }

  tags = { managedBy = "terraform" }
}

resource "azurerm_mysql_flexible_database" "appdb" {
  name                = var.mysql_db_name
  resource_group_name = data.azurerm_resource_group.rg.name
  server_name         = azurerm_mysql_flexible_server.db.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"
}

# Autorise "Azure services" (règle spéciale: 0.0.0.0)
resource "azurerm_mysql_flexible_server_firewall_rule" "allow_azure" {
  name                = "allow-azure"
  resource_group_name = data.azurerm_resource_group.rg.name
  server_name         = azurerm_mysql_flexible_server.db.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}