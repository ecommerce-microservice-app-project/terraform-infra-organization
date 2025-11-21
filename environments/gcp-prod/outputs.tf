################################################################################
# GCP PRODUCTION OUTPUTS
# Outputs for GKE Production infrastructure
################################################################################

# GKE Cluster Outputs
output "gke_cluster_name" {
  description = "Name of the GKE cluster"
  value       = module.gke_cluster.name
}

output "gke_cluster_id" {
  description = "ID of the GKE cluster"
  value       = module.gke_cluster.id
}

output "cluster_endpoint" {
  description = "Endpoint for the GKE cluster"
  value       = module.gke_cluster.endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "Base64 encoded public certificate for the cluster"
  value       = module.gke_cluster.cluster_ca_certificate
  sensitive   = true
}

output "cluster_location" {
  description = "Location of the GKE cluster"
  value       = module.gke_cluster.location
}

output "master_version" {
  description = "The current version of the master in the cluster"
  value       = module.gke_cluster.master_version
}

# GKE Node Pool Outputs
output "system_node_pool_id" {
  description = "ID of the system node pool"
  value       = module.gke_cluster.system_node_pool_id
}

output "prod_node_pool_id" {
  description = "ID of the production node pool"
  value       = module.prod_node_pool.id
}

# Convenience output for kubectl configuration
output "get_kubectl_config_command" {
  description = "Command to get kubectl configuration"
  value       = "gcloud container clusters get-credentials ${module.gke_cluster.name} --location ${var.location} --project ${var.project_id}"
}
