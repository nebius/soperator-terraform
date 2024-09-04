resource "nebius_compute_v1alpha1_gpu_cluster" "this" {
  count = local.gpu.create_cluster ? 1 : 0

  parent_id = data.nebius_iam_v1_project.this.id

  name   = local.name.gpu_cluster
  labels = module.labels.labels_common

  infiniband_fabric = var.k8s_cluster_node_group_gpu.gpu_cluster.infiniband_fabric
}

resource "nebius_mk8s_v1alpha1_node_group" "gpu" {
  depends_on = [
    nebius_mk8s_v1alpha1_cluster.this,
    nebius_compute_v1alpha1_gpu_cluster.this,
  ]

  parent_id = nebius_mk8s_v1alpha1_cluster.this.id

  name = local.name.node_group.gpu
  labels = merge(
    module.labels.labels_common,
    module.labels.label_group_name_gpu
  )

  version          = var.k8s_version
  fixed_node_count = var.k8s_cluster_node_group_gpu.size

  template = {
    metadata = {
      labels = module.labels.label_group_name_gpu
    }
    taints = [{
      key    = "nvidia.com/gpu",
      value  = local.gpu.count
      effect = "NO_SCHEDULE"
    }]

    resources = {
      platform = var.k8s_cluster_node_group_gpu.resource.platform
      preset   = var.k8s_cluster_node_group_gpu.resource.preset
    }
    gpu_cluster = local.gpu.create_cluster ? one(nebius_compute_v1alpha1_gpu_cluster.this) : null

    boot_disk = {
      type       = var.k8s_cluster_node_group_gpu.boot_disk.type
      size_bytes = data.units_data_size.boot_disk_ng_gpu.bytes
    }

    filesystems = concat([{
      attach_mode = "READ_WRITE"
      device_name = local.consts.filestore.jail
      existing_filesystem = {
        id = module.filestore.jail.id
      }
      }], [for submount in var.filestore_jail_submounts : {
      attach_mode = "READ_WRITE"
      device_name = "jail-submount-${submount.name}"
      existing_filesystem = {
        id = module.filestore.jail_submount[submount.name].id
      }
    }])
  }
}
