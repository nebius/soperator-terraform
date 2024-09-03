variable "slurm_cluster_name" {
  description = "Name of the Slurm cluster."
  type        = string
  default     = "slurm"

  validation {
    condition = (
      length(var.slurm_cluster_name) >= 1 &&
      length(var.slurm_cluster_name) <= 64 &&
      length(regexall("^[a-z][a-z\\d\\-]*[a-z\\d]+$", var.slurm_cluster_name)) == 1
    )
    error_message = <<EOF
      The Slurm cluster name must:
      - be 1 to 64 characters long
      - start with a letter
      - end with a letter or digit
      - consist of letters, digits, or hyphens (-)
      - contain only lowercase letters
    EOF
  }
}

# region filestore

variable "filestore_jail" {
  description = "Shared filesystem to be used on controller, worker, and login nodes."
  type = object({
    size_gibibytes = number
  })
  default = {
    size_gibibytes = 2048
  }
}

variable "filestore_controller_spool" {
  description = "Shared filesystem to be used on controller nodes."
  type = object({
    size_gibibytes = number
  })
  default = {
    size_gibibytes = 128
  }
}

variable "filestore_jail_submounts" {
  description = "Shared filesystems to be mounted inside jail's /mnt directory."
  type = list(object({
    name           = string
    size_gibibytes = number
    mount_path     = string
  }))
  default = []
}

# endregion filestore

variable "slurm_shared_memory_size_gibibytes" {
  description = "Shared memory size for Slurm controller and worker nodes in GiB."
  type        = string
  default     = 64
}

variable "slurm_login_service_type" {
  description = "Type of the k8s service to connect to login nodes."
  type        = string
  default     = "LoadBalancer"

  validation {
    condition     = (contains(["LoadBalancer", "NodePort"], var.slurm_login_service_type))
    error_message = "Invalid service type. It must be one of `LoadBalancer` or `NodePort`."
  }
}

variable "slurm_ssh_root_public_keys" {
  description = "Authorized keys accepted for connecting via SSH to Slurm login as 'root' user."
  type        = list(string)
  default     = []
}
