terraform {
  required_version = ">=1.8.0"

  required_providers {
    nebius = {
      source  = "terraform-provider-nebius.storage.ai.nebius.cloud/nebius/nebius"
      version = "0.3.22"
    }

    units = {
      source  = "dstaroff/units"
      version = ">=1.1.1"
    }

    helm = {
      source = "hashicorp/helm"
    }
  }
}

provider "nebius" {
  domain = "api.nemax-sandbox.nebiuscloud.net:443"
}

provider "units" {}

provider "helm" {
  kubernetes {
    host                   = module.k8s.control_plane.public_endpoint
    cluster_ca_certificate = module.k8s.control_plane.cluster_ca_certificate
    token                  = var.iam_token
  }
}
