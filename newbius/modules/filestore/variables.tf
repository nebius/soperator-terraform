variable "iam_project_id" {
  description = "ID of the IAM project."
  type        = string
}

variable "k8s_cluster_name" {
  description = "Name of the k8s cluster."
  type        = string
}

#---

variable "controller_spool" {
  description = "Specification for 'controller-spool' filestore."
  type = object({
    disk_type            = string
    size_gibibytes       = number
    block_size_kibibytes = number
  })
  nullable = false
}

variable "jail" {
  description = "Specification for 'jail' filestore."
  type = object({
    disk_type            = string
    size_gibibytes       = number
    block_size_kibibytes = number
  })
  nullable = false
}

variable "jail_submounts" {
  description = "Specification for 'jail' submount filestores."
  type = list(object({
    name                 = string
    disk_type            = string
    size_gibibytes       = number
    block_size_kibibytes = number
  }))
  default = []
}
