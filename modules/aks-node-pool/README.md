# AKS Node Pool Module

This module creates an additional node pool for an existing AKS cluster.

## Usage

```hcl
module "prod_node_pool" {
  source = "./modules/aks-node-pool"

  name                  = "prod"
  kubernetes_cluster_id = module.aks_cluster.id
  vm_size               = "Standard_DS3_v2"
  node_count            = 1

  node_taints = [
    "environment=production:NoSchedule"
  ]

  tags = {
    Environment = "production"
  }
}
```

## Variables

| Name                  | Description        | Type         | Required | Default |
|-----------------------|--------------------|--------------|----------|---------|
| name                  | Node pool name     | string       | Yes      | -       |
| kubernetes_cluster_id | AKS cluster ID     | string       | Yes      | -       |
| vm_size               | VM size            | string       | Yes      | -       |
| node_count            | Number of nodes    | number       | Yes      | -       |
| node_taints           | Node taints        | list(string) | No       | []      |
| tags                  | Tags to apply      | map(string)  | No       | {}      |

## Outputs

| Name | Description    |
|------|----------------|
| id   | Node pool ID   |
| name | Node pool name |
