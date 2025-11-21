# GKE Cluster Module

This module creates a Google Kubernetes Engine (GKE) cluster with a system node pool.

## Features

- VPC-native cluster with IP aliasing
- Workload Identity enabled for enhanced security
- System node pool with configurable size
- Auto-repair and auto-upgrade enabled
- Configurable maintenance window
- Optional master authorized networks for security

## Architecture

Similar to AKS clusters, this module creates:
1. A GKE cluster with the default node pool removed
2. A dedicated system node pool for Kubernetes system components

Additional application node pools can be added using the `gke-node-pool` module.

## Usage

```hcl
module "gke_cluster" {
  source = "./modules/gke-cluster"

  cluster_name = "my-gke-cluster"
  location     = "us-central1"
  project_id   = "my-gcp-project"

  default_node_pool = {
    node_count   = 1
    machine_type = "e2-medium"
    disk_size_gb = 50
  }

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
```

## Network Requirements

This module requires a VPC network with secondary IP ranges for pods and services:

```hcl
# Example VPC configuration
resource "google_compute_network" "vpc" {
  name                    = "gke-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "gke-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = "us-central1"
  network       = google_compute_network.vpc.id

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.1.0.0/16"
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.2.0.0/16"
  }
}
```

## Machine Type Equivalents

GCP machine types roughly equivalent to Azure Standard_B2s:
- `e2-small`: 2 vCPUs, 2 GB RAM (slightly less than B2s)
- `e2-medium`: 2 vCPUs, 4 GB RAM (more RAM than B2s)
- `n1-standard-1`: 1 vCPU, 3.75 GB RAM (alternative)

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster_name | The name of the GKE cluster | string | - | yes |
| location | The location (region or zone) for the cluster | string | - | yes |
| project_id | The GCP project ID | string | - | yes |
| network | The VPC network to host the cluster in | string | "default" | no |
| subnetwork | The subnetwork to host the cluster in | string | "default" | no |
| pods_range_name | The name of the secondary range for pods | string | "pods" | no |
| services_range_name | The name of the secondary range for services | string | "services" | no |
| default_node_pool | Configuration for the system node pool | object | See variables.tf | no |
| service_account | The service account for node VMs | string | null | no |
| master_authorized_networks | List of master authorized networks | list(object) | null | no |
| maintenance_start_time | Start time for daily maintenance window | string | "03:00" | no |
| tags | A map of tags to add to all resources | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the GKE cluster |
| name | The name of the GKE cluster |
| endpoint | The IP address of the cluster master (sensitive) |
| cluster_ca_certificate | Base64 encoded CA certificate (sensitive) |
| location | The location of the cluster |
| master_version | The current version of the master |
| system_node_pool_id | The ID of the system node pool |

## Notes

- The default node pool is automatically deleted as per GKE best practices
- The system node pool has a taint to prevent regular workloads from scheduling on it
- Workload Identity is enabled by default for enhanced security
- Auto-repair and auto-upgrade are enabled for the system node pool
