# region vpc

data "nebius_vpc_v1alpha1_subnet" "this" {
  id = var.vpc_subnet_id
}

resource "nebius_vpc_v1alpha1_allocation" "this" {
  count = local.login.create_nlb_ng ? 0 : 1

  depends_on = [
    data.nebius_vpc_v1alpha1_subnet.this
  ]

  parent_id = data.nebius_iam_v1_project.this.id

  name   = "${var.slurm_cluster_name}-alloc"
  labels = module.labels.labels_common

  ipv4_public = {}
}

# endregion vpc

# region k8s

resource "nebius_mk8s_v1alpha1_cluster" "this" {
  depends_on = [
    data.nebius_vpc_v1alpha1_subnet.this,
  ]

  parent_id = data.nebius_iam_v1_project.this.id

  name   = var.k8s_cluster_name
  labels = module.labels.labels_common

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
    module.labels.labels_common,
    module.labels.label_group_name_cpu
  )

  version          = var.k8s_version
  fixed_node_count = var.k8s_cluster_node_group_cpu.size

  template = {
    metadata = {
      labels = module.labels.label_group_name_cpu
    }

    resources = {
      platform = var.k8s_cluster_node_group_cpu.resource.platform
      preset   = var.k8s_cluster_node_group_cpu.resource.preset
    }

    boot_disk = {
      type       = var.k8s_cluster_node_group_cpu.boot_disk.type
      size_bytes = data.units_data_size.ng_cpu_boot_disk.bytes
    }

    filesystems = concat([{
      attach_mode = "READ_WRITE"
      device_name = local.consts.filestore.jail
      existing_filesystem = {
        id = module.filestore.jail.id
      }
      }, {
      attach_mode = "READ_WRITE"
      device_name = local.consts.filestore.controller_spool
      existing_filesystem = {
        id = module.filestore.controller_spool.id
      }
      }], [for submount in var.filestore_jail_submounts : {
      attach_mode = "READ_WRITE"
      device_name = "jail-submount-${submount.name}"
      existing_filesystem = {
        id = module.filestore.jail_submount[submount.name].id
      }
    }])
  }
}

resource "nebius_mk8s_v1alpha1_node_group" "gpu" {
  depends_on = [
    nebius_mk8s_v1alpha1_cluster.this,
    nebius_compute_v1alpha1_gpu_cluster.this,
  ]

  parent_id = nebius_mk8s_v1alpha1_cluster.this.id

  name = local.name.node_group.gpu
  labels = merge(
    module.labels.labels_common,
    module.labels.label_group_name_gpu
  )

  version          = var.k8s_version
  fixed_node_count = var.k8s_cluster_node_group_gpu.size

  template = {
    metadata = {
      labels = module.labels.label_group_name_gpu
    }
    taints = [{
      key    = "nvidia.com/gpu",
      value  = local.gpu.count
      effect = "NO_SCHEDULE"
    }]

    resources = {
      platform = var.k8s_cluster_node_group_gpu.resource.platform
      preset   = var.k8s_cluster_node_group_gpu.resource.preset
    }
    gpu_cluster = local.gpu.create_cluster ? one(nebius_compute_v1alpha1_gpu_cluster.this) : null

    boot_disk = {
      type       = var.k8s_cluster_node_group_gpu.boot_disk.type
      size_bytes = data.units_data_size.boot_disk_gpu.bytes
    }

    filesystems = concat([{
      attach_mode = "READ_WRITE"
      device_name = local.consts.filestore.jail
      existing_filesystem = {
        id = module.filestore.jail.id
      }
      }], [for submount in var.filestore_jail_submounts : {
      attach_mode = "READ_WRITE"
      device_name = "jail-submount-${submount.name}"
      existing_filesystem = {
        id = module.filestore.jail_submount[submount.name].id
      }
    }])
  }
}

data "units_data_size" "ng_nlb_boot_disk" {
  count = local.login.create_nlb_ng ? 1 : 0

  gibibytes = "64"
}

resource "nebius_mk8s_v1alpha1_node_group" "nlb" {
  count = local.login.create_nlb_ng ? 1 : 0

  depends_on = [
    nebius_mk8s_v1alpha1_cluster.this,
  ]

  parent_id = nebius_mk8s_v1alpha1_cluster.this.id

  name = local.name.node_group.nlb
  labels = merge(
    module.labels.labels_common,
    module.labels.label_group_name_nlb
  )

  version          = var.k8s_version
  fixed_node_count = 1

  template = {
    metadata = {
      labels = module.labels.label_group_name_nlb
    }

    resources = {
      platform = "cpu-e2"
      preset   = "2vcpu-8gb"
    }

    boot_disk = {
      type       = "NETWORK_SSD"
      size_bytes = one(data.units_data_size.ng_nlb_boot_disk).bytes
    }

    network_interfaces = [{
      public_ip_address = {}
      subnet_id         = data.nebius_vpc_v1alpha1_subnet.this.id
    }]
  }
}

# endregion node group

# endregion k8s

# region compute

# region filestore

module "filestore" {
  source = "../modules/filestore"

  iam_project_id   = data.nebius_iam_v1_project.this.id
  k8s_cluster_id   = nebius_mk8s_v1alpha1_cluster.this.id
  k8s_cluster_name = var.k8s_cluster_name

  jail = {
    disk_type            = "NETWORK_SSD"
    size_gibibytes       = var.filestore_jail.size_gibibytes
    block_size_kibibytes = 32
  }

  controller_spool = {
    disk_type            = "NETWORK_SSD"
    size_gibibytes       = var.filestore_controller_spool.size_gibibytes
    block_size_kibibytes = 32
  }

  jail_submounts = [for submount in var.filestore_jail_submounts : {
    name                 = submount.name
    disk_type            = "NETWORK_SSD"
    size_gibibytes       = submount.size_gibibytes
    block_size_kibibytes = 32
  }]

  common_labels = module.labels.labels_common

  providers = {
    nebius = nebius
    units  = units
  }
}

# endregion filestore

# region gpu cluster

resource "nebius_compute_v1alpha1_gpu_cluster" "this" {
  count = local.gpu.create_cluster ? 1 : 0

  parent_id = data.nebius_iam_v1_project.this.id

  name   = local.name.gpu_cluster
  labels = module.labels.labels_common

  infiniband_fabric = var.k8s_cluster_node_group_gpu.gpu_cluster.infiniband_fabric
}

# endregion gpu cluster

# endregion compute
