################################################################################
# AZURE INFRASTRUCTURE
# This section creates AKS (Azure Kubernetes Service) resources
################################################################################

# Azure Resource Group - Logical container for Azure resources
module "resource_group" {
  source = "./modules/resource-group"

  name     = var.resource_group_name
  location = var.location
  tags     = var.common_tags
}

# Azure AKS Cluster - Managed Kubernetes service on Azure
module "aks_cluster" {
  source = "./modules/aks-cluster"

  cluster_name        = var.cluster_name
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  dns_prefix          = var.dns_prefix

  default_node_pool = var.default_node_pool

  tags = merge(
    var.common_tags,
    {
      Environment = "multi"
      Purpose     = "dev-stage-prod"
    }
  )
}

# Azure AKS Production Node Pool - Dedicated nodes for production workloads
module "azure_prod_node_pool" {
  source = "./modules/aks-node-pool"

  name                  = "prod"
  kubernetes_cluster_id = module.aks_cluster.id
  vm_size               = var.prod_node_pool.vm_size
  node_count            = var.prod_node_pool.node_count

  node_taints = [
    "environment=production:NoSchedule"
  ]

  tags = {
    Environment = "production"
  }
}

# Azure AKS Dev/Stage Node Pool - Dedicated nodes for development and staging
# TEMPORALMENTE DESHABILITADO: Requiere más cores de los disponibles en cuenta estudiante
# Para habilitarlo: cambiar enable_devstage_pool = true en terraform.tfvars
module "azure_devstage_node_pool" {
  source = "./modules/aks-node-pool"
  count  = var.enable_devstage_pool ? 1 : 0

  name                  = "devstage"
  kubernetes_cluster_id = module.aks_cluster.id
  vm_size               = var.devstage_node_pool.vm_size
  node_count            = var.devstage_node_pool.node_count

  node_taints = [
    "environment=non-production:NoSchedule"
  ]

  tags = {
    Environment = "non-production"
  }
}

################################################################################
# BACKEND CONFIGURATION
# Terraform state storage
################################################################################

# Para cuenta estudiante: usar estado local es suficiente
# No necesitas configurar backend remoto a menos que trabajes en equipo

# Si quieres usar backend remoto (opcional), descomenta una de estas opciones:

# Opción 1: Azure Storage (requiere crear storage account primero)
# terraform {
#   backend "azurerm" {
#     resource_group_name  = "terraform-state-rg"
#     storage_account_name = "tfstateaccount"
#     container_name       = "tfstate"
#     key                  = "ecommerce.terraform.tfstate"
#   }
# }

# Opción 2: Si ya tienes el backend S3 configurado
# terraform {
#   backend "s3" {
#     bucket = "final-project-inge-soft-tf"
#     key    = "project-inge-soft/terraform.tfstate"
#     region = "us-east-2"
#   }
# }
