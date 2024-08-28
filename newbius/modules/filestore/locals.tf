locals {
  consts = {
    filesystem = {
      jail             = "jail"
      controller_spool = "controller-spool"
    }
  }

  name = {
    filesystem = {
      jail = join("-", [
        trimsuffix(
          substr(
            var.k8s_cluster_name,
            0,
            64 - (length(local.consts.filesystem.jail) + 1)
          ),
          "-"
        ),
        local.consts.filesystem.jail
      ])

      controller_spool = join("-", [
        trimsuffix(
          substr(
            var.k8s_cluster_name,
            0,
            64 - (length(local.consts.filesystem.controller_spool) + 1)
          ),
          "-"
        ),
        local.consts.filesystem.controller_spool
      ])
    }

    jail_submount = { for submount in var.jail_submounts :
      submount.name => join("-", [
        trimsuffix(
          substr(
            var.k8s_cluster_name,
            0,
            64 - (length("jail-submount-${submount.name}") + 1)
          ),
          "-"
        ),
        "jail-submount-${submount.name}"
      ])
    }
  }
}
