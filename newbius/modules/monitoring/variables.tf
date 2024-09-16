variable "slurm_cluster_name" {
  description = "Name of the Slurm cluster."
  type        = string
  nullable = false
}

variable "create_pvcs" {
  description = "Whether to create PVCs. Uses emptyDir if false."
  type = bool
  default = false
}

variable "resources_vm_operator" {
  description = "Resources for VictoriaMetrics Operator."
  type = object({
    memory = string
    cpu = string
  })
  default = {
    memory = "256Mi"
    cpu = "50m"
  }
}

variable "resources_vm_logs_server" {
  type = object({
    memory = string
    cpu = string
    size = string
  })
  default = {
    memory = "512Mi"
    cpu = "250m"
    size = "40Gi"
  }
}

variable "resources_vm_single" {
  type = object({
    memory = string
    cpu = string
    size = string
  })
  default = {
    memory = "1536Mi"
    cpu = "250m"
    size = "40Gi"
  }
}

variable "resources_vm_agent" {
  type = object({
    memory = string
    cpu = string
  })
  default = {
    memory = "384Mi"
    cpu = "250m"
  }
}

variable "resources_fb_logs_collector" {
  type = object({
    memory = string
    cpu = string
  })
  default = {
    memory = "256Mi"
    cpu = "200m"
  }
}
