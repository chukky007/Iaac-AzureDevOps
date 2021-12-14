# Generic Input Variables
# Business Division
variable "business_divsion" {
  description = "Business Division"
  type = string
  default = "sap"
}
# Environment Variable
variable "environment" {
  description = "Environment Variable to be used as prefix"
  type = string
  default = "dev"
}

# Azure Resource Group Name 
variable "resource_group_name" {
  description = "Resource Group Name"
  type = string
  default = "rg-default"  
}

# Azure Resources Location
variable "resource_group_location" {
  description = "Region in which Azure Resources is to be created"
  type = string
  default = "westeurope"  
}
