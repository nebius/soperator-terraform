output "labels_common" {
  description = "Common labels extended with k8s cluster id, which resources belong to."
  value = merge(
    local.label.managed_by,
    local.label.used_for,
    var.custom_labels,
  )
}

output "label_managed_by" {
  description = "Managed-by label."
  value       = local.label.managed_by
}

output "label_used_for" {
  description = "Used-for label."
  value       = local.label.used_for
}

output "label_group_name_cpu" {
  description = "CPU node group label."
  value       = local.label.group_name.cpu
}

output "label_group_name_gpu" {
  description = "GPU node group label."
  value       = local.label.group_name.gpu
}

output "label_group_name_nlb" {
  description = "NLB node group label."
  value       = local.label.group_name.nlb
}

output "key_k8s_cluster_id" {
  description = "k8s cluster ID label key."
  value       = local.label_key.k8s_cluster_id
}

output "key_k8s_cluster_name" {
  description = "k8s cluster name label key."
  value       = local.label_key.k8s_cluster_name
}

output "key_slurm_node_group_name" {
  description = "Slurm node group label key."
  value       = local.label_key.slurm_group_name
}

output "key_slurm_cluster_name" {
  description = "Slurm cluster name label key."
  value       = local.label_key.slurm_cluster_name
}
