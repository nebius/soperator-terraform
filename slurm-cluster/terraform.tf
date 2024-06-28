terraform {
  required_version = ">= 1.0.0"

  required_providers {
    nebius = {
      source  = "terraform-registry.storage.ai.nebius.cloud/nebius/nebius"
      version = ">= 0.9.0"
    }

    local = {
      source  = "hashicorp/local"
      version = ">= 2.2.3"
    }
  }
}

provider "nebius" {
  endpoint  = "api.nemax.nebius.cloud:443"
  folder_id = var.k8s_folder_id
}

data "nebius_client_config" "client" {}

provider "helm" {
  kubernetes {
    host                   = module.k8s_cluster.external_v4_endpoint
    cluster_ca_certificate = module.k8s_cluster.cluster_ca_certificate
    token                  = data.nebius_client_config.client.iam_token
  }
}
