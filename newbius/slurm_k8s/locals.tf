locals {
  name_suffix = {
    node_group = {
      cpu = "cpu"
      gpu = "gpu"
    }
    gpu_cluster = var.k8s_cluster_node_group_gpu.gpu_cluster.infiniband_fabric
  }

  name = {
    node_group = {
      cpu = join("-", [
        trimsuffix(
          substr(
            var.k8s_cluster_name,
            0,
            64 - (length(local.name_suffix.node_group.cpu) + 1)
          ),
          "-"
        ),
        local.name_suffix.node_group.cpu
      ])

      gpu = join("-", [
        trimsuffix(
          substr(
            var.k8s_cluster_name,
            0,
            64 - (length(local.name_suffix.node_group.gpu) + 1)
          ),
          "-"
        ),
        local.name_suffix.node_group.gpu
      ])
    }

    gpu_cluster = join("-", [
      trimsuffix(
        substr(
          var.k8s_cluster_name,
          0,
          64 - (length(local.name_suffix.gpu_cluster) + 1)
        ),
        "-"
      ),
      local.name_suffix.gpu_cluster
    ])

    operator = {
      network = "network-operator"
      gpu     = "gpu-operator"
      slurm   = "slurm-operator"
    }

    chart = {
      slurm_cluster_storage = "slurm-cluster-storage"
    }
  }

  version = {
    operator = {
      network = "24.4.0"
      gpu     = "v24.3.0"
      slurm   = "1.5.1"
    }
  }
}
