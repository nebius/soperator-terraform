output "jail" {
  description = "Jail filestore."
  value = {
    id        = nebius_compute_v1_filesystem.jail.id
    mount_tag = local.const.filesystem.jail
  }
}

output "controller_spool" {
  description = "Controller spool filestore."
  value = {
    id        = nebius_compute_v1_filesystem.controller_spool.id
    mount_tag = local.const.filesystem.controller_spool
  }
}

output "jail_submounts" {
  description = "Jail submount filestores."
  value = { for submount in var.jail_submounts :
    submount.name => {
      id        = nebius_compute_v1_filesystem.jail_submount[submount.name].id
      mount_tag = "${local.const.filesystem.jail_submount_prefix}-${submount.name}"
    }
  }
}
