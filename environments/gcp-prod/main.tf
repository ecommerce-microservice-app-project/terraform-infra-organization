################################################################################
# GCP PRODUCTION ENVIRONMENT
# GKE Cluster for Production workloads
################################################################################

terraform {
  backend "gcs" {
    bucket = "terraform-state-tfg-prod-2025"
    prefix = "terraform/state"
    # This bucket needs to be created manually in your GCP project
    # You can also use Azure Storage backend if preferred
  }
}

# GKE Cluster - Managed Kubernetes service on GCP
module "gke_cluster" {
  source = "../../modules/gke-cluster"

  cluster_name = var.cluster_name
  location     = var.location
  project_id   = var.project_id

  network    = var.network
  subnetwork = var.subnetwork

  pods_range_name     = var.pods_range_name
  services_range_name = var.services_range_name

  default_node_pool = var.default_node_pool

  service_account = var.service_account

  maintenance_start_time = var.maintenance_start_time

  tags = merge(
    var.common_tags,
    {
      environment = "production"
      purpose     = "prod-workloads"
    }
  )
}

# GKE Production Node Pool - Dedicated nodes for production workloads
module "prod_node_pool" {
  source = "../../modules/gke-node-pool"

  name         = "prod"
  location     = var.location
  cluster_name = module.gke_cluster.name

  machine_type = var.prod_node_pool.machine_type
  node_count   = var.prod_node_pool.node_count
  disk_size_gb = var.prod_node_pool.disk_size_gb

  service_account = var.service_account

  # Taints for production workloads (equivalent to Azure)
  node_taints = [
    {
      key    = "environment"
      value  = "production"
      effect = "NO_SCHEDULE"
    }
  ]

  tags = {
    environment = "production"
    pool        = "production"
  }
}
