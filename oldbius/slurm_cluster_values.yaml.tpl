clusterName: "${slurm_cluster_name}"

k8sNodeFilters:
  - name: "${slurm_cluster_k8s_node_filters.gpu}"
    affinity:
      nodeAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
          nodeSelectorTerms:
            - matchExpressions:
                - key: "nebius.com/node-group-id"
                  operator: In
                  values:
                    - "${kube_node_group_gpu.id}"
    tolerations:
      - key: nvidia.com/gpu
        operator: Exists
        effect: NoSchedule

  - name: "${slurm_cluster_k8s_node_filters.non_gpu}"
    affinity:
      nodeAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
          nodeSelectorTerms:
            - matchExpressions:
                - key: "nebius.com/node-group-id"
                  operator: In
                  values:
                    - "${kube_node_group_non_gpu.id}"

volumeSources:
  - name: "${slurm_cluster_storages.jail.name}"
    persistentVolumeClaim:
      claimName: "${slurm_cluster_storages.jail.name}-pvc"
      readOnly: false

  - name: "${slurm_cluster_storages.controller_spool.name}"
    persistentVolumeClaim:
      claimName: "${slurm_cluster_storages.controller_spool.name}-pvc"
      readOnly: false

  %{ if slurm_cluster_jail_snapshot != null }
  - name: "${slurm_cluster_jail_snapshot.name}"
    persistentVolumeClaim:
      claimName: "${slurm_cluster_jail_snapshot.name}-pvc"
      readOnly: true
  %{ endif }

  %{ for storage in slurm_cluster_storages.jail_submounts }
  - name: "${storage.name}"
    persistentVolumeClaim:
      claimName: "${storage.name}-pvc"
      readOnly: false
  %{ endfor }

secrets:
  sshdKeysName: "${slurm_cluster_login_sshd_keys_secret_name}"

populateJail:
  k8sNodeFilterName: "${slurm_cluster_k8s_node_filters.gpu}"
  %{ if slurm_cluster_jail_snapshot != null }
  jailSnapshotVolume:
    volumeSourceName: "${slurm_cluster_jail_snapshot.name}"
  %{ endif }
  overwrite: false

ncclSettings:
  topologyType: "${slurm_cluster_nccl_settings.topology_type}"
  topologyData: "${slurm_cluster_nccl_settings.topology_data}"

periodicChecks:
  ncclBenchmark:
    enabled: true
    schedule: "${slurm_cluster_nccl_benchmark_schedule}"
    ncclArguments:
      minBytes: "${slurm_cluster_nccl_benchmark_settings.min_bytes}"
      maxBytes: "${slurm_cluster_nccl_benchmark_settings.max_bytes}"
      stepFactor: "${slurm_cluster_nccl_benchmark_settings.step_factor}"
      timeout: "${slurm_cluster_nccl_benchmark_settings.timeout}"
      thresholdMoreThan: "${slurm_cluster_nccl_benchmark_settings.threshold_more_than}"
      useInfiniband: "${slurm_cluster_nccl_benchmark_settings.use_infiniband}"
    failureActions:
      setSlurmNodeDrainState: ${slurm_cluster_nccl_benchmark_drain_nodes}
    k8sNodeFilterName: "${slurm_cluster_k8s_node_filters.non_gpu}"

