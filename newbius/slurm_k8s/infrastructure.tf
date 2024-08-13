data "nebius_vpc_v1alpha1_subnet" "this" {
  id = var.vpc_subnet_id
}

# region k8s

resource "nebius_mk8s_v1alpha1_cluster" "this" {
  depends_on = [
    data.nebius_vpc_v1alpha1_subnet.this,
  ]

  parent_id = data.nebius_iam_v1_project.this.id

  name   = var.k8s_cluster_name
  labels = module.labels.common

  control_plane = {
    subnet_id = data.nebius_vpc_v1alpha1_subnet.this.id

    version = var.k8s_version
    endpoints = {
      public_endpoint = {}
    }
  }
}

# region node group

resource "nebius_mk8s_v1alpha1_node_group" "cpu" {
  depends_on = [
    nebius_mk8s_v1alpha1_cluster.this,
  ]

  parent_id = nebius_mk8s_v1alpha1_cluster.this.id

  name = local.name.node_group.cpu
  labels = merge(
    module.labels.common_with_k8s_id,
    module.labels.group_name_cpu
  )

  version          = var.k8s_version
  fixed_node_count = var.k8s_cluster_node_group_cpu.size

  template = {
    resources = {
      platform = var.k8s_cluster_node_group_cpu.resource.platform
      preset   = var.k8s_cluster_node_group_cpu.resource.preset
    }

    network_interfaces = [{
      public_ip_address = {}
      subnet_id         = data.nebius_vpc_v1alpha1_subnet.this.id
    }]
    underlay_required = false

    boot_disk = {
      type       = var.k8s_cluster_node_group_cpu.boot_disk.type
      size_bytes = data.units_data_size.boot_disk_cpu.bytes
    }

    filesystems = [{
      attach_mode = "READ_WRITE"
      device_name = "filestore-device"
      existing_filesystem = {
        id = module.shared_storage.filestore_id
      }
    }]
  }
}

locals {
  gpu_cluster_create = var.k8s_cluster_node_group_gpu.resource.preset == "1gpu-20vcpu-200gb" ? false : true
}

resource "nebius_mk8s_v1alpha1_node_group" "gpu" {
  depends_on = [
    nebius_mk8s_v1alpha1_cluster.this,
    nebius_compute_v1alpha1_gpu_cluster.this,
  ]

  parent_id = nebius_mk8s_v1alpha1_cluster.this.id

  name = local.name.node_group.gpu
  labels = merge(
    module.labels.common_with_k8s_id,
    module.labels.group_name_gpu,
  )

  version          = var.k8s_version
  fixed_node_count = var.k8s_cluster_node_group_gpu.size

  template = {
    resources = {
      platform = var.k8s_cluster_node_group_gpu.resource.platform
      preset   = var.k8s_cluster_node_group_gpu.resource.preset
    }
    gpu_cluster = local.gpu_cluster_create ? one(nebius_compute_v1alpha1_gpu_cluster.this) : null

    network_interfaces = [{
      public_ip_address = {}
      subnet_id         = data.nebius_vpc_v1alpha1_subnet.this.id
    }]
    underlay_required = false

    boot_disk = {
      type       = var.k8s_cluster_node_group_gpu.boot_disk.type
      size_bytes = data.units_data_size.boot_disk_gpu.bytes
    }

    filesystems = [{
      attach_mode = "READ_WRITE"
      device_name = "filestore-device"
      existing_filesystem = {
        id = module.shared_storage.filestore_id
      }
    }]

    taints = [{
      key    = "slurm.nebius.ai/taint"
      value  = "gpu"
      effect = "NO_SCHEDULE"
    }]
  }
}

# endregion node group

# endregion k8s

# region compute

# region filestore

module "shared_storage" {
  source = "../modules/shared_storage"

  iam_project_id   = data.nebius_iam_v1_project.this.id
  k8s_cluster_name = var.k8s_cluster_name

  filestore_create = var.filestore_create
  filestore_create_spec = {
    disk_type            = "NETWORK_SSD"
    size_gibibytes       = var.filestore_size_gibibytes
    block_size_kibibytes = 32
  }

  filestore_labels = module.labels.common_with_k8s_id

  filestore_existing_id = var.filestore_existing_id

  providers = {
    nebius = nebius
    units  = units
  }
}

# endregion filestore

# region gpu cluster

resource "nebius_compute_v1alpha1_gpu_cluster" "this" {
  count = local.gpu_cluster_create ? 1 : 0

  parent_id = data.nebius_iam_v1_project.this.id

  name   = local.name.gpu_cluster
  labels = module.labels.common_with_k8s_id

  infiniband_fabric = var.k8s_cluster_node_group_gpu.gpu_cluster.infiniband_fabric
}

# endregion gpu cluster

# endregion compute
