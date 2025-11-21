################################################################################
# AZURE PRODUCTION OUTPUTS
# Outputs for Azure AKS Production infrastructure
################################################################################

# Azure Resource Group Outputs
output "resource_group_name" {
  description = "Name of the Azure resource group"
  value       = module.resource_group.name
}

output "resource_group_location" {
  description = "Location of the Azure resource group"
  value       = module.resource_group.location
}

# Azure AKS Cluster Outputs
output "aks_cluster_name" {
  description = "Name of the AKS cluster"
  value       = module.aks_cluster.name
}

output "aks_cluster_id" {
  description = "ID of the AKS cluster"
  value       = module.aks_cluster.id
}

output "kube_config" {
  description = "Raw kubeconfig for the AKS cluster"
  value       = module.aks_cluster.kube_config_raw
  sensitive   = true
}

output "cluster_endpoint" {
  description = "Endpoint for the AKS cluster"
  value       = module.aks_cluster.cluster_endpoint
  sensitive   = true
}

# Azure AKS Node Pool Outputs
output "prod_node_pool_id" {
  description = "ID of the production node pool"
  value       = module.prod_node_pool.id
}

# Convenience output for kubectl configuration
output "get_kubectl_config_command" {
  description = "Command to get kubectl configuration"
  value       = "az aks get-credentials --resource-group ${module.resource_group.name} --name ${module.aks_cluster.name}"
}
