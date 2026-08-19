# terraform {
#   required_providers {
#     azurerm = {
#       source  = "hashicorp/azurerm"
#       version = "5.1.0"
#     }
#   }
# }



# resource "azurerm_resource_group" "rg" {
#   name     = "rg1"
#   location = "East US"
# }

# resource "azurerm_resource_group" "rg2" {
#   name = "rg2"
#   location = "Central India"
# }

# resource "azurerm_resource_group" "rg3" {
#   name = "rg3"
#   location = " West Europe"
# }


# ==============================================================================
# Resource Group Module
# ==============================================================================
module "resource_groups" {

  source = "./modules/resource-group"

  resource_groups = var.resource_groups

}




# ==============================================================================
# Virtual Network Module
# ==============================================================================
module "vnet" {

  source = "./modules/vnet"

  vnet_name = var.vnet_name

  address_space = var.vnet_address_space

  location = "Central India"

  resource_group_name = var.resource_groups["network"].name

}


# ==============================================================================
# Subnet Module
# ==============================================================================


module "subnets" {

  source = "./modules/subnet"

  subnets = var.subnets

  virtual_network_name = var.vnet_name

  resource_group_name = var.resource_groups["network"].name

  depends_on = [
    module.vnet
  ]

}


# ==============================================================================
# Network Interface Module
# ==============================================================================

module "nics" {

  source = "./modules/nic"

  nic_name            = var.nic_name
  location            = var.nic_location
  resource_group_name = var.resource_groups["network"].name
  subnet_id           = module.subnets.subnet_ids["web"]

}



