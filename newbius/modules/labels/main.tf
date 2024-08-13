locals {
  common = merge(
    tomap({
      "managed-by" = "terraform"
      "used-for"   = "slurm"
    }),
    var.custom_labels
  )

  k8s_cluster_id = tomap({
    "mk8s.nebius.ai/cluster-id" = var.k8s_cluster_id
  })

  k8s = merge(
    local.common,
    local.k8s_cluster_id,
  )

  group_name = {
    key = "slurm.nebius.ai/group-name"
    cpu = "cpu"
    gpu = "gpu"
  }
}
