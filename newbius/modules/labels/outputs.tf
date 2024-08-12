output "common" {
  description = "Common labels used across most of resources."
  value       = local.common
}

output "common_with_k8s_id" {
  description = "Common labels extended with k8s cluster id, which resources belong to."
  value       = local.k8s
}
