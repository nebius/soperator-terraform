terraform {
  required_providers {
    nebius = {
      source  = "terraform-provider-nebius.storage.ai.nebius.cloud/nebius/nebius"
      version = "0.3.18"
    }

    null = {
      source = "hashicorp/null"
    }

    units = {
      source = "dstaroff/units"
    }

    helm = {
      source = "hashicorp/helm"
    }
  }

  backend "s3" {
    bucket = "slurm-terraform-state"
    key    = "slurm.tfstate"

    endpoints = {
      s3 = "https://storage.eu-north1.nebius.cloud:443"
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
    host                   = nebius_mk8s_v1_cluster.this.status.control_plane.endpoints.public_endpoint
    cluster_ca_certificate = nebius_mk8s_v1_cluster.this.status.control_plane.auth.cluster_ca_certificate
    token                  = var.iam_token
  }
}

provider "units" {}

variable "extra_labels" {
  description = "Additional labels used for all created resources."
  type        = map(string)
  default     = {}
}

module "labels" {
  source = "../modules/labels"

  custom_labels = var.extra_labels

  ng_name_cpu = local.consts.node_group.cpu
  ng_name_gpu = local.consts.node_group.gpu
  ng_name_nlb = local.consts.node_group.nlb
}
