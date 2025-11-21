# Azure Production Environment

This environment deploys an AKS (Azure Kubernetes Service) cluster for **production workloads** using the primary Azure student account.

## Architecture

- **Cloud Provider**: Microsoft Azure
- **Region**: East US 2
- **Cluster Type**: AKS (Azure Kubernetes Service)
- **Node Pools**:
  - System Pool: 1x Standard_B2s (Kubernetes system components)
  - Production Pool: 1x Standard_B2s (Production workloads with taint)

## Prerequisites

1. **Azure CLI** installed and configured
   ```bash
   az --version
   ```

2. **Terraform** >= 1.0
   ```bash
   terraform version
   ```

3. **Azure Account** with active subscription (primary student account)

4. **Backend Storage** (already configured):
   - Resource Group: `terraform-state-rg`
   - Storage Account: `storagetfstateaccount`
   - Container: `tfstate`

## Authentication

Login to Azure with your primary student account:

```bash
az login
az account show  # Verify you're using the correct subscription
```

## Configuration

1. Copy the example tfvars file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` with your desired values (optional, defaults are set)

3. Review the configuration:
   - Cluster name: `az-k8s-prod-cluster`
   - Resource group: `az-k8s-prod-rg`
   - Location: `East US 2`

## Deployment

### Initialize Terraform

```bash
cd environments/azure-prod
terraform init
```

This will:
- Initialize the backend (Azure Storage)
- Download required providers (azurerm ~> 3.0)

### Plan the Deployment

```bash
terraform plan
```

Review the plan to ensure:
- 1 Resource Group will be created
- 1 AKS Cluster will be created
- 2 Node Pools will be created (system + production)

### Apply the Configuration

```bash
terraform apply
```

Type `yes` when prompted. This will take approximately 10-15 minutes.

## Post-Deployment

### Get Cluster Credentials

```bash
az aks get-credentials --resource-group az-k8s-prod-rg --name az-k8s-prod-cluster
```

### Verify Cluster Access

```bash
kubectl get nodes
kubectl get namespaces
```

You should see 2 nodes:
- `system-xxxxx` (system pool)
- `prod-xxxxx` (production pool)

### Check Node Taints

```bash
kubectl describe node -l agentpool=prod | grep Taints
```

You should see: `environment=production:NoSchedule`

## Node Pool Details

### System Pool
- **Purpose**: Kubernetes system components (kube-system, CoreDNS, etc.)
- **Size**: 1 node, Standard_B2s
- **Auto-scaling**: Disabled
- **Taints**: Default GKE system taints

### Production Pool
- **Purpose**: Production application workloads
- **Size**: 1 node, Standard_B2s
- **Taint**: `environment=production:NoSchedule`
- **Tolerations Required**: Pods must have this toleration to schedule:
  ```yaml
  tolerations:
  - key: "environment"
    operator: "Equal"
    value: "production"
    effect: "NoSchedule"
  ```

## Cost Information

**Estimated Monthly Cost** (student account):
- 2x Standard_B2s nodes: ~$30-40/month (with student credits)
- AKS management: Free
- **Total**: ~$30-40/month

**Note**: This uses the maximum VM size allowed for Azure student accounts.

## Maintenance

### Update Node Count

Edit `terraform.tfvars`:
```hcl
prod_node_pool = {
  vm_size    = "Standard_B2s"
  node_count = 2  # Changed from 1
}
```

Then apply:
```bash
terraform apply
```

### Destroy Infrastructure

⚠️ **WARNING**: This will delete all resources in this environment!

```bash
terraform destroy
```

## Troubleshooting

### Quota Exceeded Error

If you get a quota error:
1. Check your subscription quotas: `az vm list-usage --location "East US 2" -o table`
2. Ensure you're not exceeding the 4-core limit for student accounts
3. Delete unused resources if needed

### Authentication Issues

If Terraform can't authenticate:
```bash
az account show  # Check current subscription
az account list  # List all subscriptions
az account set --subscription "your-subscription-id"
```

### Backend Access Issues

If you can't access the backend storage:
```bash
az storage account show --name storagetfstateaccount --resource-group terraform-state-rg
```

Ensure you have "Storage Blob Data Contributor" role on the storage account.

## Related Environments

- [Azure Stage](../azure-stage/README.md) - Staging environment (second Azure account)
- [GCP Prod](../gcp-prod/README.md) - Production environment on Google Cloud

## Support

For issues with:
- **Terraform**: Check [main README](../../README.md)
- **Azure**: Check Azure student account documentation
- **Kubernetes**: Check AKS documentation
