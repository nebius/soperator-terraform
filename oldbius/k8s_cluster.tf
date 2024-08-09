locals {
  k8s_cluster_normalized_name = trimsuffix(substr(replace(trimspace(var.k8s_cluster_name), " ", "-"), 0, 63), "-")
}

locals {
  create_gpu_cluster = (var.k8s_cluster_node_group_gpu.platform == "h100" || var.k8s_cluster_node_group_gpu.platform == "h100-a-llm") ? {
    "create" = true
  } : {}
}

resource "nebius_compute_gpu_cluster" "this" {
  for_each                      = local.create_gpu_cluster
  name                          = "${local.k8s_cluster_normalized_name}-gpus"
  folder_id                     = var.k8s_folder_id
  zone                          = var.k8s_cluster_zone_id
  interconnect_type             = var.k8s_cluster_node_group_gpu.interconnect_type
  interconnect_physical_cluster = var.k8s_cluster_node_group_gpu.interconnect_physical_cluster
}

locals {
  k8s_cluster_node_group_non_gpu = {
    name = var.k8s_cluster_node_group_non_gpu.name
    content = {
      description = "k8s node group without GPUs."
      fixed_scale = {
        size = var.k8s_cluster_node_group_non_gpu.size
      }
      node_cores  = var.k8s_cluster_node_group_non_gpu.cpu_cores
      node_memory = var.k8s_cluster_node_group_non_gpu.memory_gb
      disk_type   = var.k8s_cluster_node_group_non_gpu.disk_type
      disk_size   = var.k8s_cluster_node_group_non_gpu.disk_size_gb
      node_locations = [{
        zone      = var.k8s_cluster_zone_id
        subnet_id = nebius_vpc_subnet.this.id
      }]
      node_labels = {}
    }
  }

  k8s_cluster_node_group_gpu = {
    name = "k8s-ng-${var.k8s_cluster_node_group_gpu.platform}-${var.k8s_cluster_node_group_gpu.gpus}gpu"
    content = {
      description = "k8s node group with Nvidia ${var.k8s_cluster_node_group_gpu.platform}-${var.k8s_cluster_node_group_gpu.gpus}-gpu nodes with autoscaling"
      fixed_scale = {
        size = var.k8s_cluster_node_group_gpu.size
      }
      preemptible = var.k8s_cluster_node_group_gpu.preemptible
      gpu_cluster_id = (
        var.k8s_cluster_node_group_gpu.platform == "h100" ||
        var.k8s_cluster_node_group_gpu.platform == "h100-a-llm"
      ) ? nebius_compute_gpu_cluster.this["create"].id : null
      platform_id     = "gpu-${var.k8s_cluster_node_group_gpu.platform}"
      gpu_environment = "runc"
      node_cores      = var.k8s_cluster_node_group_gpu.cpu_cores
      node_memory     = var.k8s_cluster_node_group_gpu.memory_gb
      node_gpus       = var.k8s_cluster_node_group_gpu.gpus
      disk_type       = var.k8s_cluster_node_group_gpu.disk_type
      disk_size       = var.k8s_cluster_node_group_gpu.disk_size_gb
      node_locations = [{
        zone      = var.k8s_cluster_zone_id
        subnet_id = nebius_vpc_subnet.this.id
      }]
      node_taints = [
        "nvidia.com/gpu=:NoSchedule",
      ]
      node_labels = {
        "cloud.google.com/gke-accelerator" = var.k8s_cluster_node_group_gpu.gke_accelerator
        "driver.config"                    = var.k8s_cluster_node_group_gpu.driver_config
      }
    }
  }
}

module "k8s_cluster" {
  source = "github.com/nebius/terraform-nb-kubernetes.git?ref=1.0.7"

  depends_on = [
    local.k8s_cluster_network_id,
    nebius_vpc_subnet.this,
    nebius_compute_gpu_cluster.this,
    local.k8s_cluster_node_group_gpu
  ]

  folder_id  = var.k8s_folder_id
  network_id = local.k8s_cluster_network_id

  cluster_name    = var.k8s_cluster_name
  description     = var.k8s_cluster_description
  cluster_version = var.k8s_cluster_version

  master_locations = [{
    zone      = var.k8s_cluster_zone_id
    subnet_id = nebius_vpc_subnet.this.id
  }]
  master_maintenance_windows = var.k8s_cluster_master_maintenance_windows

  node_groups = {
    for ng in [local.k8s_cluster_node_group_non_gpu, local.k8s_cluster_node_group_gpu] :
    ng.name => ng.content
  }

  enable_cilium_policy = true
  pod_mtu              = null

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
