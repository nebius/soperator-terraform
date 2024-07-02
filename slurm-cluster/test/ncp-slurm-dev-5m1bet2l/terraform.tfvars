k8s_folder_id    = "bje82q7sm8njm3c4rrlq"
k8s_cluster_name = "slurm-dev"
slurm_cluster_ssh_root_public_keys = [
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKzxkjzPQ4EyZSjan4MLGFSA18idpZicoKW7HC4YmwgN rdjjke@gmail.com",
]
slurm_cluster_filestores = {
  jail = {
    name = "jail"
    size = 1500 * (1024 * 1024 * 1024) # 1500Gi
  }
  controller_spool = {
    name = "controller-spool"
    size = 30 * (1024 * 1024 * 1024) # 30Gi
  }
  jail_submounts = [{
    name = "mlperf-sd"
    size = 1500 * (1024 * 1024 * 1024) # 1500Gi
    mountPath = "/mlperf-sd"
  }]
}
slurm_cluster_create_cr = true
