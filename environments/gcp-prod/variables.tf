################################################################################
# GCP PRODUCTION VARIABLES
# Variables for GKE Production environment
################################################################################

variable "project_id" {
  description = "The GCP project ID"
  type        = string
  # You must provide this value in terraform.tfvars
}

variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
  default     = "gke-prod-cluster"
}

variable "location" {
  description = "The location (region or zone) for the GKE cluster"
  type        = string
  default     = "us-central1"
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
    machine_type = "e2-medium"  # 2 vCPU, 4GB RAM - equivalent to Azure Standard_B2s
    disk_size_gb = 50
  }
}

variable "prod_node_pool" {
  description = "Configuration for the production node pool"
  type = object({
    machine_type = string
    node_count   = number
    disk_size_gb = number
  })
  default = {
    machine_type = "e2-medium"  # 2 vCPU, 4GB RAM
    node_count   = 1
    disk_size_gb = 50
  }
}

variable "service_account" {
  description = "The service account to be used by the node VMs"
  type        = string
  default     = null
}

variable "maintenance_start_time" {
  description = "Start time for the daily maintenance window (HH:MM format)"
  type        = string
  default     = "03:00"
}

variable "common_tags" {
  description = "Common labels to apply to all resources"
  type        = map(string)
  default = {
    managed_by  = "terraform"
    project     = "ecommerce-k8s"
    environment = "production"
  }
}
