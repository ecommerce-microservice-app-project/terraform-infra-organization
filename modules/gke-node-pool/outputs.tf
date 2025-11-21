output "id" {
  description = "The ID of the node pool"
  value       = google_container_node_pool.pool.id
}

output "name" {
  description = "The name of the node pool"
  value       = google_container_node_pool.pool.name
}

output "instance_group_urls" {
  description = "List of instance group URLs which have been assigned to the cluster"
  value       = google_container_node_pool.pool.instance_group_urls
}
