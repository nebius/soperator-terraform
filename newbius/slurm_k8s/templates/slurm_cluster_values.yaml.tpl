k8sNodeFilters:
  - name: "${slurm_cluster_k8s_node_filters.non_gpu}"
    # affinity:
    #   nodeAffinity:
    #     requiredDuringSchedulingIgnoredDuringExecution:
    #       nodeSelectorTerms:
    #         - matchExpressions:
    #             - key: "slurm.nebius.ai/group-name"
    #               operator: In
    #               values:
    #                 - "${slurm_cluster_k8s_node_filters.non_gpu}"
    tolerations:
      - key: slurm.nebius.ai/taint
        operator: Equal
        value: "${slurm_cluster_k8s_node_filters.non_gpu}"
        effect: NoSchedule

  - name: "${slurm_cluster_k8s_node_filters.gpu}"
    # affinity:
    #   nodeAffinity:
    #     requiredDuringSchedulingIgnoredDuringExecution:
    #       nodeSelectorTerms:
    #         - matchExpressions:
    #             - key: "slurm.nebius.ai/group-name"
    #               operator: In
    #               values:
    #                 - "${slurm_cluster_k8s_node_filters.gpu}"
    tolerations:
      - key: slurm.nebius.ai/taint
        operator: Equal
        value: "${slurm_cluster_k8s_node_filters.gpu}"
        effect: NoSchedule

populateJail:
  k8sNodeFilterName: "${slurm_cluster_k8s_node_filters.gpu}"

periodicChecks:
  ncclBenchmark:
    k8sNodeFilterName: "${slurm_cluster_k8s_node_filters.non_gpu}"

slurmNodes:
  controller:
    k8sNodeFilterName: "${slurm_cluster_k8s_node_filters.non_gpu}"
  worker:
    k8sNodeFilterName: "${slurm_cluster_k8s_node_filters.gpu}"
    slurmd:
      resources:
        cpu: "${ceil(slurmd_resources.cpu * 1000)}m"
        memory: "${slurmd_resources.memory}Gi"
        ephemeralStorage: "${slurmd_resources.ephemeral_storage}Gi"
        gpu: "${slurmd_resources.gpus}"
    volumes:
      spool:
        volumeClaimTemplateSpec:
          storageClassName: "compute-csi-default-sc"
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: "128Gi"
  login:
    k8sNodeFilterName: "${slurm_cluster_k8s_node_filters.non_gpu}"
