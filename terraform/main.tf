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



module "resource_groups" {

  source = "./modules/resource-group"

  resource_groups = var.resource_groups

}
