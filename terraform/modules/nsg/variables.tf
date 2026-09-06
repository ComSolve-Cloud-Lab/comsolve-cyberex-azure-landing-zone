variable "name" {
  description = "Name of the Network Security Group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "tags" {
  description = "Tags for the NSG"
  type        = map(string)
  default     = {}
}