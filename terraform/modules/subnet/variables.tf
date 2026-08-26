variable "subnets" {

  description = "Subnet configuration"

  type = map(object({

    name             = string
    address_prefixes = list(string)

  }))

}


variable "virtual_network_name" {

  description = "Virtual Network name"

  type = string

}


variable "resource_group_name" {

  description = "Resource Group name"

  type = string

}


variable "network_security_group_id" {
  description = "Network Security Group ID associated with subnets"
  type        = string
}