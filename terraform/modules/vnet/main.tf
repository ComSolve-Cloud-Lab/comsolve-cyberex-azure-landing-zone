# ==============================================================================
# Create Virtual Network
# ==============================================================================

resource "azurerm_virtual_network" "Vnet" {

  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name

  address_space = [
    var.address_space
  ]

}