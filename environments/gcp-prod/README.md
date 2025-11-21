# GCP Production Environment

This environment deploys a GKE (Google Kubernetes Engine) cluster for **production workloads** using a GCP trial account.

## Architecture

- **Cloud Provider**: Google Cloud Platform (GCP)
- **Region**: us-central1
- **Cluster Type**: GKE (Google Kubernetes Engine)
- **Node Pools**:
  - System Pool: 1x e2-medium (Kubernetes system components)
  - Production Pool: 1x e2-medium (Production workloads with taint)

## Machine Type Comparison

| Azure | GCP | vCPUs | RAM | Approximate Cost |
|-------|-----|-------|-----|------------------|
| Standard_B2s | e2-medium | 2 | 4 GB | ~$24/month |

GCP `e2-medium` provides **more RAM** (4GB vs 2GB) than Azure Standard_B2s for similar pricing.

## Prerequisites

1. **gcloud CLI** installed and configured
   ```bash
   gcloud --version
   ```

2. **Terraform** >= 1.0
   ```bash
   terraform version
   ```

3. **GCP Account** with active trial ($300 credit)

4. **GCP Project** created

5. **Service Account** with Terraform credentials

## Initial GCP Setup

### 1. Create GCP Project (if not done)

```bash
gcloud projects create your-project-id --name="Ecommerce K8s"
gcloud config set project your-project-id
```

### 2. Enable Required APIs

```bash
gcloud services enable container.googleapis.com
gcloud services enable compute.googleapis.com
gcloud services enable storage-api.googleapis.com
```

### 3. Create Service Account for Terraform

```bash
# Create service account
gcloud iam service-accounts create terraform \
  --display-name="Terraform Service Account"

# Grant necessary roles
gcloud projects add-iam-policy-binding your-project-id \
  --member="serviceAccount:terraform@your-project-id.iam.gserviceaccount.com" \
  --role="roles/container.admin"

gcloud projects add-iam-policy-binding your-project-id \
  --member="serviceAccount:terraform@your-project-id.iam.gserviceaccount.com" \
  --role="roles/compute.admin"

gcloud projects add-iam-policy-binding your-project-id \
  --member="serviceAccount:terraform@your-project-id.iam.gserviceaccount.com" \
  --role="roles/iam.serviceAccountUser"

# Create and download key
gcloud iam service-accounts keys create ../../gcp-terraform-key.json \
  --iam-account=terraform@your-project-id.iam.gserviceaccount.com
```

**Important**: Keep `gcp-terraform-key.json` secure and never commit it to git!

### 4. Create Backend Storage (GCS Bucket)

```bash
# Create GCS bucket for Terraform state
gsutil mb -p your-project-id -l us-central1 gs://terraform-state-gcp-prod

# Enable versioning (recommended)
gsutil versioning set on gs://terraform-state-gcp-prod
```

## Network Configuration

### Option 1: Use Default Network (Simpler for Trial)

The default configuration uses GCP's default VPC network. This is simpler but **may not support** secondary IP ranges for pods/services in all regions.

If you encounter errors about IP ranges, use Option 2.

### Option 2: Create Custom VPC (Recommended)

```bash
# Create custom VPC
gcloud compute networks create gke-vpc --subnet-mode=custom

# Create subnet with secondary ranges
gcloud compute networks subnets create gke-subnet \
  --network=gke-vpc \
  --region=us-central1 \
  --range=10.0.0.0/24 \
  --secondary-range pods=10.1.0.0/16 \
  --secondary-range services=10.2.0.0/16
```

Then update `terraform.tfvars`:
```hcl
network            = "gke-vpc"
subnetwork         = "gke-subnet"
pods_range_name    = "pods"
services_range_name = "services"
```

## Configuration

1. Copy the example tfvars file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` with your values:
   ```hcl
   project_id       = "your-gcp-project-id"  # REQUIRED
   credentials_file = "../../gcp-terraform-key.json"

   # Optionally customize:
   cluster_name = "gke-prod-cluster"
   location     = "us-central1"  # Regional cluster (more expensive but HA)
   # OR
   # location = "us-central1-a"  # Zonal cluster (cheaper)
   ```

## Deployment

### Initialize Terraform

```bash
cd environments/gcp-prod
terraform init
```

This will:
- Initialize the GCS backend
- Download the Google provider

### Plan the Deployment

```bash
terraform plan
```

Review the plan to ensure:
- 1 GKE Cluster will be created
- 2 Node Pools will be created (system + production)

**Check**: Verify resources are being created in your project ID!

### Apply the Configuration

```bash
terraform apply
```

Type `yes` when prompted. This will take approximately 10-15 minutes.

## Post-Deployment

### Get Cluster Credentials

```bash
gcloud container clusters get-credentials gke-prod-cluster \
  --location us-central1 \
  --project your-project-id
