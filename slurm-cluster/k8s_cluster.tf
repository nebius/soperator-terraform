locals {
  k8s_cluster_normalized_name = trimsuffix(substr(replace(trimspace(var.k8s_cluster_name), " ", "-"), 0, 63), "-")
}

resource "nebius_compute_gpu_cluster" "this" {
  name                          = "${local.k8s_cluster_normalized_name}-gpus"
  folder_id                     = var.k8s_folder_id
  zone                          = var.k8s_cluster_zone_id
  interconnect_type             = "InfiniBand"
  interconnect_physical_cluster = "fabric-1"
}

locals {
  k8s_cluster_node_group_system = {
    name = "k8s-ng-system"
    content = {
      description = "k8s system node group."
      fixed_scale = {
        size = 3
      }
      node_labels = {
        "group" = "system"
      }
    }
  }

  k8s_cluster_node_group_non_gpu = {
    name = "k8s-ng-non-gpu"
    content = {
      description = "k8s node group without GPUs."
      fixed_scale = {
        size = var.k8s_cluster_node_group_non_gpu.size
      }
      node_cores = sum([
        var.slurm_cluster_node_controller_slurmctld_resources.cpu_cores,
        var.slurm_cluster_node_controller_munge_resources.cpu_cores,
        var.slurm_cluster_node_login_sshd_resources.cpu_cores,
        var.slurm_cluster_node_login_munge_resources.cpu_cores,
        2
      ])
      node_memory = ceil(sum([
        var.slurm_cluster_node_controller_slurmctld_resources.memory_bytes,
        var.slurm_cluster_node_controller_munge_resources.memory_bytes,
        var.slurm_cluster_node_login_sshd_resources.memory_bytes,
        var.slurm_cluster_node_login_munge_resources.memory_bytes,
        2 * local.unit_gib
        ]) / local.unit_gb
      )
      disk_type = var.k8s_cluster_node_group_non_gpu.disk_type
      disk_size = max(
        ceil(sum([
          var.slurm_cluster_filestores.controller_spool.size,
          var.slurm_cluster_node_controller_slurmctld_resources.ephemeral_storage_bytes,
          var.slurm_cluster_node_controller_munge_resources.ephemeral_storage_bytes,
          var.slurm_cluster_node_login_sshd_resources.ephemeral_storage_bytes,
          var.slurm_cluster_node_login_munge_resources.ephemeral_storage_bytes,
          2 * local.unit_gib
        ]) / local.unit_gb),
        64
      )
      node_locations = [{
        zone      = var.k8s_cluster_zone_id
        subnet_id = nebius_vpc_subnet.this.id
      }]
      node_labels = {
        "group" = "non-gpu"
      }
    }
  }

  k8s_cluster_node_group_gpu = {
    name = "k8s-ng-${var.k8s_cluster_node_group_gpu.platform}-${var.k8s_cluster_node_group_gpu.gpus}gpu"
    content = {
      description = "k8s node group with Nvidia ${var.k8s_cluster_node_group_gpu.platform}-${var.k8s_cluster_node_group_gpu.size}-gpu nodes with autoscaling"
      fixed_scale = {
        size = var.k8s_cluster_node_group_gpu.size
      }
      gpu_cluster_id  = nebius_compute_gpu_cluster.this.id
      platform_id     = "gpu-${var.k8s_cluster_node_group_gpu.platform}"
      gpu_environment = "runc"
      node_gpus       = var.k8s_cluster_node_group_gpu.gpus
      disk_type       = var.k8s_cluster_node_group_gpu.disk_type
      node_cores = sum([
        var.slurm_cluster_node_worker_slurmd_resources.cpu_cores,
        var.slurm_cluster_node_worker_munge_resources.cpu_cores,
        2
      ])
      node_memory = ceil(sum([
        var.slurm_cluster_node_worker_slurmd_resources.memory_bytes,
        var.slurm_cluster_node_worker_munge_resources.memory_bytes,
        2 * local.unit_gib
        ]) / local.unit_gb
      )
      disk_type = var.k8s_cluster_node_group_non_gpu.disk_type
      disk_size = max(
        ceil(sum([
          var.slurm_cluster_filestores.jail.size,
          var.slurm_cluster_node_worker_slurmd_resources.ephemeral_storage_bytes,
          var.slurm_cluster_node_worker_munge_resources.ephemeral_storage_bytes,
          2 * local.unit_gib
        ]) / local.unit_gb),
        64
      )
      node_locations = [{
        zone      = var.k8s_cluster_zone_id
        subnet_id = nebius_vpc_subnet.this.id
      }]
      node_labels = {
        "group"                                                           = "${var.k8s_cluster_node_group_gpu.platform}-${var.k8s_cluster_node_group_gpu.gpus}gpu"
        "nebius.com/gpu"                                                  = upper(var.k8s_cluster_node_group_gpu.platform)
        "nebius.com/gpu-${var.k8s_cluster_node_group_gpu.platform}-a-llm" = upper(var.k8s_cluster_node_group_gpu.platform)
      }
    }
  }
}

module "k8s_cluster" {
  source = "github.com/nebius/terraform-nb-kubernetes.git?ref=1.0.7"

  depends_on = [
    nebius_vpc_network.this,
    nebius_vpc_subnet.this,
    nebius_compute_gpu_cluster.this,
    local.k8s_cluster_node_group_gpu
  ]

  folder_id  = var.k8s_folder_id
  network_id = nebius_vpc_network.this.id

  cluster_name    = var.k8s_cluster_name
  description     = var.k8s_cluster_description
  cluster_version = var.k8s_cluster_version

  master_locations = [{
    zone      = var.k8s_cluster_zone_id
    subnet_id = nebius_vpc_subnet.this.id
  }]
  master_maintenance_windows = var.k8s_cluster_master_maintenance_windows

  node_groups = {
    for ng in [local.k8s_cluster_node_group_system, local.k8s_cluster_node_group_non_gpu, local.k8s_cluster_node_group_gpu] :
    ng.name => ng.content
  }

  ssh_username        = var.k8s_cluster_ssh_username
  ssh_public_key      = var.k8s_cluster_ssh_public_key
  ssh_public_key_path = var.k8s_cluster_ssh_public_key_path
}

data "nebius_kubernetes_node_group" "non_gpu" {
  name = local.k8s_cluster_node_group_non_gpu.name

  depends_on = [
    module.k8s_cluster
  ]
}

data "nebius_kubernetes_node_group" "gpu" {
  name = local.k8s_cluster_node_group_gpu.name

  depends_on = [
    module.k8s_cluster
  ]
}
