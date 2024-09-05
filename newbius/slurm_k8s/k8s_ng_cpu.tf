resource "nebius_mk8s_v1_node_group" "cpu" {
  depends_on = [
    nebius_mk8s_v1_cluster.this,
  ]

  parent_id = nebius_mk8s_v1_cluster.this.id

  name = local.name.node_group.cpu
  labels = merge(
    module.labels.labels_common,
    module.labels.label_group_name_cpu
  )

  version          = var.k8s_version
  fixed_node_count = var.k8s_cluster_node_group_cpu.size

  template = {
    metadata = {
      labels = module.labels.label_group_name_cpu
    }

    resources = {
      platform = var.k8s_cluster_node_group_cpu.resource.platform
      preset   = var.k8s_cluster_node_group_cpu.resource.preset
    }

    boot_disk = {
      type       = var.k8s_cluster_node_group_cpu.boot_disk.type
      size_bytes = data.units_data_size.boot_disk_ng_cpu.bytes
    }

    filesystems = concat([{
      attach_mode = "READ_WRITE"
      mount_tag   = local.consts.filestore.jail
      existing_filesystem = {
        id = module.filestore.jail.id
      }
      }, {
      attach_mode = "READ_WRITE"
      mount_tag   = local.consts.filestore.controller_spool
      existing_filesystem = {
        id = module.filestore.controller_spool.id
      }
      }], [for submount in var.filestore_jail_submounts : {
      attach_mode = "READ_WRITE"
      mount_tag   = "jail-submount-${submount.name}"
      existing_filesystem = {
        id = module.filestore.jail_submount[submount.name].id
      }
    }])
  }
}
