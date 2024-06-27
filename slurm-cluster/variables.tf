variable "slurm_cluster_name" {
  description = "Name of the Slurm cluster"
  type        = string
  default     = "slurm"
}

variable "slurm_cluster_filestores" {
  description = "Shared filestores of the Slurm cluster. Sizes specified in bytes."
  type = object({
    jail = object({
      name = string
      size = number
    })
    controller_spool = object({
      name = string
      size = number
    })
  })
  default = {
    jail = {
      name = "jail"
      size = 128 * (1024 * 1024 * 1024)
    }
    controller_spool = {
      name = "controller-spool"
      size = 100 * (1024 * 1024 * 1024)
    }
  }
}

variable "slurm_operator_version" {
  description = "Version of Slurm operator Helm chart."
  type        = string
  default     = "0.1.10"
}
