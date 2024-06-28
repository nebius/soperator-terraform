volume:
  jail:
    name: "${slurm_cluster_filestores.jail.name}"
    filestoreDeviceName: "${slurm_cluster_filestores.jail.name}"
    size: "${slurm_cluster_jail_size}"
  controllerSpool:
    name: "${slurm_cluster_filestores.controller_spool.name}"
    filestoreDeviceName: "${slurm_cluster_filestores.controller_spool.name}"
    size: "${slurm_cluster_controller_spool_size}"
  %{ if length(slurm_cluster_filestores.jail_submounts) > 0 }
  jailSubMounts:
    %{ for filestore in slurm_cluster_filestores.jail_submounts }
    - name: "${filestore.name}"
      filestoreDeviceName: "${filestore.name}"
      size: "${ceil(filestore.size / unit_gib)}Gi"
    %{ endfor }
  %{ else }
  jailSubMounts: []
  %{ endif }
nodeGroup:
  gpu:
    id: "${kube_node_group_gpu.id}"
  nonGpu:
    id: "${kube_node_group_non_gpu.id}"
