variable "subscription_id" {
  type        = string
  description = "ID of the Azure subscriptions used"
}

variable "location" {
  type        = string
  description = "Azure location name used (input example: Canada East)"
}

variable "vn_address_space" {
  type        = list(string)
  description = "Virtual Network address space (input example: 172.16.0.0/16)"
}

variable "vn_subnet" {
  type        = list(string)
  description = "Subnet used by the Azure Virtual Network (input example: 172.16.1.0/24)"
}

variable "azure_location" {
  type        = string
  description = "Name of the azure region code, refer to https://www.ntweekly.com/2021/06/27/list-all-azure-regions-using-powershell/"
}