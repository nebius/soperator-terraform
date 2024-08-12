variable "iam_project_id" {
  description = "Project ID."
  type        = string
  nullable    = false
}

variable "k8s_cluster_name" {
  description = "Name of the k8s cluster."
  type        = string
  nullable    = false
}
