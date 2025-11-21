output "id" {
  description = "The ID of the GKE cluster"
  value       = google_container_cluster.primary.id
}

output "name" {
  description = "The name of the GKE cluster"
  value       = google_container_cluster.primary.name
}

output "endpoint" {
  description = "The IP address of the cluster master"
  value       = google_container_cluster.primary.endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "Base64 encoded public certificate that is the root of trust for the cluster"
  value       = google_container_cluster.primary.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

output "location" {
  description = "The location of the cluster"
  value       = google_container_cluster.primary.location
}

output "master_version" {
  description = "The current version of the master in the cluster"
  value       = google_container_cluster.primary.master_version
}

output "system_node_pool_id" {
  description = "The ID of the system node pool"
  value       = google_container_node_pool.system.id
}