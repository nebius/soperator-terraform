output "common" {
  description = "Common labels used across most of resources."
  value       = local.common
}

output "common_with_k8s_id" {
  description = "Common labels extended with k8s cluster id, which resources belong to."
  value       = local.k8s
}

output "group_name_cpu" {
  description = "CPU node group label."
  value = tomap({
    (local.group_name.key) = local.group_name.cpu
  })
}

output "group_name_gpu" {
  description = "GPU node group label."
  value = tomap({
    (local.group_name.key) = local.group_name.gpu
  })
}
