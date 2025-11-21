# Azure Development Environment

This environment manages the existing AKS (Azure Kubernetes Service) cluster for **development workloads** using the primary Azure student account.

## Architecture

- **Cloud Provider**: Microsoft Azure (Primary student account)
- **Region**: East US 2
- **Cluster Type**: AKS (Azure Kubernetes Service)
- **Node Pools**:
  - System Pool: 1x Standard_B2s (Kubernetes system components)
  - Production Pool: 1x Standard_B2s (Development workloads with taint)

## Important: Migrated from Root Configuration

This environment **replaces** the root configuration files (main.tf, variables.tf, etc. in the project root). It manages the **same infrastructure** that was previously managed by those files.

**Key Points**:
- Uses the **same backend state**: `ecommerce.terraform.tfstate`
- Uses the **same resource names**: `az-k8s-cluster`, `az-k8s-rg`, etc.
- **No infrastructure changes** when migrating from root to this environment

## Prerequisites

1. **Azure CLI** installed and configured
2. **Terraform** >= 1.0
3. **Azure Account** with active subscription (primary student account)
4. **Backend Storage** (already exists):
   - Resource Group: `terraform-state-rg`
   - Storage Account: `storagetfstateaccount`
   - Container: `tfstate`
   - State Key: `ecommerce.terraform.tfstate`

## First Time Setup (Migration from Root)

If you're migrating from the root configuration:

```bash
cd environments/azure-dev
terraform init
terraform plan  # Should show: No changes
```

You should see: `No changes. Infrastructure is up-to-date.`

## Related Environments

- **[Azure Stage](../azure-stage/README.md)** - Staging environment (second Azure account)
- **[GCP Prod](../gcp-prod/README.md)** - Production environment on Google Cloud
