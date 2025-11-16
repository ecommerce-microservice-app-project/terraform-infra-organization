variable "name" {
  description = "Name of the node pool"
  type        = string
}

variable "kubernetes_cluster_id" {
  description = "ID of the AKS cluster"
  type        = string
}

variable "vm_size" {
  description = "Size of the VMs in the node pool"
  type        = string
}

variable "node_count" {
  description = "Number of nodes in the node pool"
  type        = number
}

variable "node_taints" {
  description = "Taints to apply to the nodes"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to the node pool"
  type        = map(string)
  default     = {}
}
