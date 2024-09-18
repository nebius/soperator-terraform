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
    name  = "isOpenTelemetryCollectorCrdInstalled"
    value = tobool(var.k8s_cluster_operator_opentelemetry_operator_enabled)
  }

  set {
    name  = "isPrometheusCrdInstalled"
    value = tobool(var.k8s_monitoring_enabled)
  }

  wait = true
}

locals {
  helm = {
    repository = {
      marketplace = "cr.nemax.nebius.cloud/yc-marketplace"
      nvidia      = "oci://cr.nemax.nebius.cloud/yc-marketplace/nebius"
      slurm       = "oci://cr.ai.nebius.cloud/crnefnj17i4kqgt3up94"
    }

    chart = {
      slurm_cluster         = "slurm-cluster"
      slurm_cluster_storage = "slurm-cluster-storage"
      slurm_operator_crds   = "slurm-operator-crds"

      operator = {
        network = "network-operator"
        gpu     = "gpu-operator"
        slurm   = "slurm-operator"
      }
    }

    version = {
      network = "24.4.0"
      gpu     = "v24.3.0"
      slurm   = "1.13.5-02f41426"
    }
  }
}

resource "helm_release" "slurm_operator_crd" {
  depends_on = [
    module.k8s_cluster,
  ]
  name             = "slurm-operator-crd"
  namespace        = local.slurm_chart_operator
  repository       = local.helm.repository.slurm
  chart            = local.helm.chart.slurm_operator_crds
  version          = local.helm.version.slurm
  create_namespace = true
  values = [
    file("${path.module}${var.path_crd_file_yaml}"),
  ]

  wait          = true
  wait_for_jobs = true
}
