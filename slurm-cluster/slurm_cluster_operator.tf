resource "helm_release" "slurm_operator" {
  chart   = "${local.slurm_chart_path}}/${local.slurm_chart_operator}"
  name    = "${local.slurm_chart_operator}-${var.slurm_operator_version}"
  version = var.slurm_operator_version

  depends_on = [
    module.k8s_cluster
  ]

  namespace        = local.slurm_chart_operator
  create_namespace = true

  wait = true
}
