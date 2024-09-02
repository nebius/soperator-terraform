locals {
  consts = {
    node_group = {
      control = "control"
      cpu     = "cpu"
      gpu     = "gpu"
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
      slurm   = "1.10.4"
    }
  }
}
