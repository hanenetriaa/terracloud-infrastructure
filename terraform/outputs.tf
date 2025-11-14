output "vm_public_ip" {
  description = "IP publique"
  value       = azurerm_public_ip.pip.ip_address
}

output "ssh_user" {
  value = var.admin_user
}

output "ssh_command" {
  value = "ssh ${var.admin_user}@${azurerm_public_ip.pip.ip_address}"
}
