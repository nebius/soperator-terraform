resource "helm_release" "slurm_cluster_crd" {
  depends_on = [
    nebius_mk8s_v1_node_group.cpu,
    nebius_mk8s_v1_node_group.gpu,
    nebius_mk8s_v1_node_group.nlb,
  ]

  name       = local.helm.chart.slurm_operator_crds
  repository = local.helm.repository.slurm
  chart      = local.helm.chart.slurm_operator_crds
  version    = local.helm.version.slurm

  create_namespace = true
  namespace        = local.helm.chart.operator.slurm

  wait          = true
  wait_for_jobs = true
}

resource "helm_release" "slurm_cluster_storage" {
  depends_on = [
    nebius_mk8s_v1_node_group.cpu,
    nebius_mk8s_v1_node_group.gpu,
    nebius_mk8s_v1_node_group.nlb,
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
      key = module.labels.key_slurm_node_group_name
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

resource "helm_release" "slurm_operator" {
  depends_on = [
    helm_release.slurm_cluster_crd,
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

resource "helm_release" "slurm_cluster" {
  depends_on = [
    helm_release.network_operator,
    helm_release.gpu-operator,
    helm_release.slurm_operator,
    helm_release.slurm_cluster_crd,
    helm_release.slurm_cluster_storage,
    nebius_vpc_v1alpha1_allocation.this,
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
          key   = module.labels.key_slurm_node_group_name
          value = local.consts.node_group.cpu
        }
      }
      gpu = {
        name = local.consts.node_group.gpu
        affinity = {
          key   = module.labels.key_slurm_node_group_name
          value = local.consts.node_group.gpu
        }
      }
    },

    jail_submounts = [for submount in var.filestore_jail_submounts : {
      name       = submount.name
      mount_path = submount.mount_path
    }]

    nccl_topology_type = var.k8s_cluster_node_group_gpu.resource.platform == "gpu-h100-sxm" ? "H100 GPU cluster" : "auto"
    ncclBenchmark = {
      use_infiniband = local.gpu.create_cluster
    }

    nodes = {
      controller = {
        size = nebius_mk8s_v1_node_group.cpu.fixed_node_count
      }
      worker = {
        size = nebius_mk8s_v1_node_group.gpu.fixed_node_count
        # TODO make better use of ephemeral storage
        resources = tomap({
          "8gpu-128vcpu-1600gb" = {
            cpu               = 128 - 48
            memory            = 1600 - 400
            ephemeral_storage = ceil(data.units_data_size.boot_disk_ng_gpu.gibibytes / 2)
            gpus              = 8
          }
          "1gpu-20vcpu-200gb" = {
            cpu               = 20 - 4
            memory            = 200 - 50
            ephemeral_storage = ceil(data.units_data_size.boot_disk_ng_gpu.gibibytes / 2)
            gpus              = 1
          }
        })[var.k8s_cluster_node_group_gpu.resource.preset]
        shared_memory = var.slurm_shared_memory_size_gibibytes
      }
      login = {
        size             = nebius_mk8s_v1_node_group.cpu.fixed_node_count
        service_type     = var.slurm_login_service_type
        load_balancer_ip = local.login.create_nlb_ng ? "" : regexall("[\\d\\.]+", one(nebius_vpc_v1alpha1_allocation.this).status.details.allocated_cidr)[0]
        node_port        = var.slurm_login_node_port
        root_public_keys = var.slurm_login_ssh_root_public_keys
      }
    }
  })]

  wait          = true
  wait_for_jobs = true
}

resource "nebius_vpc_v1alpha1_allocation" "this" {
  count = local.login.create_nlb_ng ? 0 : 1

  depends_on = [
    data.nebius_vpc_v1alpha1_subnet.this,
    nebius_mk8s_v1_cluster.this,
  ]

  parent_id = data.nebius_iam_v1_project.this.id

  name = "${var.k8s_cluster_name}-${var.slurm_cluster_name}"
  labels = merge(
    module.labels.labels_common,
    tomap({
      (module.labels.key_k8s_cluster_id)     = (nebius_mk8s_v1_cluster.this.id)
      (module.labels.key_k8s_cluster_name)   = (nebius_mk8s_v1_cluster.this.name)
      (module.labels.key_slurm_cluster_name) = (var.slurm_cluster_name)
    })
  )

  ipv4_public = {}
}
