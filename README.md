# E-commerce Microservices Infrastructure - Azure AKS

Infrastructure as Code (IaC) for the e-commerce microservices project using Terraform with **Azure AKS (Azure Kubernetes Service)**.

## Project Structure

```
ecommerce-terraform-infra/
├── main.tf                    # Main orchestration file with Azure resources
├── variables.tf               # Variable definitions
├── outputs.tf                 # Outputs for Azure resources
├── providers.tf              # Azure provider configuration
├── terraform.tfvars.example   # Example configuration file
└── modules/                   # Reusable modules
    ├── resource-group/        # Azure Resource Group module
    ├── aks-cluster/           # Azure AKS Cluster module
    └── aks-node-pool/         # Azure AKS Node Pool module
```

## Azure Infrastructure

This project creates Kubernetes infrastructure on Azure:

- **Resource Group**: Logical container for Azure resources
- **AKS Cluster**: Managed Kubernetes service with system node pool
- **Production Node Pool**: Dedicated nodes for production workloads (with taints)
- **Dev/Stage Node Pool**: Dedicated nodes for development and staging (with taints)

### Key Features

- **Modular architecture**: Reusable, testable, and maintainable modules
- **Environment separation**: Node pools with taints for workload isolation
- **Parameterized configuration**: Customize deployments via variables
- **Comprehensive outputs**: Integration-ready outputs for CI/CD pipelines
- **Inline documentation**: Comments explain the purpose of each resource

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) installed and configured
- Active Azure subscription (cuenta de estudiante funciona con estas configuraciones)

### Notas para Cuenta de Estudiante de Azure

⚠️ **Limitaciones de cuenta estudiante:**
- Límites en tipos de recursos
- Créditos limitados (~$100-$200)
- Algunos tamaños de VM pueden no estar disponibles

✅ **Esta configuración está optimizada para cuenta estudiante:**
- Usa `Standard_B2s` (mínimo y más económico)
- Mínimo de nodos (1 por pool)
- Un solo cluster compartido para todos los ambientes

## Usage

### 1. Azure Authentication

```bash
az login
az account set --subscription <YOUR_SUBSCRIPTION_ID>
```

### 2. Configure Variables

Copy the example file and adjust values:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your values. **Important**: Don't commit `terraform.tfvars` to git!

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Review the Plan

```bash
terraform plan
```

### 5. Apply the Infrastructure

```bash
terraform apply
```

### 6. Get Kubeconfig

After deployment, configure kubectl:

```bash
# Using the output command
terraform output -raw get_kubectl_config_command | bash

# Or manually
az aks get-credentials --resource-group <RESOURCE_GROUP> --name <CLUSTER_NAME>
```

## Main Variables

| Variable            | Description         | Default        |
| ------------------- | ------------------- | -------------- |
| resource_group_name | Resource group name | az-k8s-rg      |
| location            | Azure region        | East US 2      |
| cluster_name        | AKS cluster name    | az-k8s-cluster |
| dns_prefix          | DNS prefix          | aksmultienv    |

See [variables.tf](variables.tf) for the complete list of variables.

## Node Pools

The infrastructure creates three node pools:

1. **System Pool** (default): System workloads - mínimo necesario
2. **Production Pool**: Para workloads de producción (taint: `environment=production:NoSchedule`)
3. **Dev/Stage Pool**: Para desarrollo y staging (taint: `environment=non-production:NoSchedule`)

### Usando los Taints

Para desplegar pods en un node pool específico, agrega tolerations y nodeSelector en tu deployment:

**Producción:**
```yaml
spec:
  tolerations:
    - key: environment
      operator: Equal
      value: production
      effect: NoSchedule
  nodeSelector:
    kubernetes.io/os: linux
```

**Dev/Stage:**
```yaml
spec:
  tolerations:
    - key: environment
      operator: Equal
      value: non-production
      effect: NoSchedule
  nodeSelector:
    kubernetes.io/os: linux
```

## Outputs

After applying the configuration, retrieve outputs:

```bash
terraform output
```

Get kubeconfig:

```bash
terraform output -raw azure_kube_config > ~/.kube/azure-config
```

## Modules

Each module is independent and reusable:

### Azure Modules

- **[resource-group](modules/resource-group/README.md)**: Creates Azure resource groups
- **[aks-cluster](modules/aks-cluster/README.md)**: Creates AKS clusters
- **[aks-node-pool](modules/aks-node-pool/README.md)**: Creates additional AKS node pools

## Backend Configuration

### Option 1: Local State (Default)
No backend configuration needed. State is stored locally in `terraform.tfstate`.

### Option 2: Azure Storage (Recomendado para producción)
Descomenta y configura el backend en `main.tf`:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstateaccount"
    container_name       = "tfstate"
    key                  = "ecommerce.terraform.tfstate"
  }
}
```

Luego crea el storage account primero:

```bash
az group create --name terraform-state-rg --location eastus
az storage account create --name tfstateaccount --resource-group terraform-state-rg --sku Standard_LRS
az storage container create --name tfstate --account-name tfstateaccount
```

## Clean Up Resources

**Destroy all infrastructure:**

```bash
terraform destroy
```

## Best Practices

1. Never commit `terraform.tfvars` with sensitive values
2. Use remote backend for state (Azure Storage) in production
3. Implement CI/CD for infrastructure changes
4. Always review the plan before applying
5. Use workspaces for multiple environments
6. Tag all resources appropriately for cost tracking
7. Enable logging and monitoring for the cluster
8. Implement network policies for security

## Cost Optimization

- Use smaller VM sizes (Standard_B2s) for development
- Use spot instances for non-production workloads (futuro)
- Implement auto-scaling for node pools
- Review and right-size instance types
- Use reserved instances for production workloads
- Monitor and clean up unused resources

## Troubleshooting

### Azure Issues

```bash
# Check AKS cluster status
az aks show --resource-group <RESOURCE_GROUP> --name <CLUSTER_NAME>

# View AKS logs
az aks get-credentials --resource-group <RESOURCE_GROUP> --name <CLUSTER_NAME>
kubectl get nodes

# Check node pools
az aks nodepool list --resource-group <RESOURCE_GROUP> --cluster-name <CLUSTER_NAME>
```

## License

This infrastructure code is part of the e-commerce microservices project.
