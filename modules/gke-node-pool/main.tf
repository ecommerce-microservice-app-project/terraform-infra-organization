resource "google_container_node_pool" "pool" {
  name       = var.name
  location   = var.location
  cluster    = var.cluster_name
  node_count = var.node_count

  # Node configuration
  node_config {
    machine_type = var.machine_type
    disk_size_gb = var.disk_size_gb
    disk_type    = var.disk_type

    # Service account
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
        pool = var.name
      }
    )

    # Taints (equivalent to Azure node taints)
    dynamic "taint" {
      for_each = var.node_taints
      content {
        key    = taint.value.key
        value  = taint.value.value
        effect = taint.value.effect
      }
    }

    metadata = {
      disable-legacy-endpoints = "true"
    }

    # Preemptible nodes (optional, for cost savings)
    preemptible = var.preemptible
  }

  # Node pool management
  management {
    auto_repair  = var.auto_repair
    auto_upgrade = var.auto_upgrade
  }

  # Autoscaling configuration (optional)
  dynamic "autoscaling" {
    for_each = var.autoscaling_enabled ? [1] : []
    content {
      min_node_count = var.min_node_count
      max_node_count = var.max_node_count
    }
  }
}
