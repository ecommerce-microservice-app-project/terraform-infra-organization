variable "cluster_name" {
  description = "The name of the GKE cluster"
  type        = string
}

variable "location" {
  description = "The location (region or zone) for the GKE cluster"
  type        = string
}

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "network" {
  description = "The VPC network to host the cluster in"
  type        = string
  default     = "default"
}

variable "subnetwork" {
  description = "The subnetwork to host the cluster in"
  type        = string
  default     = "default"
}

variable "pods_range_name" {
  description = "The name of the secondary range for pods"
  type        = string
  default     = "pods"
}

variable "services_range_name" {
  description = "The name of the secondary range for services"
  type        = string
  default     = "services"
}

variable "default_node_pool" {
  description = "Configuration for the default system node pool"
  type = object({
    node_count   = number
    machine_type = string
    disk_size_gb = number
  })
  default = {
    node_count   = 1
    machine_type = "e2-medium"
    disk_size_gb = 50
  }
}

variable "service_account" {
  description = "The service account to be used by the node VMs"
  type        = string
  default     = null
}

variable "master_authorized_networks" {
  description = "List of master authorized networks"
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = null
}

variable "maintenance_start_time" {
  description = "Start time for the daily maintenance window (HH:MM format)"
  type        = string
  default     = "03:00"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}