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
  count = 0

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

  values = [templatefile("${path.module}/templates/slurm_cluster_storage_values.yaml.tpl", {})]

  set {
    name  = "volume.jail.size"
    value = "${var.filestore_jail.size_gibibytes}Gi"
  }

  wait          = true
  wait_for_jobs = true
}

resource "helm_release" "slurm_cluster" {
  count = 0

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

  values = [templatefile("${path.module}/templates/slurm_cluster_values.yaml.tpl", {
    slurm_cluster_k8s_node_filters = {
      gpu     = "gpu"
      non_gpu = "cpu"
    },

    slurmd_resources = var.k8s_cluster_node_group_gpu.resource.preset == "8gpu-160vcpu-1600gb" ? {
      # 8gpu-160vcpu-1600gb
      cpu               = 156
      memory            = 1220
      ephemeral_storage = 55
      gpus              = 8
      } : {
      # 1gpu-20vcpu-200gb
      cpu               = 18
      memory            = 150
      ephemeral_storage = 55
      gpus              = 1
    }
  })]

  set {
    name  = "clusterName"
    value = var.slurm_cluster_name
  }

  set {
    name  = "slurmNodes.controller.size"
    value = nebius_mk8s_v1alpha1_node_group.cpu.fixed_node_count
  }

  set {
    name  = "slurmNodes.worker.size"
    value = nebius_mk8s_v1alpha1_node_group.gpu.fixed_node_count
  }

  set {
    name  = "slurmNodes.login.size"
    value = nebius_mk8s_v1alpha1_node_group.cpu.fixed_node_count
  }

  set {
    name  = "slurmNodes.login.sshdServiceLoadBalancerIP"
    value = regexall("[\\d\\.]+", nebius_vpc_v1alpha1_allocation.this.status.details.allocated_cidr)[0]
  }

  wait          = true
  wait_for_jobs = true
}
