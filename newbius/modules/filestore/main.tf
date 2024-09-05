resource "nebius_compute_v1_filesystem" "jail" {
  parent_id = var.iam_project_id

  name   = local.name.filesystem.jail
  labels = module.labels.labels_common

  type             = var.jail.disk_type
  size_bytes       = data.units_data_size.jail_storage.bytes
  block_size_bytes = data.units_data_size.jail_block.bytes
}

resource "nebius_compute_v1_filesystem" "controller_spool" {
  parent_id = var.iam_project_id

  name   = local.name.filesystem.controller_spool
  labels = module.labels.labels_common

  type             = var.controller_spool.disk_type
  size_bytes       = data.units_data_size.controller_spool_storage.bytes
  block_size_bytes = data.units_data_size.controller_spool_block.bytes
}

resource "nebius_compute_v1_filesystem" "jail_submount" {
  for_each = tomap({ for submount in var.jail_submounts :
    submount.name => {
      name    = local.name.jail_submount[submount.name]
      type    = submount.disk_type
      storage = data.units_data_size.jail_submount_storage[submount.name]
      block   = data.units_data_size.jail_submount_block[submount.name]
    }
  })

  parent_id = var.iam_project_id

  name   = each.value.name
  labels = module.labels.labels_common

  type             = each.value.type
  size_bytes       = each.value.storage.bytes
  block_size_bytes = each.value.block.bytes
}
