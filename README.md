# E-commerce Microservices Infrastructure - Multi-Cloud Kubernetes

Infrastructure as Code (IaC) for the e-commerce microservices project using Terraform with **multi-cloud Kubernetes** (Azure AKS and Google GKE).

## Overview

This repository contains Terraform configurations to deploy Kubernetes clusters across multiple cloud providers and environments:

- **Azure Production** (AKS) - Production workloads on primary Azure student account
- **Azure Staging** (AKS) - Staging workloads on secondary Azure student account
- **GCP Production** (GKE) - Production workloads on Google Cloud trial account

Each environment is **completely isolated** with its own:
- Terraform state (separate backends)
- Cloud provider account/subscription
- Kubernetes cluster and resources
- Authentication and credentials

## Architecture

```
┌─────────────────────┬─────────────────────┬─────────────────────┐
│   Azure Prod        │   Azure Stage       │   GCP Prod          │
│  (Account 1)        │  (Account 2)        │  (Trial Account)    │
├─────────────────────┼─────────────────────┼─────────────────────┤
│ AKS Cluster         │ AKS Cluster         │ GKE Cluster         │
│ • System Pool       │ • System Pool       │ • System Pool       │
│ • Production Pool   │ • Production Pool   │ • Production Pool   │
│                     │                     │                     │
│ Standard_B2s (2GB)  │ Standard_B2s (2GB)  │ e2-medium (4GB)     │
│ Backend: Azure Blob │ Backend: Azure Blob │ Backend: GCS        │
└─────────────────────┴─────────────────────┴─────────────────────┘
```

## Project Structure

```
terraform-infra-organization/
├── environments/                   # Environment-specific configurations
│   ├── azure-prod/                # Azure Production (Account 1)
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── providers.tf
│   │   ├── terraform.tfvars.example
│   │   └── README.md
│   ├── azure-stage/               # Azure Staging (Account 2)
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── providers.tf
│   │   ├── terraform.tfvars.example
│   │   └── README.md
│   └── gcp-prod/                  # GCP Production (Trial)
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       ├── providers.tf
│       ├── terraform.tfvars.example
│       └── README.md
├── modules/                        # Reusable Terraform modules
│   ├── resource-group/            # Azure Resource Group
│   ├── aks-cluster/               # Azure AKS Cluster
│   ├── aks-node-pool/             # Azure AKS Node Pool
│   ├── gke-cluster/               # GCP GKE Cluster
│   └── gke-node-pool/             # GCP GKE Node Pool
├── gcp-terraform-key.json         # GCP service account credentials (not in git)
├── main.tf                        # Legacy root config (deprecated)
├── variables.tf                   # Legacy variables (deprecated)
├── outputs.tf                     # Legacy outputs (deprecated)
├── providers.tf                   # Legacy providers (deprecated)
└── README.md                      # This file
```

## Quick Start

### Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) (for Azure environments)
- [gcloud CLI](https://cloud.google.com/sdk/docs/install) (for GCP environment)
- Active cloud provider accounts with appropriate permissions

### Deploying an Environment

Each environment is deployed independently:

```bash
# Example: Deploy Azure Production
cd environments/azure-prod
terraform init
terraform plan
terraform apply
```

For detailed instructions, see the README in each environment directory:

- **[Azure Production README](environments/azure-prod/README.md)** - Primary Azure student account
- **[Azure Staging README](environments/azure-stage/README.md)** - Secondary Azure student account
- **[GCP Production README](environments/gcp-prod/README.md)** - Google Cloud trial account

## Environment Details

### Azure Production (environments/azure-prod/)

- **Cloud**: Microsoft Azure (Primary student account)
- **Region**: East US 2
- **Cluster**: AKS with 2 node pools
- **VMs**: Standard_B2s (2 vCPU, 2GB RAM)
- **Backend**: Azure Blob Storage (existing account)
- **Cost**: ~$30-40/month with student credits

**Use Case**: Production workloads for the e-commerce application.

[→ Read full documentation](environments/azure-prod/README.md)

### Azure Staging (environments/azure-stage/)

- **Cloud**: Microsoft Azure (Secondary student account)
- **Region**: East US 2
- **Cluster**: AKS with 2 node pools (same config as prod)
- **VMs**: Standard_B2s (2 vCPU, 2GB RAM)
- **Backend**: Azure Blob Storage (separate staging account)
- **Cost**: ~$30-40/month with separate student credits
- **Authentication**: Service Principal or Azure CLI with subscription switch

**Use Case**: Staging environment for testing before production deployment.

**Special Notes**:
- Uses a different Azure subscription
- Requires switching accounts: `az account set --subscription <staging-id>`
- Backend must be created in the staging subscription first

[→ Read full documentation](environments/azure-stage/README.md)

### GCP Production (environments/gcp-prod/)

- **Cloud**: Google Cloud Platform (Trial account)
- **Region**: us-central1
- **Cluster**: GKE with 2 node pools
- **VMs**: e2-medium (2 vCPU, 4GB RAM)
- **Backend**: Google Cloud Storage (GCS)
- **Cost**: ~$48/month (~6 months with $300 trial credit)
- **Authentication**: Service Account JSON key

**Use Case**: Production workloads with higher RAM requirements (4GB vs 2GB in Azure).

**Special Notes**:
- Requires GCP service account credentials (`gcp-terraform-key.json`)
- May need custom VPC with secondary IP ranges for pods/services
- Trial account has $300 credit valid for 90 days

[→ Read full documentation](environments/gcp-prod/README.md)

## Modules

All modules are located in the `modules/` directory and can be reused across environments.

### Azure Modules

- **[resource-group](modules/resource-group/README.md)**: Creates Azure Resource Groups
- **[aks-cluster](modules/aks-cluster/README.md)**: Creates AKS clusters with system node pool
- **[aks-node-pool](modules/aks-node-pool/README.md)**: Creates additional node pools with taints

### GCP Modules

- **[gke-cluster](modules/gke-cluster/README.md)**: Creates GKE clusters with system node pool
- **[gke-node-pool](modules/gke-node-pool/README.md)**: Creates additional node pools with taints

## Node Pool Architecture

Each Kubernetes cluster has **two node pools**:

### System Pool
- **Purpose**: Kubernetes system components (kube-system, CoreDNS, etc.)
- **Taints**: Prevents user workloads from scheduling
- **Size**: 1 node per environment
- **Auto-upgrade**: Enabled

### Production Pool
- **Purpose**: Application workloads
- **Taint**: `environment=production:NoSchedule`
- **Size**: 1 node per environment
- **Scaling**: Can be increased as needed

### Using Taints and Tolerations

To deploy pods on the production node pool, add tolerations to your Kubernetes manifests:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  template:
    spec:
      tolerations:
      - key: "environment"
        operator: "Equal"
        value: "production"
        effect: "NoSchedule"
      containers:
      - name: my-app
        image: my-app:latest
```

## Authentication & Credentials

### Azure Production (Account 1)
```bash
az login
az account set --subscription "<primary-subscription-id>"
cd environments/azure-prod
terraform init && terraform apply
```

### Azure Staging (Account 2)
```bash
az login
az account set --subscription "<staging-subscription-id>"
cd environments/azure-stage
terraform init && terraform apply
```

Or use Service Principal (recommended):
```bash
export ARM_SUBSCRIPTION_ID="<staging-subscription-id>"
export ARM_CLIENT_ID="<service-principal-id>"
export ARM_CLIENT_SECRET="<service-principal-secret>"
export ARM_TENANT_ID="<tenant-id>"
```

### GCP Production
```bash
# Authenticate with service account key
export GOOGLE_APPLICATION_CREDENTIALS="../../gcp-terraform-key.json"
cd environments/gcp-prod
terraform init && terraform apply
```

## Backend Configuration

Each environment uses its own backend for state management:

| Environment | Backend Type | Location | State File |
|-------------|-------------|----------|------------|
| Azure Prod | Azure Blob | Account 1 | azure-prod.terraform.tfstate |
| Azure Stage | Azure Blob | Account 2 | azure-stage.terraform.tfstate |
| GCP Prod | Google Cloud Storage | GCP Project | terraform/state |

**Important**: Backends must be created manually before running `terraform init`. See each environment's README for instructions.

## Cost Estimation

| Environment | Monthly Cost | Credit Source | Duration |
|-------------|--------------|---------------|----------|
| Azure Prod | ~$30-40 | Student credits | Depends on allocation |
| Azure Stage | ~$30-40 | Separate student credits | Depends on allocation |
| GCP Prod | ~$48 | $300 trial credit | ~6 months |
| **Total** | **~$110-130** | **Free with credits** | **Varies** |

**Cost Optimization Tips**:
- Use smaller VMs for dev/test (e2-small, Standard_B1s)
- Enable autoscaling
- Use preemptible/spot instances for non-critical workloads
- Delete resources when not in use
- Monitor usage via cloud provider dashboards

## Managing Multiple Kubernetes Contexts

After deploying all environments, you'll have multiple kubeconfig contexts:

```bash
# List all contexts
kubectl config get-contexts

# Switch between clusters
kubectl config use-context az-k8s-prod-cluster       # Azure Production
kubectl config use-context az-k8s-stage-cluster      # Azure Staging
kubectl config use-context gke_project-id_region_gke-prod-cluster  # GCP Production

# Check current context
kubectl config current-context

# View nodes in current cluster
kubectl get nodes
```

## Comparison: Azure vs GCP

| Feature | Azure AKS | GCP GKE |
|---------|-----------|---------|
| Machine Type | Standard_B2s | e2-medium |
| vCPUs | 2 | 2 |
| RAM | 2 GB | 4 GB |
| Cost/node | ~$15-20/month | ~$24/month |
| Management Fee | Free | $0.10/hour (~$73/month, first cluster free) |
| Student Benefits | Azure for Students | $300 trial credit |
| Node Pool Isolation | Taints + Node Selector | Taints + Node Selector |
| Auto-upgrade | Supported | Supported |

**Key Difference**: GKE provides **double the RAM** (4GB vs 2GB) for slightly higher cost.

## Troubleshooting

### Common Issues

**Backend Access Errors**
- Ensure backend storage exists before `terraform init`
- Verify authentication for the correct account/subscription
- Check IAM permissions on storage account/bucket

**Quota Exceeded**
- Azure student accounts: Limited to Standard_B series VMs
- GCP trial: Check vCPU quotas per region
- Solution: Use smaller VMs or fewer nodes

**Wrong Subscription/Project**
```bash
# Azure
az account show
az account set --subscription "<correct-id>"

# GCP
gcloud config list
gcloud config set project "<correct-project-id>"
```

**Authentication Issues**
- Azure: Run `az login` and verify subscription
- GCP: Verify service account key path and permissions

For environment-specific troubleshooting, see each environment's README.

## Best Practices

1. **State Management**
   - Always use remote backends (never local state for production)
   - Enable state locking
   - Enable versioning on backend storage

2. **Security**
   - Never commit credentials to git (use `.gitignore`)
   - Use service principals/accounts for automation
   - Rotate credentials regularly
   - Use separate accounts for different environments

3. **Resource Management**
   - Tag/label all resources with environment, project, owner
   - Implement resource naming conventions
   - Use `terraform plan` before `apply`
   - Document all changes

4. **Cost Control**
   - Monitor cloud spending regularly
   - Set up billing alerts
   - Clean up unused resources
   - Use autoscaling where appropriate

5. **Deployment**
   - Test changes in staging before production
   - Use CI/CD for infrastructure changes
   - Keep modules version-pinned
   - Document environment-specific configurations

## Migration from Root Configuration

If you have an existing deployment using the root configuration files, see the migration guide:

1. The root files (`main.tf`, `variables.tf`, `outputs.tf`, `providers.tf`) are **deprecated**
2. All infrastructure is now managed through `environments/` directories
3. Each environment is independent and can be deployed separately
4. State files are separate per environment

**To migrate**:
1. Export existing state: `terraform state pull > old-state.json`
2. Deploy new environment: `cd environments/azure-prod && terraform init && terraform plan`
3. Import existing resources if needed
4. Destroy old root infrastructure once verified

## Support & Documentation

- **General Questions**: See this README
- **Azure Production**: [environments/azure-prod/README.md](environments/azure-prod/README.md)
- **Azure Staging**: [environments/azure-stage/README.md](environments/azure-stage/README.md)
- **GCP Production**: [environments/gcp-prod/README.md](environments/gcp-prod/README.md)
- **Modules**: See individual module READMEs in `modules/` directory

## Contributing

When adding new environments or modules:
1. Follow the existing directory structure
2. Create comprehensive README documentation
3. Include `terraform.tfvars.example` files
4. Test in a separate account before committing
5. Update this main README with new information

## License

This infrastructure code is part of the e-commerce microservices project.
