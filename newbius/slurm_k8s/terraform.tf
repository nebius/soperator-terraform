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
