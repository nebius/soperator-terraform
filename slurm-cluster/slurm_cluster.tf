resource "helm_release" "slurm_cluster" {
  chart   = "${local.slurm_chart_path}/${local.slurm_chart_cluster}"
  name    = "${local.slurm_chart_cluster}-${var.slurm_operator_version}"
  version = var.slurm_operator_version

  depends_on = [
    helm_release.slurm_operator,
    helm_release.slurm_cluster_filestore,
  ]

  namespace        = local.slurm_cluster_name
  create_namespace = true

  set {
    name  = ""
    value = ""
  }

  set {
    name  = ""
    value = ""
  }

  wait          = true
  wait_for_jobs = true
}
