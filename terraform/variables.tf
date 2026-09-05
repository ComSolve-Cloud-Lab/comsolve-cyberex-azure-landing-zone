# ==============================================================================
# Resource Group Variables
# ==============================================================================

variable "resource_groups" {

  description = "Resource Group configuration"

  type = map(object({
    name     = string
    location = string
  }))

}


# ==============================================================================
# Virtual Network Variables
# ==============================================================================

variable "vnet_name" {

  description = "Virtual Network name"

  type = string

}


variable "vnet_address_space" {

  description = "Virtual Network address space"

  type = string

}


# ==============================================================================
# Subnet Variables
# ==============================================================================
variable "subnets" {

  description = "Subnet configuration"

  type = map(object({

    name             = string
    address_prefixes = list(string)

  }))

}

# ==============================================================================
# Network Interface Variables
# ==============================================================================

variable "nic_name" {
  description = "Network Interface name"
  type        = string
}

variable "nic_location" {
  description = "Azure region for Network Interface"
  type        = string
}

