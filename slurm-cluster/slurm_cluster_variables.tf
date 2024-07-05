variable "slurm_cluster_create_cr" {
  description = "Whether to create a Slurm cluster"
  type        = bool
  default     = true
}

variable "slurm_cluster_name" {
  description = "Name of the Slurm cluster"
  type        = string
  default     = "slurm"
}

variable "slurm_cluster_storages" {
  description = "Shared storages of the Slurm cluster. Sizes specified in bytes."
  type = object({
    jail = object({
      name = string
      size = number
      type = string
    })
    controller_spool = object({
      name = string
      size = number
    })
    jail_submounts = list(object({
      name      = string
      size      = number
      mountPath = string
    }))
  })
  default = {
    jail = {
      name = "jail"
      size = 1115 * (1024 * 1024 * 1024) # 1115Gi
      type = "glusterfs"
    }
    controller_spool = {
      name = "controller-spool"
      size = 30 * (1024 * 1024 * 1024) # 30Gi
    }
    jail_submounts = []
  }
}

variable "slurm_cluster_jail_snapshot" {
  description = "A disk with the initial content for populating the jail filesystem."
  type = object({
    name = string
    size = number
  })
  default = null
}

locals {
  slurm_cluster_jail_submounts_storages = [
    for sm in var.slurm_cluster_storages.jail_submounts : {
      name                = sm.name
      filestoreDeviceName = sm.name
      size                = "${ceil(sm.size / local.unit_gib)}Gi"
    }
  ]
}

variable "slurm_cluster_worker_volume_spool_size" {
  description = "Spool volume size of the Slurm cluster worker node, specified in bytes."
  type        = number
  default     = 128 * (1024 * 1024 * 1024)
}

variable "slurm_cluster_ssh_root_public_keys" {
  description = "Authorized keys available for connecting by SSH to Slurm login under user root."
  type        = list(string)
}

variable "slurm_cluster_nccl_benchmark_schedule" {
  description = "NCCL test benchmark CronJob schedule."
  type        = string
  default     = "0 */3 * * *"
}

variable "slurm_cluster_nccl_settings" {
  description = "NCCL settings."
  type = object({
    topology_type       = string
    topology_data       = string
  })
  default = {
    topology_type           = "H100 GPU cluster"
    topology_data           = ""
  }
}

variable "slurm_cluster_nccl_benchmark_settings" {
  description = "NCCL test benchmark settings."
  type = object({
    min_bytes           = string
    max_bytes           = string
    step_factor         = string
    timeout             = string
    threshold_more_than = string
    use_infiniband      = bool
  })
  default = {
    min_bytes           = "512Mb"
    max_bytes           = "8Gb"
    step_factor         = "2"
    timeout             = "20:00"
    threshold_more_than = "420"
    use_infiniband      = false
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
  default     = "0.1.14"
}
