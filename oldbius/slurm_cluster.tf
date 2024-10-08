locals {
  slurm_cluster_k8s_node_filters = {
    gpu     = "gpu"
    non_gpu = "non-gpu"
  }
  otel_collector_http_host = "vmsingle-slurm.${local.monitoring_namespace}.svc.cluster.local"
  otel_collector_path      = "/opentelemetry/api/v1/push"
  otel_collector_port      = 8429
}

locals {
  slurm_cluster_values_yaml = templatefile("${path.module}/slurm_cluster_values.yaml.tpl", {
    slurm_cluster_k8s_node_filters = local.slurm_cluster_k8s_node_filters,
    unit_gb                        = local.unit_gb,
    unit_gib                       = local.unit_gib,
    unit_core                      = local.unit_core,

    otelCollectorHttpHost = local.otel_collector_http_host
    otelCollectorPath     = local.otel_collector_path
    otelCollectorPort     = local.otel_collector_port
    monitoring            = var.k8s_monitoring_enabled

    kube_node_group_gpu              = data.nebius_kubernetes_node_group.gpu,
    kube_node_group_non_gpu          = data.nebius_kubernetes_node_group.non_gpu,
    nebius_vpc_external_ipv4_address = nebius_vpc_address.this.external_ipv4_address,

    slurm_cluster_name                                = var.slurm_cluster_name,
    slurm_cluster_storages                            = var.slurm_cluster_storages,
    slurm_cluster_jail_snapshot                       = var.slurm_cluster_jail_snapshot,
    slurm_cluster_nccl_settings                       = var.slurm_cluster_nccl_settings,
    slurm_cluster_nccl_benchmark_schedule             = var.slurm_cluster_nccl_benchmark_schedule,
    slurm_cluster_nccl_benchmark_settings             = var.slurm_cluster_nccl_benchmark_settings,
    slurm_cluster_nccl_benchmark_drain_nodes          = var.slurm_cluster_nccl_benchmark_drain_nodes,
    slurm_cluster_node_controller_count               = var.slurm_cluster_node_controller_count,
    slurm_cluster_node_controller_slurmctld_resources = var.slurm_cluster_node_controller_slurmctld_resources,
    slurm_cluster_node_controller_munge_resources     = var.slurm_cluster_node_controller_munge_resources,
    slurm_cluster_node_worker_count                   = var.slurm_cluster_node_worker_count,
    slurm_cluster_node_worker_slurmd_resources        = var.slurm_cluster_node_worker_slurmd_resources,
    slurm_cluster_node_worker_munge_resources         = var.slurm_cluster_node_worker_munge_resources,
    slurm_cluster_worker_volume_spool_size            = var.slurm_cluster_worker_volume_spool_size,
    slurm_cluster_node_login_count                    = var.slurm_cluster_node_login_count,
    slurm_cluster_node_login_sshd_resources           = var.slurm_cluster_node_login_sshd_resources,
    slurm_cluster_node_login_munge_resources          = var.slurm_cluster_node_login_munge_resources,
    slurm_cluster_ssh_root_public_keys                = var.slurm_cluster_ssh_root_public_keys,
    slurm_cluster_login_sshd_keys_secret_name         = var.slurm_cluster_login_sshd_keys_secret_name,
    k8s_cluster_node_group_gpu                        = var.k8s_cluster_node_group_gpu,
    shared_memory_size                                = var.shared_memory_size,
    slurm_cluster_exporter_enabled                    = var.slurm_cluster_exporter_enabled
  })
}

resource "helm_release" "slurm_cluster" {
  count = var.slurm_cluster_create_cr ? 1 : 0

  name       = local.slurm_chart_cluster
  repository = local.slurm_chart_container_registry
  chart      = local.slurm_chart_cluster
  version    = var.slurm_operator_version

  depends_on = [
    helm_release.slurm_operator,
    helm_release.slurm_cluster_storage,
    helm_release.k8s_cluster_operator_network,
    helm_release.k8s_cluster_operator_gpu
  ]

  namespace        = local.slurm_cluster_normalized_name
  create_namespace = true

  # language=yamls
  values = [local.slurm_cluster_values_yaml]

  wait          = true
  wait_for_jobs = true
}
