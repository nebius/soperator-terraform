locals {
  k8s_cluster_operator_chart_gpu     = "gpu-operator"
  k8s_cluster_operator_chart_network = "network-operator"
}

resource "helm_release" "k8s_cluster_operator_gpu" {
  name       = local.k8s_cluster_operator_chart_gpu
  repository = "oci://cr.nemax.nebius.cloud/yc-marketplace/nebius/${local.k8s_cluster_operator_chart_gpu}/chart/"
  chart      = local.k8s_cluster_operator_chart_gpu
  version    = var.k8s_cluster_operator_gpu_version

  depends_on = [
    module.k8s_cluster
  ]

  namespace        = local.k8s_cluster_operator_chart_gpu
  create_namespace = true

  set {
    name  = "toolkit.enabled"
    value = tostring(var.k8s_cluster_operator_gpu_cuda_toolkit)
  }

  set {
    name  = "driver.version"
    value = var.k8s_cluster_operator_gpu_driver_version
  }

  set {
    name  = "driver.rdma.enabled"
    value = tostring(var.k8s_cluster_operator_gpu_driver_rdma)
  }

  wait          = true
  wait_for_jobs = true
}

resource "helm_release" "k8s_cluster_operator_network" {
  name       = local.k8s_cluster_operator_chart_network
  repository = "oci://cr.nemax.nebius.cloud/yc-marketplace/nebius/${local.k8s_cluster_operator_chart_network}/chart/"
  chart      = local.k8s_cluster_operator_chart_network
  version    = var.k8s_cluster_operator_network_version

  depends_on = [
    module.k8s_cluster
  ]

  namespace        = local.k8s_cluster_operator_chart_network
  create_namespace = true

  wait          = true
  wait_for_jobs = true
}
