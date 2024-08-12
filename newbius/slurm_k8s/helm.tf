resource "helm_release" "operator_network" {
  depends_on = [
    nebius_mk8s_v1alpha1_node_group.cpu,
    nebius_mk8s_v1alpha1_node_group.gpu
  ]

  name       = local.name.operator.network
  repository = "oci://cr.nemax.nebius.cloud/yc-marketplace/nebius/elijahk-nvidia-${local.name.operator.network}/chart"
  chart      = local.name.operator.network
  version    = local.version.operator.network

  create_namespace = true
  namespace        = local.name.operator.network

  wait          = true
  wait_for_jobs = true
}

resource "helm_release" "operator_gpu" {
  depends_on = [
    nebius_mk8s_v1alpha1_node_group.cpu,
    nebius_mk8s_v1alpha1_node_group.gpu
  ]

  name       = local.name.operator.gpu
  repository = "oci://cr.nemax.nebius.cloud/yc-marketplace/nebius/nvidia-${local.name.operator.gpu}/chart/"
  chart      = local.name.operator.gpu
  version    = local.version.operator.gpu

  create_namespace = true
  namespace        = local.name.operator.gpu

  # Use RDMA if GPUs have InfiniBand connection
  dynamic "set" {
    for_each = local.gpu_cluster_create ? [true] : []
    content {
      name = "driver.rdma"
      value = jsonencode({
        enabled      = set.value
        useHostMofed = set.value
      })
    }
  }

  wait          = true
  wait_for_jobs = true
}

resource "helm_release" "slurm_operator" {
  depends_on = [
    helm_release.operator_network,
    helm_release.operator_gpu,
    helm_release.slurm_cluster_storage,
  ]

  name       = local.name.operator.slurm
  repository = "oci://cr.ai.nebius.cloud/crnefnj17i4kqgt3up94"
  chart      = local.name.operator.slurm
  version    = local.version.operator.slurm

  create_namespace = true
  namespace        = local.name.operator.slurm

  wait = true
}

resource "helm_release" "slurm_cluster_storage" {
  depends_on = [
    module.shared_storage,
    nebius_mk8s_v1alpha1_node_group.cpu,
    nebius_mk8s_v1alpha1_node_group.gpu
  ]

  name       = local.name.chart.slurm_cluster_storage
  repository = "oci://cr.ai.nebius.cloud/crnefnj17i4kqgt3up94"
  chart      = local.name.chart.slurm_cluster_storage
  version    = local.version.operator.slurm

  namespace        = local.name.chart.slurm_cluster_storage
  create_namespace = true

  # nodeGroup
  set {
    name = "nodeGroup"
    value = jsonencode({
      nonGpu = {
        id = nebius_mk8s_v1alpha1_node_group.cpu.id
      }
      gpu = {
        id = nebius_mk8s_v1alpha1_node_group.gpu.id
      }
    })
  }

  # volume.jail.size
  set {
    name  = "volume.jail.size"
    value = "${var.storage_jail_size_gibibytes}Gi"
  }

  # volume.controllerSpool.size
  set {
    name  = "volume.controllerSpool.size"
    value = "${var.storage_controller_spool_size_gibibytes}Gi"
  }

  # volume.jailSubMounts
  set {
    name = "volume.jailSubMounts"
    value = jsonencode([for sub_mount in var.storage_jail_sub_mounts : {
      name                = sub_mount.name
      filestoreDeviceName = sub_mount.device_name
      size                = "${sub_mount.size_gibibytes}Gi"
    }])
  }

  wait          = true
  wait_for_jobs = true
}
