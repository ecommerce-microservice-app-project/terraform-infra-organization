################################################################################
# AZURE STAGING ENVIRONMENT
# AKS Cluster for Staging workloads (Second Azure Account)
################################################################################

terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-stage-rg"
    storage_account_name = "storagetfstatestageacct"
    container_name       = "tfstate"
    key                  = "azure-stage.terraform.tfstate"
    # These values will be configured for the second Azure account
    # You'll need to create this storage account in your stage Azure subscription
  }
}

# Azure Resource Group - Logical container for Azure resources
module "resource_group" {
  source = "../../modules/resource-group"

  name     = var.resource_group_name
  location = var.location
  tags     = var.common_tags
}

# Azure AKS Cluster - Managed Kubernetes service on Azure
module "aks_cluster" {
  source = "../../modules/aks-cluster"

  cluster_name        = var.cluster_name
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  dns_prefix          = var.dns_prefix

  default_node_pool = var.default_node_pool

  tags = merge(
    var.common_tags,
    {
      Environment = "staging"
      Purpose     = "stage-workloads"
    }
  )
}

# Azure AKS Production Node Pool - Dedicated nodes for staging workloads
# Note: Named "prod" to maintain consistency with production environment structure
module "prod_node_pool" {
  source = "../../modules/aks-node-pool"

  name                  = "prod"
  kubernetes_cluster_id = module.aks_cluster.id
  vm_size               = var.prod_node_pool.vm_size
  node_count            = var.prod_node_pool.node_count

  node_taints = [
    "environment=production:NoSchedule"
  ]

  tags = {
    Environment = "staging"
    Pool        = "production"
  }
}
