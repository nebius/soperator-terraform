resource "helm_release" "slurm_operator" {
  name       = local.slurm_chart_operator
  repository = local.slurm_chart_container_registry
  chart      = local.slurm_chart_operator
  version    = var.slurm_operator_version

  depends_on = [
    module.k8s_cluster
  ]

  namespace        = local.slurm_chart_operator
  create_namespace = true

  set {
    name  = "watchNamespaces"
    value = "*"
  }

  wait = true
}
