locals {
  slurm_cluster_jail_size             = "${ceil(var.slurm_cluster_filestores.jail.size / local.unit_gib)}Gi"
  slurm_cluster_controller_spool_size = "${ceil(var.slurm_cluster_filestores.controller_spool.size / local.unit_gib)}Gi"
}

resource "helm_release" "slurm_cluster_filestore" {
  chart   = "${local.slurm_chart_path}}/${local.slurm_chart_filestore}"
  name    = "${local.slurm_chart_filestore}-${var.slurm_operator_version}"
  version = var.slurm_operator_version

  depends_on = [
    module.k8s_cluster,
    data.nebius_kubernetes_node_group.non_gpu,
    data.nebius_kubernetes_node_group.gpu,
    null_resource.filestore_attachment
  ]

  namespace        = local.slurm_cluster_normalized_name
  create_namespace = true

  set {
    name  = "volume.jail.name"
    value = var.slurm_cluster_filestores.jail.name
  }
  set {
    name  = "volume.jail.filestoreDeviceName"
    value = var.slurm_cluster_filestores.jail.name
  }
  set {
    name  = "volume.jail.size"
    value = local.slurm_cluster_jail_size
  }

  set {
    name  = "volume.controllerSpool.name"
    value = var.slurm_cluster_filestores.controller_spool.name
  }
  set {
    name  = "volume.controllerSpool.filestoreDeviceName"
    value = var.slurm_cluster_filestores.controller_spool.name
  }
  set {
    name  = "volume.controllerSpool.size"
    value = local.slurm_cluster_controller_spool_size
  }

  set {
    name  = "nodeGroup.gpu.id"
    value = data.nebius_kubernetes_node_group.gpu.id
  }
  set {
    name  = "nodeGroup.nonGpu.id"
    value = data.nebius_kubernetes_node_group.non_gpu.id
  }

  wait          = true
  wait_for_jobs = true
}
