locals {
  consts = {
    node_group = {
      cpu = "cpu"
      gpu = "gpu"
      nlb = "nlb"
    }

    filestore = {
      jail             = "jail"
      controller_spool = "controller-spool"
    }
  }

  name = {
    node_group = {
      cpu = join("-", [
        trimsuffix(
          substr(
            var.k8s_cluster_name,
            0,
            64 - (length(local.consts.node_group.cpu) + 1)
          ),
          "-"
        ),
        local.consts.node_group.cpu
      ])

      gpu = join("-", [
        trimsuffix(
          substr(
            var.k8s_cluster_name,
            0,
            64 - (length(local.consts.node_group.gpu) + 1)
          ),
          "-"
        ),
        local.consts.node_group.gpu
      ])

      nlb = join("-", [
        trimsuffix(
          substr(
            var.k8s_cluster_name,
            0,
            64 - (length(local.consts.node_group.nlb) + 1)
          ),
          "-"
        ),
        local.consts.node_group.nlb
      ])
    }

    gpu_cluster = join("-", [
      trimsuffix(
        substr(
          var.k8s_cluster_name,
          0,
          64 - (length(var.k8s_cluster_node_group_gpu.gpu_cluster.infiniband_fabric) + 1)
        ),
        "-"
      ),
      var.k8s_cluster_node_group_gpu.gpu_cluster.infiniband_fabric
    ])
  }

  helm = {
    repository = {
      nvidia = "https://helm.ngc.nvidia.com/nvidia"
      slurm  = "oci://cr.ai.nebius.cloud/crnefnj17i4kqgt3up94"
    }

    chart = {
      slurm_cluster         = "slurm-cluster"
      slurm_cluster_storage = "slurm-cluster-storage"

      operator = {
        network = "network-operator"
        gpu     = "gpu-operator"
        slurm   = "slurm-operator"
      }
    }

    version = {
      network = "24.4.1"
      gpu     = "v24.6.1"
      slurm   = "1.11.3-9a6c3bf3"
    }
  }

  gpu = {
    create_cluster = tomap({
      "8gpu-160vcpu-1600gb" = true
      "1gpu-20vcpu-200gb"   = false
    })[var.k8s_cluster_node_group_gpu.resource.preset]

    count = tomap({
      "8gpu-160vcpu-1600gb" = 8
      "1gpu-20vcpu-200gb"   = 1
    })[var.k8s_cluster_node_group_gpu.resource.preset]
  }

  login = {
    create_nlb_ng = var.slurm_login_service_type == "NodePort" ? true : false
  }
}
