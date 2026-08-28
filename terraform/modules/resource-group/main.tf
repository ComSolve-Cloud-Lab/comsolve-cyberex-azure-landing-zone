#==============================================================================
# Create Resource Groups
# ==============================================================================

resource "azurerm_resource_group" "Rgs" {

  THIS_IS_A_TEST_ERROR

  for_each = var.resource_groups

  name     = each.value.name
  location = each.value.location

}