locals {
  helm = {
    repository = {
      slurm   = "oci://cr.ai.nebius.cloud/crnefnj17i4kqgt3up94"
      mariadb = "https://helm.mariadb.com/mariadb-operator"
    }

    chart = {
      slurm_cluster         = "slurm-cluster"
      slurm_cluster_storage = "slurm-cluster-storage"
      slurm_operator_crds   = "slurm-operator-crds"

      operator = {
        slurm   = "slurm-operator"
        mariadb = "mariadb-operator"
      }
    }

    version = {
      slurm   = var.operator_version
      mariadb = "0.31.0"
    }
  }
}