slurmNodes:
  controller:
    size: ${slurm_cluster_node_controller_count}
    k8sNodeFilterName: "${slurm_cluster_k8s_node_filters.non_gpu}"
    slurmctld:
      resources:
        cpu: "${ceil(slurm_cluster_node_controller_slurmctld_resources.cpu_cores * unit_core)}m"
        memory: "${ceil(slurm_cluster_node_controller_slurmctld_resources.memory_bytes / unit_gib)}Gi"
        ephemeralStorage: "${ceil(slurm_cluster_node_controller_slurmctld_resources.ephemeral_storage_bytes / unit_gib)}Gi"
    munge:
      resources:
        cpu: "${ceil(slurm_cluster_node_controller_munge_resources.cpu_cores * unit_core)}m"
        memory: "${ceil(slurm_cluster_node_controller_munge_resources.memory_bytes / unit_gib)}Gi"
        ephemeralStorage: "${ceil(slurm_cluster_node_controller_munge_resources.ephemeral_storage_bytes / unit_gib)}Gi"
    volumes:
      spool:
        volumeSourceName: "${slurm_cluster_storages.controller_spool.name}"
      jail:
        volumeSourceName: "${slurm_cluster_storages.jail.name}"
  worker:
    size: ${slurm_cluster_node_worker_count}
    k8sNodeFilterName: "${slurm_cluster_k8s_node_filters.gpu}"
    cgroupVersion: v1
    slurmd:
      resources:
        cpu: "${ceil(slurm_cluster_node_worker_slurmd_resources.cpu_cores * unit_core)}m"
        memory: "${ceil(slurm_cluster_node_worker_slurmd_resources.memory_bytes / unit_gib)}Gi"
        ephemeralStorage: "${ceil(slurm_cluster_node_worker_slurmd_resources.ephemeral_storage_bytes / unit_gib)}Gi"
        gpu: "${k8s_cluster_node_group_gpu.gpus}"
    munge:
      resources:
        cpu: "${ceil(slurm_cluster_node_worker_munge_resources.cpu_cores * unit_core)}m"
        memory: "${ceil(slurm_cluster_node_worker_munge_resources.memory_bytes / unit_gib)}Gi"
        ephemeralStorage: "${ceil(slurm_cluster_node_worker_munge_resources.ephemeral_storage_bytes / unit_gib)}Gi"
    volumes:
      spool:
        volumeClaimTemplateSpec:
          storageClassName: "nebius-network-ssd"
          accessModes: [ "ReadWriteOnce" ]
          resources:
            requests:
              storage: "${ceil(slurm_cluster_worker_volume_spool_size / unit_gib)}Gi"
      jail:
        volumeSourceName: "${slurm_cluster_storages.jail.name}"
      %{ if length(slurm_cluster_storages.jail_submounts) > 0 }
      jailSubMounts:
        %{ for storage in slurm_cluster_storages.jail_submounts }
        - name: "${storage.name}"
          mountPath: "${storage.mountPath}"
          volumeSourceName: "${storage.name}"
        %{ endfor }
      %{ else }
      jailSubMounts: []
      %{ endif }
      sharedMemorySize: ${shared_memory_size}
  login:
    size: ${slurm_cluster_node_login_count}
    k8sNodeFilterName: "${slurm_cluster_k8s_node_filters.non_gpu}"
    sshd:
      resources:
        cpu: "${ceil(slurm_cluster_node_login_sshd_resources.cpu_cores * unit_core)}m"
        memory: "${ceil(slurm_cluster_node_login_sshd_resources.memory_bytes / unit_gib)}Gi"
        ephemeralStorage: "${ceil(slurm_cluster_node_login_sshd_resources.ephemeral_storage_bytes / unit_gib)}Gi"
    sshdServiceType: "LoadBalancer"
    sshdServiceLoadBalancerIP: "${one(nebius_vpc_external_ipv4_address).address}"
    sshRootPublicKeys:
      %{ for key in slurm_cluster_ssh_root_public_keys }
      - "${key}"
      %{ endfor }
    munge:
      resources:
        cpu: "${ceil(slurm_cluster_node_login_munge_resources.cpu_cores * unit_core)}m"
        memory: "${ceil(slurm_cluster_node_login_munge_resources.memory_bytes / unit_gib)}Gi"
        ephemeralStorage: "${ceil(slurm_cluster_node_login_munge_resources.ephemeral_storage_bytes / unit_gib)}Gi"
    volumes:
      jail:
        volumeSourceName: "${slurm_cluster_storages.jail.name}"
      %{ if length(slurm_cluster_storages.jail_submounts) > 0 }
      jailSubMounts:
        %{ for storage in slurm_cluster_storages.jail_submounts }
        - name: "${storage.name}"
          mountPath: "${storage.mountPath}"
          volumeSourceName: "${storage.name}"
        %{ endfor }
      %{ else }
      jailSubMounts: []
      %{ endif }
  exporter:
    enabled: "${slurm_cluster_exporter_enabled}"
    k8sNodeFilterName: "${slurm_cluster_k8s_node_filters.non_gpu}"

telemetry:
  jobsTelemetry:
    otelCollectorHttpHost: "${otelCollectorHttpHost}"
    otelCollectorPath: "${otelCollectorPath}"
    otelCollectorPort: "${otelCollectorPort}"
    sendJobsEvents: "${monitoring}"
    sendOtelMetrics: "${monitoring}"
