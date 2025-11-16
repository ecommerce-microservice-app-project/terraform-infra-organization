################################################################################
# AZURE VARIABLES
# Variables for Azure AKS infrastructure
################################################################################

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "az-k8s-rg"
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "East US 2"
}

variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
  default     = "az-k8s-cluster"
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  type        = string
  default     = "aksmultienv"
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
    vm_size    = "Standard_B2s"  # Optimizado para cuenta estudiante
  }
}

variable "prod_node_pool" {
  description = "Configuration for the production node pool"
  type = object({
    vm_size    = string
    node_count = number
  })
  default = {
    vm_size    = "Standard_B2s"  # Optimizado para cuenta estudiante
    node_count = 1
  }
}

variable "devstage_node_pool" {
  description = "Configuration for the dev/stage node pool"
  type = object({
    vm_size    = string
    node_count = number
  })
  default = {
    vm_size    = "Standard_B2s"  # Optimizado para cuenta estudiante
    node_count = 1
  }
}

variable "enable_devstage_pool" {
  description = "Enable dev/stage node pool. Set to false for student accounts with limited quota"
  type        = bool
  default     = false  # Deshabilitado por defecto para cuentas estudiante
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
    Project   = "Ecommerce-K8s"
  }
}
