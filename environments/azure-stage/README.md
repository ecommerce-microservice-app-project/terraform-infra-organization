# Azure Staging Environment

This environment deploys an AKS (Azure Kubernetes Service) cluster for **staging workloads** using a **second Azure student account**.

## Architecture

- **Cloud Provider**: Microsoft Azure (Second Student Account)
- **Region**: East US 2
- **Cluster Type**: AKS (Azure Kubernetes Service)
- **Node Pools**:
  - System Pool: 1x Standard_B2s (Kubernetes system components)
  - Production Pool: 1x Standard_B2s (Staging workloads with production-like config)

## Prerequisites

1. **Azure CLI** installed and configured
   ```bash
   az --version
   ```

2. **Terraform** >= 1.0
   ```bash
   terraform version
   ```

3. **Second Azure Student Account** with active subscription

4. **Service Principal** (recommended) or Azure CLI authentication for the second account

## Authentication Setup

### Option 1: Azure CLI (Simpler)

Switch to the staging subscription before running Terraform:

```bash
az login  # Login with second student account
az account list  # List all subscriptions
az account set --subscription "<staging-subscription-id>"
az account show  # Verify correct subscription
```

### Option 2: Service Principal (Recommended for Automation)

1. Create a service principal in the staging subscription:
   ```bash
   az ad sp create-for-rbac --name "terraform-staging" --role="Contributor" --scopes="/subscriptions/<staging-subscription-id>"
   ```

2. Note the output:
   ```json
   {
     "appId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
     "displayName": "terraform-staging",
     "password": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
     "tenant": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
   }
   ```

3. Set environment variables:
   ```bash
   export ARM_SUBSCRIPTION_ID="<staging-subscription-id>"
   export ARM_CLIENT_ID="<appId>"
   export ARM_CLIENT_SECRET="<password>"
   export ARM_TENANT_ID="<tenant>"
   ```

4. Or uncomment the variables in `providers.tf` and add to `terraform.tfvars`

### Option 3: Environment Variables

```bash
export ARM_SUBSCRIPTION_ID="your-staging-subscription-id"
export ARM_TENANT_ID="your-tenant-id"
# Azure CLI will use these for authentication
```

## Backend Configuration

This environment uses a **separate backend** in the staging Azure account:

```hcl
backend "azurerm" {
  resource_group_name  = "terraform-state-stage-rg"
  storage_account_name = "storagetfstatestageacct"
  container_name       = "tfstate"
  key                  = "azure-stage.terraform.tfstate"
}
```

### Create Backend Storage (First Time Only)

Before running Terraform, create the backend storage in your staging account:

```bash
# Login to staging account
az login
az account set --subscription "<staging-subscription-id>"

# Create resource group
az group create --name terraform-state-stage-rg --location "East US 2"

# Create storage account
az storage account create \
  --name storagetfstatestageacct \
  --resource-group terraform-state-stage-rg \
  --location "East US 2" \
  --sku Standard_LRS \
  --encryption-services blob

# Create container
az storage container create \
  --name tfstate \
  --account-name storagetfstatestageacct \
  --auth-mode login
```

## Configuration

1. Copy the example tfvars file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` with your values:
   ```hcl
   # If using service principal, add:
   subscription_id = "your-staging-subscription-id"
   client_id       = "your-service-principal-client-id"
   client_secret   = "your-service-principal-secret"
   tenant_id       = "your-azure-tenant-id"
   ```

## Deployment

### Initialize Terraform

```bash
cd environments/azure-stage
terraform init
```

If backend doesn't exist yet, you'll get an error. Create it first (see above).

### Plan the Deployment

```bash
terraform plan
```

Verify that resources will be created in the **staging subscription**.

### Apply the Configuration

```bash
terraform apply
```

Type `yes` when prompted. This will take approximately 10-15 minutes.

## Post-Deployment

### Get Cluster Credentials

```bash
az aks get-credentials --resource-group az-k8s-stage-rg --name az-k8s-stage-cluster
```

### Verify Cluster Access

```bash
kubectl get nodes
kubectl config current-context  # Should show az-k8s-stage-cluster
```

### Switch Between Clusters

```bash
# List all contexts
kubectl config get-contexts

# Switch to staging
kubectl config use-context az-k8s-stage-cluster

# Switch to production
kubectl config use-context az-k8s-prod-cluster
```

## Node Pool Details

### System Pool
- **Purpose**: Kubernetes system components
- **Size**: 1 node, Standard_B2s
- **Same specs as production** for consistency

### Production Pool (Staging Workloads)
- **Purpose**: Staging application workloads
- **Size**: 1 node, Standard_B2s
- **Taint**: `environment=production:NoSchedule` (same as prod for testing)
- **Note**: Named "prod" to maintain consistency with production environment

## Cost Information

**Estimated Monthly Cost** (student account):
- 2x Standard_B2s nodes: ~$30-40/month (with student credits)
- AKS management: Free
- **Total**: ~$30-40/month

**Note**: This is a second student account, so it has its own separate credit allocation.

## Important Notes

### Account Isolation
- This environment is **completely isolated** from azure-prod
- Different subscription, different resources, different state
- No shared resources between environments

### Naming Convention
- All resources have `-stage` suffix
- DNS prefix: `aksstage`
- Resource group: `az-k8s-stage-rg`

### Same Configuration as Production
- Intentionally mirrors production environment
- Same VM sizes (Standard_B2s)
- Same node pool structure
- Allows realistic staging testing

## Troubleshooting

### Wrong Subscription

If resources are being created in the wrong subscription:
```bash
az account show  # Check current subscription
az account set --subscription "<correct-staging-subscription-id>"
```

### Backend Already Exists Error

If the backend storage is in the wrong subscription:
1. Delete `terraform-state-stage-rg` in the wrong subscription
2. Recreate it in the correct staging subscription
3. Run `terraform init -reconfigure`

### Service Principal Permission Issues

If service principal can't create resources:
```bash
# Grant Contributor role to subscription
az role assignment create \
  --assignee <service-principal-app-id> \
  --role "Contributor" \
  --scope "/subscriptions/<staging-subscription-id>"
```

### Can't Access Backend Storage

Ensure your user/service principal has "Storage Blob Data Contributor" role:
```bash
az role assignment create \
  --assignee <your-user-or-sp> \
  --role "Storage Blob Data Contributor" \
  --scope "/subscriptions/<staging-subscription-id>/resourceGroups/terraform-state-stage-rg/providers/Microsoft.Storage/storageAccounts/storagetfstatestageacct"
```

## Maintenance

### Destroy Infrastructure

⚠️ **WARNING**: This will delete all resources in the staging environment!

```bash
terraform destroy
```

## Related Environments

- [Azure Prod](../azure-prod/README.md) - Production environment (first Azure account)
- [GCP Prod](../gcp-prod/README.md) - Production environment on Google Cloud

## Support

For issues with:
- **Authentication**: Check Azure CLI and service principal setup
- **Backend**: Ensure storage account exists in staging subscription
- **Quotas**: Each student account has independent quotas
