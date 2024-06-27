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
      size = 64 * (1024 * 1024 * 1024)
    }
  }
}

variable "slurm_cluster_worker_volume_spool_size" {
  description = "Spool volume size of the Slurm cluster worker node, specified in bytes."
  type        = number
  default     = 128 * (1024 * 1024 * 1024)
}

variable "slurm_cluster_ssh_root_public_keys" {
  description = "Authorized keys required for SSH connection to Slurm login nodes. Each key must be base64 encoded string."
  type        = list(string)
}

variable "slurm_cluster_nccl_benchmark_schedule" {
  description = "NCCL test benchmark CronJob schedule."
  type        = string
  default     = "0 */3 * * *"
}

variable "slurm_cluster_nccl_benchmark_settings" {
  description = "NCCL test benchmark settings."
  type = object({
    min_bytes           = string
    max_bytes           = string
    step_factor         = string
    timeout             = string
    threshold_more_than = string
  })
  default = {
    min_bytes           = "512Mb"
    max_bytes           = "8Gb"
    step_factor         = "2"
    timeout             = "20:00"
    threshold_more_than = "42"
  }
}

variable "slurm_cluster_nccl_benchmark_drain_nodes" {
  description = "Whether to drain Slurm node in case of benchmark failure."
  type        = bool
  default     = true
}

variable "slurm_cluster_node_controller_count" {
  description = "Number of Slurm controller nodes."
  type        = number
  default     = 2
}

variable "slurm_cluster_node_worker_count" {
  description = "Number of Slurm worker nodes."
  type        = number
  default     = 2
}

variable "slurm_cluster_node_login_count" {
  description = "Number of Slurm login nodes."
  type        = number
  default     = 2
}

variable "slurm_cluster_node_controller_slurmctld_resources" {
  description = "Slurm controller node slurmctld container resources."
  type = object({
    cpu_cores               = number
    memory_bytes            = number
    ephemeral_storage_bytes = number
  })
  default = {
    cpu_cores               = 1
    memory_bytes            = 3 * (1024 * 1024 * 1024)
    ephemeral_storage_bytes = 20 * (1024 * 1024 * 1024)
  }
}

variable "slurm_cluster_node_controller_munge_resources" {
  description = "Slurm controller node munge container resources."
  type = object({
    cpu_cores               = number
    memory_bytes            = number
    ephemeral_storage_bytes = number
  })
  default = {
    cpu_cores               = 1
    memory_bytes            = 1 * (1024 * 1024 * 1024)
    ephemeral_storage_bytes = 5 * (1024 * 1024 * 1024)
  }
}

variable "slurm_cluster_node_worker_slurmd_resources" {
  description = "Slurm worker node slurmd container resources."
  type = object({
    cpu_cores               = number
    memory_bytes            = number
    ephemeral_storage_bytes = number
  })
  default = {
    cpu_cores               = 156
    memory_bytes            = 1220 * (1024 * 1024 * 1024)
    ephemeral_storage_bytes = 55 * (1024 * 1024 * 1024)
  }
}

variable "slurm_cluster_node_worker_munge_resources" {
  description = "Slurm worker node munge container resources."
  type = object({
    cpu_cores               = number
    memory_bytes            = number
    ephemeral_storage_bytes = number
  })
  default = {
    cpu_cores               = 2
    memory_bytes            = 4 * (1024 * 1024 * 1024)
    ephemeral_storage_bytes = 5 * (1024 * 1024 * 1024)
  }
}

variable "slurm_cluster_node_login_sshd_resources" {
  description = "Slurm login node sshd container resources."
  type = object({
    cpu_cores               = number
    memory_bytes            = number
    ephemeral_storage_bytes = number
  })
  default = {
    cpu_cores               = 3
    memory_bytes            = 9 * (1024 * 1024 * 1024)
    ephemeral_storage_bytes = 30 * (1024 * 1024 * 1024)
  }
}

variable "slurm_cluster_node_login_munge_resources" {
  description = "Slurm login node munge container resources."
  type = object({
    cpu_cores               = number
    memory_bytes            = number
    ephemeral_storage_bytes = number
  })
  default = {
    cpu_cores               = 0.5
    memory_bytes            = 0.5 * (1024 * 1024 * 1024)
    ephemeral_storage_bytes = 5 * (1024 * 1024 * 1024)
  }
}

variable "slurm_operator_version" {
  description = "Version of Slurm operator Helm chart."
  type        = string
  default     = "0.1.11"
}
