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
    name  = "controllerManager.manager.env.watchNamespaces"
    value = "*"
  }

  set {
    name  = "controllerManager.manager.env.isOpenTelemetryCollectorCrdInstalled"
    value = tobool(var.k8s_cluster_operator_opentelemetry_operator_enabled)
  }

  set {
    name  = "controllerManager.manager.env.isPrometheusCrdInstalled"
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
      slurm_cluster         = "helm-slurm-cluster"
      slurm_cluster_storage = "helm-slurm-cluster-storage"
      slurm_operator_crds   = "helm-soperator-crds"

      operator = {
        network = "network-operator"
        gpu     = "gpu-operator"
        slurm   = "helm-soperator"
      }
    }

    version = {
      network = "24.4.0"
      gpu     = "v24.3.0"
      slurm   = "1.14.2"
    }
  }
}

resource "helm_release" "slurm_operator_crd" {
  name       = local.helm.chart.slurm_operator_crds
  repository = local.helm.repository.slurm
  chart      = local.helm.chart.slurm_operator_crds
  version    = local.helm.version.slurm

  create_namespace = true
  namespace        = local.helm.chart.operator.slurm

  wait          = true
  wait_for_jobs = true
}
