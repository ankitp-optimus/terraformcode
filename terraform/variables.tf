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

variable "admin_ssh_key" {
  description = "Admin SSH public key. This is a sensitive value and should be passed in via a .tfvars file or environment variable."
  type        = string
  sensitive   = true
}

variable "github_repo_url" {
  description = "GitHub repository URL to clone and deploy"
  type        = string
}

variable "app_name" {
  description = "Name of the application to deploy"
  type        = string
  default     = "python-flask-app"
}

variable "github_token" {
  description = "GitHub personal access token for private repositories (optional)"
  type        = string
  default     = ""
  sensitive   = true
}
