locals {
  slurm_chart_path      = "../../helm"
  slurm_chart_operator  = "slurm-operator"
  slurm_chart_filestore = "slurm-cluster-filestore"
  slurm_chart_cluster   = "slurm-cluster"

  slurm_cluster_normalized_name = trimsuffix(substr(replace(trimspace(var.slurm_cluster_name), " ", "-"), 0, 63), "-")

  unit_gb   = 1000 * 1000 * 1000
  unit_gib  = 1024 * 1024 * 1024
  unit_core = 1000
}

resource "null_resource" "entrypoint" {
  depends_on = [
    helm_release.slurm_cluster
  ]
}