```

Or use the output command:
```bash
terraform output get_kubectl_config_command
```

### Verify Cluster Access

```bash
kubectl get nodes
kubectl get namespaces
```

You should see 2 nodes:
- `gke-...-system-...` (system pool)
- `gke-...-prod-...` (production pool)

### Check Node Taints

```bash
kubectl get nodes -o json | jq '.items[].spec.taints'
```

Production nodes should have: `environment=production:NO_SCHEDULE`

## Node Pool Details

### System Pool
- **Purpose**: Kubernetes system components
- **Size**: 1 node, e2-medium (2 vCPU, 4GB RAM)
- **Taint**: GKE system taints (prevents user workloads)
- **Auto-upgrade**: Enabled
- **Auto-repair**: Enabled

### Production Pool
- **Purpose**: Production application workloads
- **Size**: 1 node, e2-medium (2 vCPU, 4GB RAM)
- **Taint**: `environment=production:NO_SCHEDULE`
- **Tolerations Required**: Pods must have this toleration:
  ```yaml
  tolerations:
  - key: "environment"
    operator: "Equal"
    value: "production"
    effect: "NoSchedule"
  ```

## Cost Information

**Estimated Monthly Cost** (with trial credits):
- GKE cluster management: $0.10/hour (~$73/month) - **First cluster free for trial**
- 2x e2-medium nodes: ~$24/month each = ~$48/month
- **Total**: ~$48/month (cluster management likely free during trial)

**Trial Credit**: $300 valid for 90 days = **~6 months of runtime**

### Cost Optimization Tips

1. **Use Zonal Cluster** (not regional):
   ```hcl
   location = "us-central1-a"  # Single zone
   ```
   Saves ~50% on cluster management fees

2. **Use Smaller Machines**:
   ```hcl
   machine_type = "e2-small"  # 2 vCPU, 2GB RAM (~$13/month)
   ```

3. **Use Preemptible Nodes** (up to 80% cheaper):
   ```hcl
   preemptible = true
   ```
   Note: Nodes can be terminated at any time (max 24 hours)

4. **Auto-scaling** (only pay for what you use):
   ```hcl
   autoscaling_enabled = true
   min_node_count      = 1
   max_node_count      = 3
   ```

## Trial Account Limitations

- **vCPU Quota**: Typically 8-12 vCPUs per region (enough for this setup)
- **Regional Restrictions**: Some regions may not be available
- **No Sustained Use Discounts**: Trial accounts don't get discounts
- **Credit Expiration**: $300 expires after 90 days

Check your quotas:
```bash
gcloud compute project-info describe --project=your-project-id | grep -A 2 "CPUS"
```

## Maintenance

### Scale Node Pool

Edit `terraform.tfvars`:
```hcl
prod_node_pool = {
  machine_type = "e2-medium"
  node_count   = 2  # Changed from 1
  disk_size_gb = 50
}
```

Then apply:
```bash
terraform apply
```

### Upgrade Cluster

GKE auto-upgrades are enabled by default. To manually upgrade:
```bash
gcloud container clusters upgrade gke-prod-cluster \
  --location us-central1 \
  --cluster-version latest
```

### Destroy Infrastructure

⚠️ **WARNING**: This will delete all resources in this environment!

```bash
terraform destroy
```

## Troubleshooting

### API Not Enabled Error

Enable required APIs:
```bash
gcloud services enable container.googleapis.com compute.googleapis.com
```

### Quota Exceeded Error

Check quotas:
```bash
gcloud compute project-info describe --project=your-project-id
```

Request quota increase or use smaller machines/fewer nodes.

### Secondary IP Range Errors

If using default network, you may need to create a custom VPC with secondary ranges (see Network Configuration above).

### Authentication Issues

Verify service account key:
```bash
gcloud auth activate-service-account --key-file=../../gcp-terraform-key.json
gcloud projects list  # Should show your project
```

### Backend Access Issues

Verify GCS bucket exists:
```bash
gsutil ls -p your-project-id
```

Ensure service account has Storage Admin role:
```bash
gcloud projects add-iam-policy-binding your-project-id \
  --member="serviceAccount:terraform@your-project-id.iam.gserviceaccount.com" \
  --role="roles/storage.admin"
```

## Monitoring Costs

Check your trial credit usage:
```bash
gcloud billing accounts list
gcloud billing projects describe your-project-id
```

Or visit: https://console.cloud.google.com/billing

## Related Environments

- [Azure Prod](../azure-prod/README.md) - Production environment on Azure (first account)
- [Azure Stage](../azure-stage/README.md) - Staging environment on Azure (second account)

## Support

For issues with:
- **GCP Setup**: Check GCP trial documentation
- **Terraform**: Check [main README](../../README.md)
- **Kubernetes**: Check GKE documentation
- **Billing**: Visit GCP Console billing section
