# AKS Cluster Module

This module creates an Azure Kubernetes Service (AKS) cluster.

## Usage

```hcl
module "aks_cluster" {
  source = "./modules/aks-cluster"

  cluster_name        = "my-aks-cluster"
  location            = "East US 2"
  resource_group_name = "my-rg"
  dns_prefix          = "myaks"

  default_node_pool = {
    name       = "system"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  tags = {
    Environment = "dev"
  }
}
```

## Variables

| Name                | Description                    | Type   | Required | Default |
|---------------------|--------------------------------|--------|----------|---------|
| cluster_name        | AKS cluster name               | string | Yes      | -       |
| location            | Azure region                   | string | Yes      | -       |
| resource_group_name | Resource group name            | string | Yes      | -       |
| dns_prefix          | DNS prefix for the cluster     | string | Yes      | -       |
| default_node_pool   | Default node pool configuration| object | Yes      | -       |
| tags                | Tags to apply                  | map(string) | No  | {}      |

## Outputs

| Name                   | Description                     |
|------------------------|---------------------------------|
| id                     | AKS cluster ID                  |
| name                   | Cluster name                    |
| kube_config_raw        | Raw kubeconfig (sensitive)      |
| kube_config            | Structured kubeconfig (sensitive)|
| client_certificate     | Client certificate (sensitive)  |
| client_key             | Client key (sensitive)          |
| cluster_ca_certificate | Cluster CA certificate (sensitive)|
| cluster_endpoint       | Cluster endpoint (sensitive)    |
