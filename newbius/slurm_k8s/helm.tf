resource "helm_release" "network_operator" {
  depends_on = [
    nebius_mk8s_v1alpha1_node_group.cpu,
    nebius_mk8s_v1alpha1_node_group.gpu,
  ]

  name       = local.helm.chart.operator.network
  repository = local.helm.repository.nvidia
  chart      = local.helm.chart.operator.network
  version    = local.helm.version.network

  create_namespace = true
  namespace        = local.helm.chart.operator.network

  wait          = true
  wait_for_jobs = true
}

resource "helm_release" "gpu-operator" {
  depends_on = [
    helm_release.network_operator
  ]

  name       = local.helm.chart.operator.gpu
  repository = local.helm.repository.nvidia
  chart      = local.helm.chart.operator.gpu
  version    = local.helm.version.gpu

  create_namespace = true
  namespace        = local.helm.chart.operator.gpu

  set {
    name  = "driver.rdma.useHostMofed"
    value = length(helm_release.network_operator) > 0 ? "true" : "false"
  }

  wait          = true
  wait_for_jobs = true
}

resource "helm_release" "slurm_operator" {
  depends_on = [
    nebius_mk8s_v1alpha1_node_group.cpu,
    nebius_mk8s_v1alpha1_node_group.gpu,
  ]

  name       = local.helm.chart.operator.slurm
  repository = local.helm.repository.slurm
  chart      = local.helm.chart.operator.slurm
  version    = local.helm.version.slurm

  create_namespace = true
  namespace        = local.helm.chart.operator.slurm

  wait          = true
  wait_for_jobs = true
}

resource "helm_release" "slurm_cluster_storage" {
  depends_on = [
    nebius_mk8s_v1alpha1_node_group.cpu,
    nebius_mk8s_v1alpha1_node_group.gpu,
    module.filestore,
  ]

  name       = local.helm.chart.slurm_cluster_storage
  repository = local.helm.repository.slurm
  chart      = local.helm.chart.slurm_cluster_storage
  version    = local.helm.version.slurm

  create_namespace = true
  namespace        = var.slurm_cluster_name

  values = [templatefile("${path.module}/templates/slurm_cluster_storage_values.yaml.tftpl", {
    scheduling = {
      key = module.labels.key_node_group_name
      cpu = local.consts.node_group.cpu
      gpu = local.consts.node_group.gpu
    }
    volume = {
      jail = {
        size                  = "${var.filestore_jail.size_gibibytes}Gi"
        filestore_device_name = local.consts.filestore.jail
      }
      controller_spool = {
        size                  = "${var.filestore_controller_spool.size_gibibytes}Gi"
        filestore_device_name = local.consts.filestore.controller_spool
      }
      jail_submounts = [for submount in var.filestore_jail_submounts : {
        name                  = submount.name
        size                  = "${submount.size_gibibytes}Gi"
        filestore_device_name = "jail-submount-${submount.name}"
      }]
    }
  })]

  wait          = true
  wait_for_jobs = true
}

resource "helm_release" "slurm_cluster" {
  depends_on = [
    helm_release.network_operator,
    helm_release.gpu-operator,
    helm_release.slurm_operator,
    helm_release.slurm_cluster_storage,
  ]

  name       = local.helm.chart.slurm_cluster
  repository = local.helm.repository.slurm
  chart      = local.helm.chart.slurm_cluster
  version    = local.helm.version.slurm

  create_namespace = true
  namespace        = var.slurm_cluster_name

  values = [templatefile("${path.module}/templates/slurm_cluster_values.yaml.tftpl", {
    name = var.slurm_cluster_name

    k8s_node_filters = {
      non_gpu = {
        name = local.consts.node_group.cpu
        affinity = {
          key   = module.labels.key_node_group_name
          value = local.consts.node_group.cpu
        }
      }
      gpu = {
        name = local.consts.node_group.gpu
        affinity = {
          key   = module.labels.key_node_group_name
          value = local.consts.node_group.gpu
        }
      }
    },

    jail_submounts = [for submount in var.filestore_jail_submounts : {
      name       = submount.name
      mount_path = submount.mount_path
    }]

    ncclBenchmark = {
      use_infiniband = local.gpu_cluster_create
    }

    nodes = {
      controller = {
        size = nebius_mk8s_v1alpha1_node_group.cpu.fixed_node_count
      }
      worker = {
        size = nebius_mk8s_v1alpha1_node_group.gpu.fixed_node_count
        resources = tomap({
          "8gpu-160vcpu-1600gb" = {
            cpu               = 156
            memory            = 1220
            ephemeral_storage = 64
            gpus              = 8
          }
          "1gpu-20vcpu-200gb" = {
            cpu               = 18
            memory            = 150
            ephemeral_storage = 16
            gpus              = 1
          }
        })[var.k8s_cluster_node_group_gpu.resource.preset]
        shared_memory = var.slurm_shared_memory_size_gibibytes
      }
      login = {
        size             = nebius_mk8s_v1alpha1_node_group.cpu.fixed_node_count
        load_balancer_ip = regexall("[\\d\\.]+", nebius_vpc_v1alpha1_allocation.this.status.details.allocated_cidr)[0]
        root_public_keys = var.slurm_ssh_root_public_keys
      }
    }
  })]

  wait          = true
  wait_for_jobs = true
}
