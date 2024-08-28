# region iam

variable "iam_project_id" {
  description = "Project ID."
  type        = string
  nullable    = false
}

# endregion iam

# region k8s

variable "k8s_cluster_id" {
  description = "ID of the k8s cluster."
  type        = string
  nullable    = false
}

variable "k8s_cluster_name" {
  description = "Name of the k8s cluster."
  type        = string
  nullable    = false
}

# endregion k8s

# region jail

variable "jail" {
  description = "Specification for 'jail' filestore."
  type = object({
    disk_type            = string
    size_gibibytes       = number
    block_size_kibibytes = number
  })
  nullable = false
}

data "units_data_size" "jail_storage" {
  gibibytes = var.jail.size_gibibytes
}

data "units_data_size" "jail_block" {
  kibibytes = var.jail.block_size_kibibytes
}

# endregion jail

# region controller-spool

variable "controller_spool" {
  description = "Specification for 'controller-spool' filestore."
  type = object({
    disk_type            = string
    size_gibibytes       = number
    block_size_kibibytes = number
  })
  nullable = false
}

data "units_data_size" "controller_spool_storage" {
  gibibytes = var.controller_spool.size_gibibytes
}

data "units_data_size" "controller_spool_block" {
  kibibytes = var.controller_spool.block_size_kibibytes
}

# endregion controller-spool

# region jail submounts

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

data "units_data_size" "jail_submount_storage" {
  for_each = tomap({ for submount in var.jail_submounts :
    submount.name => submount.size_gibibytes
  })

  gibibytes = each.value
}

data "units_data_size" "jail_submount_block" {
  for_each = tomap({ for submount in var.jail_submounts :
    submount.name => submount.block_size_kibibytes
  })

  kibibytes = each.value
}

# endregion jail submounts

# region labels

variable "common_labels" {
  description = "Labels to set for filestores."
  type        = map(string)
  default     = {}
}

# endregion labels
