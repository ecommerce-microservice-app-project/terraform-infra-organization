resource "azurerm_kubernetes_cluster_node_pool" "this" {
  name                  = var.name
  kubernetes_cluster_id = var.kubernetes_cluster_id
  vm_size               = var.vm_size
  node_count            = var.node_count
  node_taints           = var.node_taints
  tags                  = var.tags
}
