output "id" {
  description = "ID of the AKS cluster"
  value       = azurerm_kubernetes_cluster.this.id
}

output "name" {
  description = "Name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.this.name
}

output "kube_config_raw" {
  description = "Raw kubeconfig for the AKS cluster"
  value       = azurerm_kubernetes_cluster.this.kube_config_raw
  sensitive   = true
}

output "kube_config" {
  description = "Structured kubeconfig for the AKS cluster"
  value       = azurerm_kubernetes_cluster.this.kube_config
  sensitive   = true
}

output "client_certificate" {
  description = "Client certificate for the AKS cluster"
  value       = azurerm_kubernetes_cluster.this.kube_config[0].client_certificate
  sensitive   = true
}

output "client_key" {
  description = "Client key for the AKS cluster"
  value       = azurerm_kubernetes_cluster.this.kube_config[0].client_key
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "Cluster CA certificate for the AKS cluster"
  value       = azurerm_kubernetes_cluster.this.kube_config[0].cluster_ca_certificate
  sensitive   = true
}

output "cluster_endpoint" {
  description = "Endpoint for the AKS cluster"
  value       = azurerm_kubernetes_cluster.this.kube_config[0].host
  sensitive   = true
}
