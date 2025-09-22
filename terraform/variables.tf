variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-terraform-vm"
}

variable "location" {
  description = "Location for the resources"
  type        = string
  default     = "East US"
}

variable "vm_name" {
  description = "VM name"
  type        = string
  default     = "terraform-vm"
}

variable "admin_username" {
  description = "Admin username for VM"
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  description = "Admin password for VM. This is a sensitive value and should be passed in via a .tfvars file or environment variable."
  type        = string
  sensitive   = true
}

variable "app_name" {
  description = "Name of the application to deploy"
  type        = string
  default     = "python-flask-app"
}

# Azure Authentication Variables
# These are automatically provided by Azure DevOps service connection
variable "client_id" {
  description = "Azure Service Principal Client ID"
  type        = string
  default     = ""
  sensitive   = true
}

variable "client_secret" {
  description = "Azure Service Principal Client Secret"
  type        = string
  default     = ""
  sensitive   = true
}

variable "tenant_id" {
  description = "Azure Tenant ID"
  type        = string
  default     = ""
  sensitive   = true
}

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  default     = ""
  sensitive   = true
}
