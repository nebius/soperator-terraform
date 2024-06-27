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
  k8s_cluster_gpu_node_groups = {
    for i, ng in var.k8s_cluster_gpu_node_groups :
    "k8s-ng-${ng.platform}-${ng.gpus}gpu-${i}" =>
    {
      description = "k8s node group with Nvidia ${ng.platform}-${ng.size}-gpu nodes with autoscaling"
      fixed_scale = {
        size = ng.size
      }
      gpu_cluster_id  = nebius_compute_gpu_cluster.this.id
      platform_id     = "gpu-${ng.platform}"
      gpu_environment = "runc"
      node_cores      = ng.cores
      node_memory     = ng.memory
      node_gpus       = ng.gpus
      disk_type       = ng.disk_type
      disk_size       = ng.disk_size
      node_labels = {
        "group"                               = "${ng.platform}-${ng.gpus}gpu"
        "nebius.com/gpu"                      = upper(ng.platform)
        "nebius.com/gpu-${ng.platform}-a-llm" = upper(ng.platform)
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
    local.k8s_cluster_gpu_node_groups
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

  node_groups = merge(
    {
      "k8s-ng-system" = {
        description = "k8s system node group."
        fixed_scale = {
          size = 3
        }
        node_labels = {
          "group" = "system"
        }
      },
    },
    local.k8s_cluster_gpu_node_groups
  )

  ssh_username        = var.k8s_cluster_ssh_username
  ssh_public_key      = var.k8s_cluster_ssh_public_key
  ssh_public_key_path = var.k8s_cluster_ssh_public_key_path
}
