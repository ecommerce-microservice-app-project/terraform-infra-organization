################################################################################
# AZURE STAGING VARIABLES
# Variables for Azure AKS Staging environment (Second Azure Account)
################################################################################

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "az-k8s-stage-rg"
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "East US 2"
}

variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
  default     = "az-k8s-stage-cluster"
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  type        = string
  default     = "aksstage"
}

variable "default_node_pool" {
  description = "Configuration for the default node pool (system pool)"
  type = object({
    name       = string
    node_count = number
    vm_size    = string
  })
  default = {
    name       = "system"
    node_count = 1
    vm_size    = "Standard_B2s"  # Same as prod for student account
  }
}

variable "prod_node_pool" {
  description = "Configuration for the production node pool"
  type = object({
    vm_size    = string
    node_count = number
  })
  default = {
    vm_size    = "Standard_B2s"  # Same as prod for student account
    node_count = 1
  }
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    ManagedBy   = "Terraform"
    Project     = "Ecommerce-K8s"
    Environment = "staging"
  }
}
