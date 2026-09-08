# ==============================================================================
# Existing Azure Resource Group Imports
# ==============================================================================

import {
  to = module.resource_groups.azurerm_resource_group.Rgs["network"]

  id = "/subscriptions/7cf9c45e-0a1e-4828-9c98-3e8f25397732/resourceGroups/rg-comsolve-cyberex-network"
}

import {
  to = module.resource_groups.azurerm_resource_group.Rgs["security"]

  id = "/subscriptions/7cf9c45e-0a1e-4828-9c98-3e8f25397732/resourceGroups/rg-comsolve-cyberex-security"
}

import {
  to = module.resource_groups.azurerm_resource_group.Rgs["platform"]

  id = "/subscriptions/7cf9c45e-0a1e-4828-9c98-3e8f25397732/resourceGroups/rg-comsolve-cyberex-platform"
}

import {
  to = module.vnet.azurerm_virtual_network.Vnet

  id = "/subscriptions/7cf9c45e-0a1e-4828-9c98-3e8f25397732/resourceGroups/rg-comsolve-cyberex-network/providers/Microsoft.Network/virtualNetworks/vnet-comsolve-cyberex-dev"
}

import {
  to = module.nsg.azurerm_network_security_group.this

  id = "/subscriptions/7cf9c45e-0a1e-4828-9c98-3e8f25397732/resourceGroups/rg-comsolve-cyberex-network/providers/Microsoft.Network/networkSecurityGroups/cyberex-nsg"
}

import {
  to = module.subnets.azurerm_subnet.Subnets["web"]

  id = "/subscriptions/7cf9c45e-0a1e-4828-9c98-3e8f25397732/resourceGroups/rg-comsolve-cyberex-network/providers/Microsoft.Network/virtualNetworks/vnet-comsolve-cyberex-dev/subnets/snet-web"
}

import {
  to = module.subnets.azurerm_subnet.Subnets["management"]

  id = "/subscriptions/7cf9c45e-0a1e-4828-9c98-3e8f25397732/resourceGroups/rg-comsolve-cyberex-network/providers/Microsoft.Network/virtualNetworks/vnet-comsolve-cyberex-dev/subnets/snet-management"
}

import {
  to = module.subnets.azurerm_subnet.Subnets["security"]

  id = "/subscriptions/7cf9c45e-0a1e-4828-9c98-3e8f25397732/resourceGroups/rg-comsolve-cyberex-network/providers/Microsoft.Network/virtualNetworks/vnet-comsolve-cyberex-dev/subnets/snet-security"
}

import {
  to = module.subnets.azurerm_subnet.Subnets["application"]

  id = "/subscriptions/7cf9c45e-0a1e-4828-9c98-3e8f25397732/resourceGroups/rg-comsolve-cyberex-network/providers/Microsoft.Network/virtualNetworks/vnet-comsolve-cyberex-dev/subnets/snet-application"
}

import {
  to = module.subnets.azurerm_subnet.Subnets["data"]

  id = "/subscriptions/7cf9c45e-0a1e-4828-9c98-3e8f25397732/resourceGroups/rg-comsolve-cyberex-network/providers/Microsoft.Network/virtualNetworks/vnet-comsolve-cyberex-dev/subnets/snet-data"
}

# ==============================================================================
# Existing Subnet to NSG Association Imports
# ==============================================================================

# import {
#   to = azurerm_subnet_network_security_group_association.subnet_nsg["web"]

#   id = "/subscriptions/7cf9c45e-0a1e-4828-9c98-3e8f25397732/resourceGroups/rg-comsolve-cyberex-network/providers/Microsoft.Network/virtualNetworks/vnet-comsolve-cyberex-dev/subnets/snet-web|/subscriptions/7cf9c45e-0a1e-4828-9c98-3e8f25397732/resourceGroups/rg-comsolve-cyberex-network/providers/Microsoft.Network/networkSecurityGroups/cyberex-nsg"
# }

# import {
#   to = azurerm_subnet_network_security_group_association.subnet_nsg["management"]

#   id = "/subscriptions/7cf9c45e-0a1e-4828-9c98-3e8f25397732/resourceGroups/rg-comsolve-cyberex-network/providers/Microsoft.Network/virtualNetworks/vnet-comsolve-cyberex-dev/subnets/snet-management|/subscriptions/7cf9c45e-0a1e-4828-9c98-3e8f25397732/resourceGroups/rg-comsolve-cyberex-network/providers/Microsoft.Network/networkSecurityGroups/cyberex-nsg"
# }

# import {
#   to = azurerm_subnet_network_security_group_association.subnet_nsg["application"]

#   id = "/subscriptions/7cf9c45e-0a1e-4828-9c98-3e8f25397732/resourceGroups/rg-comsolve-cyberex-network/providers/Microsoft.Network/virtualNetworks/vnet-comsolve-cyberex-dev/subnets/snet-application|/subscriptions/7cf9c45e-0a1e-4828-9c98-3e8f25397732/resourceGroups/rg-comsolve-cyberex-network/providers/Microsoft.Network/networkSecurityGroups/cyberex-nsg"
# }

# import {
#   to = azurerm_subnet_network_security_group_association.subnet_nsg["data"]

#   id = "/subscriptions/7cf9c45e-0a1e-4828-9c98-3e8f25397732/resourceGroups/rg-comsolve-cyberex-network/providers/Microsoft.Network/virtualNetworks/vnet-comsolve-cyberex-dev/subnets/snet-data|/subscriptions/7cf9c45e-0a1e-4828-9c98-3e8f25397732/resourceGroups/rg-comsolve-cyberex-network/providers/Microsoft.Network/networkSecurityGroups/cyberex-nsg"
# }

# import {
#   to = azurerm_subnet_network_security_group_association.subnet_nsg["security"]

#   id = "/subscriptions/7cf9c45e-0a1e-4828-9c98-3e8f25397732/resourceGroups/rg-comsolve-cyberex-network/providers/Microsoft.Network/virtualNetworks/vnet-comsolve-cyberex-dev/subnets/snet-security|/subscriptions/7cf9c45e-0a1e-4828-9c98-3e8f25397732/resourceGroups/rg-comsolve-cyberex-network/providers/Microsoft.Network/networkSecurityGroups/cyberex-nsg"
# }

# ==============================================================================
# Existing Network Interface Import
# ==============================================================================

import {
  to = module.nics.azurerm_network_interface.Nic

  id = "/subscriptions/7cf9c45e-0a1e-4828-9c98-3e8f25397732/resourceGroups/rg-comsolve-cyberex-network/providers/Microsoft.Network/networkInterfaces/nic-comsolve-cyberex-web"
}