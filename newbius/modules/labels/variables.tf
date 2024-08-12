variable "custom_labels" {
  description = "Custom labels to be used for all created resources."
  type        = map(string)
  default     = {}
}

variable "k8s_cluster_id" {
  description = "ID of the k8s cluster."
  type        = string
  nullable    = false
}
