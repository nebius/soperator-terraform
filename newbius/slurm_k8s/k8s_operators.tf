resource "helm_release" "network_operator" {
  depends_on = [
    nebius_mk8s_v1_node_group.cpu,
    nebius_mk8s_v1_node_group.gpu,
    nebius_mk8s_v1_node_group.nlb,
  ]

  name       = local.helm.chart.operator.network
  repository = local.helm.repository.nvidia
  chart      = local.helm.chart.operator.network
  version    = local.helm.version.network

  create_namespace = true
  namespace        = local.helm.chart.operator.network

  wait          = true
  wait_for_jobs = true
}

resource "helm_release" "gpu-operator" {
  depends_on = [
    helm_release.network_operator
  ]

  name       = local.helm.chart.operator.gpu
  repository = local.helm.repository.nvidia
  chart      = local.helm.chart.operator.gpu
  version    = local.helm.version.gpu

  create_namespace = true
  namespace        = local.helm.chart.operator.gpu

  set {
    name  = "driver.rdma.useHostMofed"
    value = true
  }

  wait          = true
  wait_for_jobs = true
}
