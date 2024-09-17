locals {
  helm = {
    repository = {
      slurm = "oci://cr.ai.nebius.cloud/crnefnj17i4kqgt3up94"
    }

    chart = {
      slurm_cluster         = "slurm-cluster"
      slurm_cluster_storage = "slurm-cluster-storage"
      slurm_operator_crds   = "slurm-operator-crds"

      operator = {
        slurm = "slurm-operator"
      }
    }
  }
}
