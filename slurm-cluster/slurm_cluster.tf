locals {
  slurm_cluster_k8s_node_filters = {
    gpu     = "gpu"
    non_gpu = "non-gpu"
  }
}

resource "helm_release" "slurm_cluster" {
  chart   = "${local.slurm_chart_path}/${local.slurm_chart_cluster}"
  name    = "${local.slurm_chart_cluster}-${var.slurm_operator_version}"
  version = var.slurm_operator_version

  depends_on = [
    helm_release.slurm_operator,
    helm_release.slurm_cluster_filestore,
    helm_release.k8s_cluster_operator_network,
    helm_release.k8s_cluster_operator_gpu
  ]

  namespace        = local.slurm_cluster_normalized_name
  create_namespace = true

  # language=yamls
  values = [<<EOF
clusterName: "slurm"

k8sNodeFilters:
  - name: "${local.slurm_cluster_k8s_node_filters.gpu}"
    affinity:
      nodeAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
          nodeSelectorTerms:
            - matchExpressions:
                - key: "nebius.com/node-group-id"
                  operator: In
                  values:
                    - "${data.nebius_kubernetes_node_group.gpu.id}"
    tolerations:
      - key: nvidia.com/gpu
        operator: Exists
        effect: NoSchedule

  - name: "${local.slurm_cluster_k8s_node_filters.non_gpu}"
    affinity:
      nodeAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
          nodeSelectorTerms:
            - matchExpressions:
                - key: "nebius.com/node-group-id"
                  operator: In
                  values:
                    - "${data.nebius_kubernetes_node_group.non_gpu.id}"

volumeSources:
  - name: "${var.slurm_cluster_filestores.jail.name}"
    persistentVolumeClaim:
      claimName: "${var.slurm_cluster_filestores.jail.name}-pvc"
      readOnly: false

  - name: "${var.slurm_cluster_filestores.controller_spool.name}"
    persistentVolumeClaim:
      claimName: "${var.slurm_cluster_filestores.controller_spool.name}-pvc"
      readOnly: false

secrets:
  mungeKey:
    create: true
  sshRootPublicKeys:
    create: true
    keys:
      %{~for ssh_key in var.slurm_cluster_ssh_root_public_keys~}
      - "${ssh_key}"
      %{~endfor~}

populateJail:
  k8sNodeFilterName: "${local.slurm_cluster_k8s_node_filters.gpu}"

periodicChecks:
  ncclBenchmark:
    enabled: true
    schedule: "${var.slurm_cluster_nccl_benchmark_schedule}"
    ncclSettings:
      minBytes: "${var.slurm_cluster_nccl_benchmark_settings.min_bytes}"
      maxBytes: "${var.slurm_cluster_nccl_benchmark_settings.max_bytes}"
      stepFactor: "${var.slurm_cluster_nccl_benchmark_settings.step_factor}"
      timeout: "${var.slurm_cluster_nccl_benchmark_settings.timeout}"
      thresholdMoreThan: "${var.slurm_cluster_nccl_benchmark_settings.threshold_more_than}"
    failureActions:
      setSlurmNodeDrainState: ${var.slurm_cluster_nccl_benchmark_drain_nodes}
    k8sNodeFilterName: "${local.slurm_cluster_k8s_node_filters.non_gpu}"

slurmNodes:
  controller:
    size: ${var.slurm_cluster_node_controller_count}
    k8sNodeFilterName: "${local.slurm_cluster_k8s_node_filters.non_gpu}"
    slurmctld:
      resources:
        cpu: "${ceil(var.slurm_cluster_node_controller_slurmctld_resources.cpu_cores * local.unit_core)}m"
        memory: "${ceil(var.slurm_cluster_node_controller_slurmctld_resources.memory_bytes / local.unit_gib)}Gi"
        ephemeral-storage: "${ceil(var.slurm_cluster_node_controller_slurmctld_resources.ephemeral_storage_bytes / local.unit_gib)}Gi"
    munge:
      resources:
        cpu: "${ceil(var.slurm_cluster_node_controller_munge_resources.cpu_cores * local.unit_core)}m"
        memory: "${ceil(var.slurm_cluster_node_controller_munge_resources.memory_bytes / local.unit_gib)}Gi"
        ephemeral-storage: "${ceil(var.slurm_cluster_node_controller_munge_resources.ephemeral_storage_bytes / local.unit_gib)}Gi"
    volumes:
      spool:
        volumeSourceName: "${var.slurm_cluster_filestores.controller_spool.name}"
      jail:
        volumeSourceName: "${var.slurm_cluster_filestores.jail.name}"
  worker:
    size: ${var.slurm_cluster_node_worker_count}
    k8sNodeFilterName: "${local.slurm_cluster_k8s_node_filters.gpu}"
    slurmd:
      resources:
        cpu: "${ceil(var.slurm_cluster_node_worker_slurmd_resources.cpu_cores * local.unit_core)}m"
        memory: "${ceil(var.slurm_cluster_node_worker_slurmd_resources.memory_bytes / local.unit_gib)}Gi"
        ephemeral-storage: "${ceil(var.slurm_cluster_node_worker_slurmd_resources.ephemeral_storage_bytes / local.unit_gib)}Gi"
        nvidia.com/gpu: ${var.k8s_cluster_node_group_gpu.gpus}
    munge:
      resources:
        cpu: "${ceil(var.slurm_cluster_node_worker_munge_resources.cpu_cores * local.unit_core)}m"
        memory: "${ceil(var.slurm_cluster_node_worker_munge_resources.memory_bytes / local.unit_gib)}Gi"
        ephemeral-storage: "${ceil(var.slurm_cluster_node_worker_munge_resources.ephemeral_storage_bytes / local.unit_gib)}Gi"
    volumes:
      spool:
        volumeClaimTemplateSpec:
          storageClassName: "nebius-network-ssd"
          accessModes: [ "ReadWriteOnce" ]
          resources:
            requests:
              storage: "${ceil(var.slurm_cluster_worker_volume_spool_size / local.unit_gib)}Gi"
      jail:
        volumeSourceName: "${var.slurm_cluster_filestores.jail.name}"
      jailSubMounts: []
  login:
    size: ${var.slurm_cluster_node_login_count}
    k8sNodeFilterName: "${local.slurm_cluster_k8s_node_filters.non_gpu}"
    sshd:
      resources:
        cpu: "${ceil(var.slurm_cluster_node_login_sshd_resources.cpu_cores * local.unit_core)}m"
        memory: "${ceil(var.slurm_cluster_node_login_sshd_resources.memory_bytes / local.unit_gib)}Gi"
        ephemeral-storage: "${ceil(var.slurm_cluster_node_login_sshd_resources.ephemeral_storage_bytes / local.unit_gib)}Gi"
    sshdServiceType: "LoadBalancer"
    sshdServiceLoadBalancerIP: "${one(nebius_vpc_address.this.external_ipv4_address).address}"
    munge:
      resources:
        cpu: "${ceil(var.slurm_cluster_node_login_munge_resources.cpu_cores * local.unit_core)}m"
        memory: "${ceil(var.slurm_cluster_node_login_munge_resources.memory_bytes / local.unit_gib)}Gi"
        ephemeral-storage: "${ceil(var.slurm_cluster_node_login_munge_resources.ephemeral_storage_bytes / local.unit_gib)}Gi"
    volumes:
      jail:
        volumeSourceName: "${var.slurm_cluster_filestores.jail.name}"
      jailSubMounts: []
EOF
  ]

  wait          = true
  wait_for_jobs = true
}
