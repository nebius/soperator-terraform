output "jail" {
  description = "Jail filestore."
  value = {
    id = nebius_compute_v1_filesystem.jail.id
  }
}

output "controller_spool" {
  description = "Controller spool filestore."
  value = {
    id = nebius_compute_v1_filesystem.controller_spool.id
  }
}

output "jail_submount" {
  description = "Jail submount filestores."
  value = { for submount in var.jail_submounts :
    submount.name => {
      id = nebius_compute_v1_filesystem.jail_submount[submount.name].id
    }
  }
}
