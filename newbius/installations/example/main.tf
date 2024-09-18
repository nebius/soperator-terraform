locals {
  create_nlb = var.slurm_login_service_type == "NodePort"
}

module "filestore" {
  source = "../../modules/filestore"

  iam_project_id = data.nebius_iam_v1_project.this.id

  k8s_cluster_name = var.k8s_cluster_name

  controller_spool = {
    spec = {
      disk_type            = "NETWORK_SSD"
      size_gibibytes       = var.filestore_controller_spool.size_gibibytes
      block_size_kibibytes = var.filestore_controller_spool.block_size_kibibytes
    }
  }

  jail = {
    spec = {
      disk_type            = "NETWORK_SSD"
      size_gibibytes       = var.filestore_jail.size_gibibytes
      block_size_kibibytes = var.filestore_jail.block_size_kibibytes
    }
  }

  jail_submounts = [for submount in var.filestore_jail_submounts : {
    name = submount.name
    spec = {
      disk_type            = "NETWORK_SSD"
      size_gibibytes       = submount.size_gibibytes
      block_size_kibibytes = submount.block_size_kibibytes
    }
  }]

  providers = {
    nebius = nebius
    units  = units
  }
}

module "k8s" {
  depends_on = [
    module.filestore
  ]

  source = "../../modules/k8s"

  iam_project_id = data.nebius_iam_v1_project.this.id
  vpc_subnet_id  = data.nebius_vpc_v1_subnet.this.id

  name               = var.k8s_cluster_name
  slurm_cluster_name = var.slurm_cluster_name

  node_group_cpu = {
    size      = var.slurm_node_count.controller
    resource  = var.k8s_cluster_node_group_cpu.resource
    boot_disk = var.k8s_cluster_node_group_cpu.boot_disk
  }
  node_group_gpu = {
    size        = var.slurm_node_count.worker
    resource    = var.k8s_cluster_node_group_gpu.resource
    boot_disk   = var.k8s_cluster_node_group_gpu.boot_disk
    gpu_cluster = var.k8s_cluster_node_group_gpu.gpu_cluster
  }

  filestores = {
    controller_spool = {
      id        = module.filestore.controller_spool.id
      mount_tag = module.filestore.controller_spool.mount_tag
    }
    jail = {
      id        = module.filestore.jail.id
      mount_tag = module.filestore.jail.mount_tag
    }
    jail_submounts = [for key, submount in module.filestore.jail_submounts : {
      id        = submount.id
      mount_tag = submount.mount_tag
    }]
  }

  create_nlb = local.create_nlb

  providers = {
    nebius = nebius
    units  = units
  }
}

module "nvidia_operators" {
  depends_on = [
    module.k8s
  ]

  source = "../../modules/nvidia_operators"

  providers = {
    helm = helm
  }
}

module "slurm" {
  depends_on = [
    module.k8s
  ]

  source = "../../modules/slurm"

  name             = var.slurm_cluster_name
  operator_version = var.slurm_operator_version

  node_count = var.slurm_node_count

  worker_resources = tomap({
    "8gpu-128vcpu-1600gb" = {
      cpu_cores                   = 128 - 48
      memory_gibibytes            = 1600 - 400
      ephemeral_storage_gibibytes = ceil(var.k8s_cluster_node_group_gpu.boot_disk.size_gibibytes / 2)
      gpus                        = 8
    }
    "1gpu-20vcpu-200gb" = {
      cpu_cores                   = 20 - 4
      memory_gibibytes            = 200 - 50
      ephemeral_storage_gibibytes = ceil(var.k8s_cluster_node_group_gpu.boot_disk.size_gibibytes / 2)
      gpus                        = 1
    }
  })[var.k8s_cluster_node_group_gpu.resource.preset]

  login_service_type         = "NodePort"
  login_node_port            = var.slurm_login_node_port
  login_load_balancer_ip     = module.k8s.login_ip
  login_ssh_root_public_keys = var.slurm_login_ssh_root_public_keys

  exporter_enabled = var.slurm_exporter_enabled

  # TODO: MSP-2817 - use computed values of filestore sizes
  filestores = {
    controller_spool = {
      size_gibibytes = var.filestore_controller_spool.size_gibibytes
      device         = module.filestore.controller_spool.mount_tag
    }
    jail = {
      size_gibibytes = var.filestore_jail.size_gibibytes
      device         = module.filestore.jail.mount_tag
    }
    jail_submounts = [for submount in var.filestore_jail_submounts : {
      name           = submount.name
      size_gibibytes = submount.size_gibibytes
      device         = module.filestore.jail_submounts[submount.name].mount_tag
      mount_path     = submount.mount_path
    }]
  }

  nccl_topology_type           = var.k8s_cluster_node_group_gpu.resource.platform == "gpu-h100-sxm" ? "H100 GPU cluster" : "auto"
  nccl_benchmark_enable        = var.nccl_benchmark_enable
  nccl_benchmark_schedule      = var.nccl_benchmark_schedule
  nccl_benchmark_min_threshold = var.nccl_benchmark_min_threshold

  telemetry_enabled                = var.telemetry_enabled
  telemetry_grafana_admin_password = var.telemetry_grafana_admin_password

  providers = {
    helm = helm
  }
}
