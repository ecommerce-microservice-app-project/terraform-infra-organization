terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  # Authentication via service account key file
  credentials = file(var.credentials_file)
  project     = var.project_id
  region      = var.region
}

# Additional variables for provider configuration
variable "credentials_file" {
  description = "Path to the GCP service account credentials JSON file"
  type        = string
  default     = "../../gcp-terraform-key.json"
  # Adjust this path to where you store your credentials file
}

variable "region" {
  description = "Default GCP region"
  type        = string
  default     = "us-central1"
}
