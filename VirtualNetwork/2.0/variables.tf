variable "resource_name_vnet" {
  description = "Name of the vnet to create"
  default     = ""
}

variable "resource_group_name_vnet" {
  description = "Name of the resource group to be imported."
  default     = "rg-tera-net-001"
}

variable "address_space" {
  type        = list(string)
  description = "The address space that is used by the virtual network."
  default     = ["10.0.0.0/16"]
}

# If no values specified, this defaults to Azure DNS 
variable "dns_servers" {
  description = "The DNS servers to be used with vNet."
  default     = []
}
variable "location" {
  
}

variable "subnet_prefixes" {
  description = "The address prefix to use for the subnet."
  default     = ["10.0.1.0/24","10.0.2.0/24"]
}

variable "subnet_names" {
  description = "A list of public subnets inside the vNet."
  default     = ["subnet1", "subnet2"]
}
variable "nsg_ids" {
  description = "A map of subnet name to Network Security Group IDs"
  type        = map(string)

  default = {
 
  }
}
variable "workspace_id" {
  description = "Name of the vnet to create"
  default     = ""
}
variable "workspace_rgname" {
  description = "Name of the vnet to create"
  default     = ""
}


variable "tags" {
  description = "The tags to associate with your network and subnets."
  type        = map(string)

  default = {
    ENV = "test"
  }
}

