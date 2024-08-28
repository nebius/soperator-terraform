locals {
  consts = {
    compute = {
      label = {
        managed_by = "managed-by"
        used_for   = "used-for"
      }
    }

    k8s = {
      label = {
        domain = {
          slurm = "slurm.nebius.ai"
          mk8s  = "mk8s.nebius.ai"
        }
        cluster_id = "cluster-id"
        group_name = "group-name"
      }
    }

    value = {
      ng_control = var.ng_name_control
      ng_cpu     = var.ng_name_cpu
      ng_gpu     = var.ng_name_gpu

      terraform = "terraform"
      slurm     = "slurm"
    }
  }

  label_key = {
    group_name = "${local.consts.k8s.label.domain.slurm}/${local.consts.k8s.label.group_name}"
  }

  label = {
    managed_by = tomap({
      (local.consts.compute.label.managed_by) = (local.consts.value.terraform)
    })

    used_for = tomap({
      (local.consts.compute.label.used_for) = (local.consts.value.slurm)
    })

    group_name = {
      control = tomap({
        (local.label_key.group_name) = (local.consts.value.ng_control)
      })

      cpu = tomap({
        (local.label_key.group_name) = (local.consts.value.ng_cpu)
      })

      gpu = tomap({
        (local.label_key.group_name) = (local.consts.value.ng_gpu)
      })
    }
  }
}
