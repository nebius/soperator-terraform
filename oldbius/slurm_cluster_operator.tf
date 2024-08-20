resource "helm_release" "slurm_operator" {
  name       = local.slurm_chart_operator
  repository = local.slurm_chart_container_registry
  chart      = local.slurm_chart_operator
  version    = var.slurm_operator_version

  depends_on = [
    module.k8s_cluster,
    helm_release.slurm_operator_crd,
  ]

  namespace        = local.slurm_chart_operator
  create_namespace = true

  set {
    name  = "watchNamespaces"
    value = "*"
  }

  set {
    name  = "opentelemetryOperator.enabled"
    value = tobool(var.k8s_cluster_operator_opentelemetry_operator_enabled)
  }

  wait = true
}

resource "helm_release" "slurm_operator_crd" {
  depends_on = [
    module.k8s_cluster,
  ]
  name       = "slurm-operator-crd"
  namespace  = local.slurm_chart_operator
  repository = "https://bedag.github.io/helm-charts/"
  chart      = "raw"
  version    = "2.0.0"
  values = [
    file("${path.module}${var.path_crd_file_yaml}"),
  ]
}
