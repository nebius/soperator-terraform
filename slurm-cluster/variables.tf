variable "slurm_cluster_name" {
  description = "Name of the Slurm cluster"
  type        = string
  default     = "slurm"
}

variable "slurm_cluster_filestores" {
  description = "Shared filestores of the Slurm cluster. Sizes specified in GB."
  type = list(object({
    name = string
    size = number
  }))
  default = [
    {
      name = "jail"
      size = 2000
    },
    {
      name = "controller-spool"
      size = 100
    }
  ]
}

variable "slurm_operator_version" {
  description = "Version of Slurm operator Helm chart."
  type        = string
  default     = "0.1.10"
}
