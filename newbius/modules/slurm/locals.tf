locals {
  helm = {
    repository = {
      slurm   = "oci://ghcr.io/nebius"
      mariadb = "https://helm.mariadb.com/mariadb-operator"
    }

    chart = {
      slurm_cluster         = "helm-slurm-cluster"
      slurm_cluster_storage = "helm-slurm-cluster-storage"
      slurm_operator_crds   = "helm-soperator-crds"

      operator = {
        slurm   = "helm-soperator"
        mariadb = "mariadb-operator"
      }
    }

    version = {
      slurm   = var.operator_version
      mariadb = "0.31.0"
    }
  }
}
