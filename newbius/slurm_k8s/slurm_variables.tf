variable "slurm_cluster_name" {
  description = "Name of the Slurm cluster in k8s cluster."
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

# region Login

variable "slurm_login_service_type" {
  description = "Type of the k8s service to connect to login nodes."
  type        = string
  default     = "LoadBalancer"

  validation {
    condition     = (contains(["LoadBalancer", "NodePort"], var.slurm_login_service_type))
    error_message = "Invalid service type. It must be one of `LoadBalancer` or `NodePort`."
  }
}

variable "slurm_login_node_port" {
  description = "Port of the host to be opened in case of use of `NodePort` service type."
  type        = number
  default     = 30022

  validation {
    condition     = var.slurm_login_node_port >= 30000 && var.slurm_login_node_port < 32768
    error_message = "Invalid node port. It must be in range [30000,32768)."
  }
}

variable "slurm_login_ssh_root_public_keys" {
  description = "Authorized keys accepted for connecting to Slurm login nodes via SSH as 'root' user."
  type        = list(string)
  nullable    = false
}

# endregion Login

# region Config

variable "slurm_shared_memory_size_gibibytes" {
  description = "Shared memory size for Slurm controller and worker nodes in GiB."
  type        = number
  default     = 64
}

# endregion Config
