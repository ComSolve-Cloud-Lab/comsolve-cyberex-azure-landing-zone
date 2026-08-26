# ==============================================================================
# Create Subnets
# ==============================================================================

resource "azurerm_subnet" "Subnets" {

  for_each = var.subnets

  name                 = each.value.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name

  address_prefixes = each.value.address_prefixes

}

# ==============================================================================
# Network Security Group Association
# ==============================================================================

resource "azurerm_subnet_network_security_group_association" "this" {

  for_each = azurerm_subnet.Subnets

  subnet_id                 = each.value.id
  network_security_group_id = var.network_security_group_id
}


