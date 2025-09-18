# Terraform Backend Configuration for Azure Storage
# This file configures remote state storage in Azure Storage Account

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  # Backend configuration for Azure Storage (OPTIONAL)
  # Uncomment the backend block below when you want to use remote state
  # backend "azurerm" {
  #   resource_group_name  = "rg-terraform-state"
  #   storage_account_name = "tfstateankitdevops"  # Must be globally unique
  #   container_name       = "tfstate"
  #   key                  = "terraform.tfstate"
  #   use_azuread_auth     = true
  # }
}

# Configure the Azure Provider
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    
    virtual_machine {
      delete_os_disk_on_deletion     = true
      graceful_shutdown              = false
      skip_shutdown_and_force_delete = false
    }
  }
  
  # These will be automatically set by Azure DevOps service connection
  # client_id       = var.client_id
  # client_secret   = var.client_secret  
  # tenant_id       = var.tenant_id
  # subscription_id = var.subscription_id
}