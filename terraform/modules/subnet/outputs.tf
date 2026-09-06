# ==============================================================================
# Subnet Outputs
# ==============================================================================

output "subnet_ids" {

  description = "Subnet IDs"

  value = {
    for key, subnet in azurerm_subnet.Subnets :
    key => subnet.id
  }

}