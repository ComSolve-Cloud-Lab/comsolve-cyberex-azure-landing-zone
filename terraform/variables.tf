variable "resource_groups" {

  description = "Resource Group configuration"

  type = map(object({
    name     = string
    location = string
  }))

}