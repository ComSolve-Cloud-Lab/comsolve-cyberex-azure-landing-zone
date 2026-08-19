#==============================================================================
# Create Resource Groups
# ==============================================================================

resource "azurerm_resource_group" "Rgs" {

  for_each = var.resource_groups

  name     = each.value.name
  location = each.value.location

}