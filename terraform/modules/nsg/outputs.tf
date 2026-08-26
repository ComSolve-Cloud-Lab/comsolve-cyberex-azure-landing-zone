output "id" {
  description = "NSG resource ID"
  value       = azurerm_network_security_group.this.id
}

output "name" {
  description = "NSG name"
  value       = azurerm_network_security_group.this.name
}