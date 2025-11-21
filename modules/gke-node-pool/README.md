# GKE Node Pool Module

This module creates an additional node pool for an existing GKE cluster.

## Features

- Configurable machine types and node counts
- Support for node taints (equivalent to Azure AKS taints)
- Auto-repair and auto-upgrade capabilities
- Optional autoscaling
- Workload Identity enabled
- Optional preemptible nodes for cost savings

## Usage

```hcl
module "production_node_pool" {
  source = "./modules/gke-node-pool"

  name         = "production"
  location     = "us-central1"
  cluster_name = module.gke_cluster.name

  node_count   = 1
  machine_type = "e2-medium"
  disk_size_gb = 50

  # Taint for production workloads only
  node_taints = [
    {
      key    = "environment"
      value  = "production"
      effect = "NO_SCHEDULE"
    }
  ]

  tags = {
    Environment = "production"
  }
}
```

## Node Taints

Node taints work similarly to Azure AKS taints. Common taint effects:

- `NO_SCHEDULE`: Pods without matching tolerations won't be scheduled
- `PREFER_NO_SCHEDULE`: Kubernetes will try to avoid scheduling pods without tolerations
- `NO_EXECUTE`: Existing pods without tolerations will be evicted

Example with multiple taints:

```hcl
node_taints = [
  {
    key    = "environment"
    value  = "production"
    effect = "NO_SCHEDULE"
  },
  {
    key    = "dedicated"
    value  = "backend"
    effect = "NO_SCHEDULE"
  }
]
```

## Autoscaling

Enable autoscaling for dynamic workloads:

```hcl
module "autoscaling_pool" {
  source = "./modules/gke-node-pool"

  name         = "autoscale"
  cluster_name = module.gke_cluster.name
  location     = "us-central1"

  autoscaling_enabled = true
  min_node_count      = 1
  max_node_count      = 5

  machine_type = "e2-medium"
}
```

## Preemptible Nodes

Use preemptible nodes for non-critical workloads to save costs (up to 80% cheaper):

```hcl
module "preemptible_pool" {
  source = "./modules/gke-node-pool"

  name         = "batch"
  cluster_name = module.gke_cluster.name
  location     = "us-central1"

  preemptible  = true
  machine_type = "e2-medium"
  node_count   = 2
}
```

**Note**: Preemptible nodes can be terminated at any time and will live for a maximum of 24 hours.

## Machine Types

Common GCP machine types equivalent to Azure:

| Azure | GCP Equivalent | vCPUs | RAM |
|-------|----------------|-------|-----|
| Standard_B2s | e2-small | 2 | 2 GB |
| Standard_B2s | e2-medium | 2 | 4 GB |
| Standard_B2ms | e2-standard-2 | 2 | 8 GB |
| Standard_D2s_v3 | n2-standard-2 | 2 | 8 GB |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the node pool | string | - | yes |
| location | The location of the node pool | string | - | yes |
| cluster_name | The name of the GKE cluster | string | - | yes |
| node_count | The number of nodes in the pool | number | 1 | no |
| machine_type | The machine type for nodes | string | "e2-medium" | no |
| disk_size_gb | The disk size in GB per node | number | 50 | no |
| disk_type | The disk type (pd-standard or pd-ssd) | string | "pd-standard" | no |
| service_account | The service account for node VMs | string | null | no |
| node_taints | List of Kubernetes taints | list(object) | [] | no |
| preemptible | Whether to use preemptible nodes | bool | false | no |
| auto_repair | Whether nodes will be auto-repaired | bool | true | no |
| auto_upgrade | Whether nodes will be auto-upgraded | bool | true | no |
| autoscaling_enabled | Enable autoscaling | bool | false | no |
| min_node_count | Minimum nodes for autoscaling | number | 1 | no |
| max_node_count | Maximum nodes for autoscaling | number | 3 | no |
| tags | Map of tags to add to resources | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the node pool |
| name | The name of the node pool |
| instance_group_urls | List of instance group URLs assigned to the cluster |

## Notes

- Node pools inherit the cluster's network and Workload Identity configuration
- Auto-repair and auto-upgrade are enabled by default for reliability
- Preemptible nodes are significantly cheaper but less reliable
- Taints must match pod tolerations for scheduling to work
