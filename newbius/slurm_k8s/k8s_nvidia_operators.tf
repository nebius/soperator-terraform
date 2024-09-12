resource "helm_release" "network_operator" {
  depends_on = [
    nebius_mk8s_v1_node_group.cpu,
    nebius_mk8s_v1_node_group.gpu,
    nebius_mk8s_v1_node_group.nlb,
  ]

  name       = local.helm.chart.operator.network
  repository = "${local.helm.repository.nvidia}/nvidia-${local.helm.chart.operator.network}/chart"
  chart      = local.helm.chart.operator.network
  version    = local.helm.version.network
  atomic     = true
  timeout    = 600

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
  repository = "${local.helm.repository.nvidia}/nvidia-${local.helm.chart.operator.gpu}/chart"
  chart      = local.helm.chart.operator.gpu
  version    = local.helm.version.gpu
  atomic     = true
  timeout    = 600

  create_namespace = true
  namespace        = local.helm.chart.operator.gpu

  values = [templatefile("${path.module}/templates/helm_values/gpu_operator.yaml.tftpl", {
    repository       = local.helm.repository.marketplace
    image_prefix     = "nebius/nvidia-gpu-operator/image"
    operator_version = local.helm.version.gpu

    enable = {
      cc_manager             = false
      dcgm                   = true
      dcgm_exporter          = true
      device_plugin          = true
      driver                 = true
      driver_rdma            = true
      driver_rdma_host_mofed = false
      gfd                    = true
      kata_manager           = false
      mig_manager            = true
      nfd                    = true
      node_status_exporter   = false
      sandbox_device_plugin  = true
      toolkit                = true
      vfio_manager           = true
      vgpu_device_manager    = true
      vgpu_manager           = false
    }
  })]

  wait          = true
  wait_for_jobs = true
}
