# ==============================================================================
# Network Interface Outputs
# ==============================================================================

output "nic_id" {
  description = "Network Interface ID"
  value       = azurerm_network_interface.Nic.id
}

output "private_ip_address" {
  description = "Private IP address assigned to the NIC"
  value       = azurerm_network_interface.Nic.private_ip_address
}