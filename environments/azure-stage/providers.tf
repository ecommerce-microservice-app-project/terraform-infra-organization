terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}

  # Authentication for second Azure account (student account)
  # Option 1: Use Azure CLI with specific subscription
  # Before running terraform: az account set --subscription "<subscription-id>"

  # Option 2: Use Service Principal (recommended for automation)
  # Uncomment and configure these if using service principal:
  # subscription_id = var.subscription_id
  # client_id       = var.client_id
  # client_secret   = var.client_secret
  # tenant_id       = var.tenant_id

  # Option 3: Use environment variables
  # export ARM_SUBSCRIPTION_ID="..."
  # export ARM_CLIENT_ID="..."
  # export ARM_CLIENT_SECRET="..."
  # export ARM_TENANT_ID="..."
}

# Uncomment these variables if using service principal authentication
# variable "subscription_id" {
#   description = "Azure Subscription ID for staging account"
#   type        = string
#   sensitive   = true
# }
#
# variable "client_id" {
#   description = "Azure Client ID (Service Principal)"
#   type        = string
#   sensitive   = true
# }
#
# variable "client_secret" {
#   description = "Azure Client Secret (Service Principal)"
#   type        = string
#   sensitive   = true
# }
#
# variable "tenant_id" {
#   description = "Azure Tenant ID"
#   type        = string
#   sensitive   = true
# }
