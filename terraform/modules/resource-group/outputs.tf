# ==============================================================================
# Resource Group Outputs
# ==============================================================================

output "resource_group_names" {

  description = "Map of Resource Group names"

  value = {
    for key, rg in azurerm_resource_group.Rgs :
    key => rg.name
  }

}