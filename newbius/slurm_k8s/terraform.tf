terraform {
  required_providers {
    nebius = {
      source  = "terraform-provider-nebius.storage.ai.nebius.cloud/nebius/nebius"
      version = "0.3.11"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "2.14.1"
    }

    null = {
      source  = "hashicorp/null"
      version = "3.2.2"
    }

    units = {
      source  = "dstaroff/units"
      version = "0.1.0"
    }
  }

  backend "s3" {
    bucket = "slurm-terraform-state"
    key    = "slurm.tfstate"

    endpoints = {
      s3 = var.endpoint_s3
    }
    region = "eu-north1"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}

provider "nebius" {
  domain = var.endpoint_nebius
}

provider "helm" {
  kubernetes {
    token = var.iam_token

    host                   = nebius_mk8s_v1alpha1_cluster.this.status.control_plane.endpoints.public_endpoint
    cluster_ca_certificate = nebius_mk8s_v1alpha1_cluster.this.status.control_plane.auth.cluster_ca_certificate
  }
}

module "labels" {
  source = "../modules/labels"

  custom_labels  = var.extra_labels
  k8s_cluster_id = nebius_mk8s_v1alpha1_cluster.this.id
}
