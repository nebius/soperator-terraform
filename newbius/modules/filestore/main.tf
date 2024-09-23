resource "nebius_compute_v1_filesystem" "controller_spool" {
  count = var.controller_spool.spec != null ? 1 : 0

  parent_id = var.iam_project_id

  name = local.name.filesystem.controller_spool

  type             = var.controller_spool.spec.disk_type
  size_bytes       = provider::units::from_gib(var.controller_spool.spec.size_gibibytes)
  block_size_bytes = provider::units::from_kib(var.controller_spool.spec.block_size_kibibytes)
}
data "nebius_compute_v1_filesystem" "controller_spool" {
  count = var.controller_spool.existing != null ? 1 : 0

  id = var.controller_spool.existing.id
}
locals {
  controller_spool = {
    id = try(
      one(nebius_compute_v1_filesystem.controller_spool).id,
      one(data.nebius_compute_v1_filesystem.controller_spool).id,
    )
    size_gibibytes = floor(provider::units::to_gib(try(
      one(nebius_compute_v1_filesystem.controller_spool).status.size_bytes,
      one(data.nebius_compute_v1_filesystem.controller_spool).status.size_bytes,
    )))
    mount_tag = local.const.filesystem.controller_spool
  }
}

resource "nebius_compute_v1_filesystem" "jail" {
  count = var.jail.spec != null ? 1 : 0

  parent_id = var.iam_project_id

  name = local.name.filesystem.jail

  type             = var.jail.spec.disk_type
  size_bytes       = provider::units::from_gib(var.jail.spec.size_gibibytes)
  block_size_bytes = provider::units::from_kib(var.jail.spec.block_size_kibibytes)
}
data "nebius_compute_v1_filesystem" "jail" {
  count = var.jail.existing != null ? 1 : 0

  id = var.jail.existing.id
}
locals {
  jail = {
    id = try(
      one(nebius_compute_v1_filesystem.jail).id,
      one(data.nebius_compute_v1_filesystem.jail).id,
    )
    size_gibibytes = floor(provider::units::to_gib(try(
      one(nebius_compute_v1_filesystem.jail).status.size_bytes,
      one(data.nebius_compute_v1_filesystem.jail).status.size_bytes,
    )))
    mount_tag = local.const.filesystem.jail
  }
}

resource "nebius_compute_v1_filesystem" "jail_submount" {
  for_each = tomap({ for submount in var.jail_submounts :
    submount.name => {
      name    = local.name.jail_submount[submount.name]
      type    = submount.spec.disk_type
      storage = provider::units::from_gib(submount.spec.size_gibibytes)
      block   = provider::units::from_kib(submount.spec.block_size_kibibytes)
    }
    if submount.spec != null
  })

  parent_id = var.iam_project_id

  name = each.value.name

  type             = each.value.type
  size_bytes       = each.value.storage
  block_size_bytes = each.value.block
}
data "nebius_compute_v1_filesystem" "jail_submount" {
  for_each = tomap({ for submount in var.jail_submounts :
    submount.name => submount.existing.id
    if submount.existing != null
  })

  id = each.value
}
locals {
  jail_submount = merge(
    tomap({ for submount in var.jail_submounts :
      submount.name => {
        id             = nebius_compute_v1_filesystem.jail_submount[submount.name].id
        size_gibibytes = floor(provider::units::to_gib(nebius_compute_v1_filesystem.jail_submount[submount.name].status.size_bytes))
        mount_tag      = "${local.const.filesystem.jail_submount_prefix}-${submount.name}"
      }
      if submount.spec != null
    }),
    tomap({ for submount in var.jail_submounts :
      submount.name => {
        id             = data.nebius_compute_v1_filesystem.jail_submount[submount.name].id
        size_gibibytes = floor(provider::units::to_gib(data.nebius_compute_v1_filesystem.jail_submount[submount.name].status.size_bytes))
        mount_tag      = "${local.const.filesystem.jail_submount_prefix}-${submount.name}"
      }
      if submount.existing != null
    }),
  )
}
