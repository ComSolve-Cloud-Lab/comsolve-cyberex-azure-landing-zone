# ==============================================================================
# Network Interface Variables
# ==============================================================================

variable "nic_name" {
  description = "Name of the Network Interface"
  type        = string
}

variable "location" {
  description = "Azure region for the Network Interface"
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group name"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where the NIC will be attached"
  type        = string
}