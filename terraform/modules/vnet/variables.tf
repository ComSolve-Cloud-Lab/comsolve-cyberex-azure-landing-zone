variable "vnet_name" {

  description = "Name of the Azure Virtual Network"

  type = string

}


variable "address_space" {

  description = "Address space of the Virtual Network"

  type = string

}


variable "location" {

  description = "Azure region"

  type = string

}


variable "resource_group_name" {

  description = "Resource Group name"

  type = string

}