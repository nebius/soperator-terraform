resource "nebius_compute_v1_filesystem" "controller_spool" {
  parent_id = var.iam_project_id

  name = local.name.filesystem.controller_spool

  type             = var.controller_spool.disk_type
  size_bytes       = provider::units::from_gib(var.controller_spool.size_gibibytes)
  block_size_bytes = provider::units::from_kib(var.controller_spool.block_size_kibibytes)
}

resource "nebius_compute_v1_filesystem" "jail" {
  parent_id = var.iam_project_id

  name = local.name.filesystem.jail

  type             = var.jail.disk_type
  size_bytes       = provider::units::from_gib(var.jail.size_gibibytes)
  block_size_bytes = provider::units::from_kib(var.jail.block_size_kibibytes)
}

resource "nebius_compute_v1_filesystem" "jail_submount" {
  for_each = tomap({ for submount in var.jail_submounts :
    submount.name => {
      name    = local.name.jail_submount[submount.name]
      type    = submount.disk_type
      storage = provider::units::from_gib(submount.size_gibibytes)
      block   = provider::units::from_kib(submount.block_size_kibibytes)
    }
  })

  parent_id = var.iam_project_id

  name = each.value.name

  type             = each.value.type
  size_bytes       = each.value.storage
  block_size_bytes = each.value.block
}
