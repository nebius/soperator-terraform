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
        cluster_id   = "cluster-id"
        cluster_name = "cluster-name"
        group_name   = "group-name"
      }
    }

    value = {
      ng_cpu = var.ng_name_cpu
      ng_gpu = var.ng_name_gpu
      ng_nlb = var.ng_name_nlb

      terraform = "terraform"
      slurm     = "slurm"
    }
  }

  label_key = {
    k8s_cluster_id     = "${local.consts.k8s.label.domain.mk8s}/${local.consts.k8s.label.cluster_id}"
    k8s_cluster_name   = "${local.consts.k8s.label.domain.mk8s}/${local.consts.k8s.label.cluster_name}"
    slurm_cluster_name = "${local.consts.k8s.label.domain.slurm}/${local.consts.k8s.label.cluster_name}"
    slurm_group_name   = "${local.consts.k8s.label.domain.slurm}/${local.consts.k8s.label.group_name}"
  }

  label = {
    managed_by = tomap({
      (local.consts.compute.label.managed_by) = (local.consts.value.terraform)
    })

    used_for = tomap({
      (local.consts.compute.label.used_for) = (local.consts.value.slurm)
    })

    group_name = {
      cpu = tomap({
        (local.label_key.slurm_group_name) = (local.consts.value.ng_cpu)
      })

      gpu = tomap({
        (local.label_key.slurm_group_name) = (local.consts.value.ng_gpu)
      })

      nlb = tomap({
        (local.label_key.slurm_group_name) = (local.consts.value.ng_nlb)
      })
    }
  }
}
