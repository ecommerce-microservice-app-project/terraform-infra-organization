variable "name" {
  description = "The name of the node pool"
  type        = string
}

variable "location" {
  description = "The location (region or zone) of the node pool"
  type        = string
}

variable "cluster_name" {
  description = "The name of the GKE cluster"
  type        = string
}

variable "node_count" {
  description = "The number of nodes in the node pool"
  type        = number
  default     = 1
}

variable "machine_type" {
  description = "The machine type for the nodes"
  type        = string
  default     = "e2-medium"
}

variable "disk_size_gb" {
  description = "The disk size in GB for each node"
  type        = number
  default     = 50
}

variable "disk_type" {
  description = "The disk type for each node (pd-standard or pd-ssd)"
  type        = string
  default     = "pd-standard"
}

variable "service_account" {
  description = "The service account to be used by the node VMs"
  type        = string
  default     = null
}

variable "node_taints" {
  description = "List of Kubernetes taints to apply to nodes"
  type = list(object({
    key    = string
    value  = string
    effect = string
  }))
  default = []
}

variable "preemptible" {
  description = "Whether to use preemptible nodes (cheaper but can be terminated)"
  type        = bool
  default     = false
}

variable "auto_repair" {
  description = "Whether the nodes will be automatically repaired"
  type        = bool
  default     = true
}

variable "auto_upgrade" {
  description = "Whether the nodes will be automatically upgraded"
  type        = bool
  default     = true
}

variable "autoscaling_enabled" {
  description = "Whether to enable autoscaling for this node pool"
  type        = bool
  default     = false
}

variable "min_node_count" {
  description = "Minimum number of nodes in the autoscaling configuration"
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "Maximum number of nodes in the autoscaling configuration"
  type        = number
  default     = 3
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
