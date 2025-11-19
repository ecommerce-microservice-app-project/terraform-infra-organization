################################################################################
# AZURE OUTPUTS
# Outputs for Azure AKS infrastructure
################################################################################

# Azure Resource Group Outputs
output "azure_resource_group_name" {
  description = "Name of the Azure resource group"
  value       = module.resource_group.name
}

output "azure_resource_group_location" {
  description = "Location of the Azure resource group"
  value       = module.resource_group.location
}

# Azure AKS Cluster Outputs
output "azure_aks_cluster_name" {
  description = "Name of the AKS cluster"
  value       = module.aks_cluster.name
}

output "azure_aks_cluster_id" {
  description = "ID of the AKS cluster"
  value       = module.aks_cluster.id
}

output "azure_kube_config" {
  description = "Raw kubeconfig for the AKS cluster"
  value       = module.aks_cluster.kube_config_raw
  sensitive   = true
}

output "azure_cluster_endpoint" {
  description = "Endpoint for the AKS cluster"
  value       = module.aks_cluster.cluster_endpoint
  sensitive   = true
}

# Azure AKS Node Pool Outputs
output "azure_prod_node_pool_id" {
  description = "ID of the Azure production node pool"
  value       = module.azure_prod_node_pool.id
}

output "azure_devstage_node_pool_id" {
  description = "ID of the Azure dev/stage node pool"
  value       = var.enable_devstage_pool ? module.azure_devstage_node_pool[0].id : "Not enabled"
}

# Convenience output for kubectl configuration
output "get_kubectl_config_command" {
  description = "Command to get kubectl configuration"
  value       = "az aks get-credentials --resource-group ${module.resource_group.name} --name ${module.aks_cluster.name}"
}

terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstateaccount"
    container_name       = "tfstate"
    key                  = "ecommerce.terraform.tfstate"
  }
}
