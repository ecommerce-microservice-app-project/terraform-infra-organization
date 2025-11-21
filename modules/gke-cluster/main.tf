resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.location

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  # Network configuration
  network    = var.network
  subnetwork = var.subnetwork

  # Enable Workload Identity (recommended for security)
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Cluster configuration
  deletion_protection = false

  # IP allocation policy (required for VPC-native clusters)
  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_range_name
    services_secondary_range_name = var.services_range_name
  }

  # Master authorized networks (optional, for security)
  dynamic "master_authorized_networks_config" {
    for_each = var.master_authorized_networks != null ? [1] : []
    content {
      dynamic "cidr_blocks" {
        for_each = var.master_authorized_networks
        content {
          cidr_block   = cidr_blocks.value.cidr_block
          display_name = cidr_blocks.value.display_name
        }
      }
    }
  }

  # Maintenance window
  maintenance_policy {
    daily_maintenance_window {
      start_time = var.maintenance_start_time
    }
  }

  # Resource labels
  resource_labels = var.tags
}

# System node pool (similar to AKS default pool)
resource "google_container_node_pool" "system" {
  name       = "system"
  location   = var.location
  cluster    = google_container_cluster.primary.name
  node_count = var.default_node_pool.node_count

  node_config {
    machine_type = var.default_node_pool.machine_type
    disk_size_gb = var.default_node_pool.disk_size_gb
    disk_type    = "pd-standard"

    # Service account with minimal permissions
    service_account = var.service_account
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    # Workload Identity
    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    # Labels
    labels = merge(
      var.tags,
      {
        pool = "system"
      }
    )

    # Taints for system pool
    taint {
      key    = "components.gke.io/gke-managed-components"
      value  = "true"
      effect = "NO_SCHEDULE"
    }

    metadata = {
      disable-legacy-endpoints = "true"
    }
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}