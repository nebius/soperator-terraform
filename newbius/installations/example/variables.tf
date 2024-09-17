# region Cloud

variable "iam_token" {
  description = "IAM token used for communicating with Nebius services."
  type        = string
  nullable    = false
  sensitive   = true
}

variable "iam_project_id" {
  description = "ID of the IAM project."
  type        = string
  nullable    = false

  validation {
    condition     = startswith(var.iam_project_id, "project-")
    error_message = "ID of the IAM project must start with `project-`."
  }
}
data "nebius_iam_v1_project" "this" {
  id = var.iam_project_id
}

variable "vpc_subnet_id" {
  description = "ID of VPC subnet."
  type        = string

  validation {
    condition     = startswith(var.vpc_subnet_id, "vpcsubnet-")
    error_message = "The ID of the VPC subnet must start with `vpcsubnet-`."
  }
}
data "nebius_vpc_v1_subnet" "this" {
  id = var.vpc_subnet_id
}

# endregion Cloud

# region Infrastructure

# region Storage

variable "filestore_controller_spool" {
  description = "Shared filesystem to be used on controller nodes."
  type = object({
    size_gibibytes       = number
    block_size_kibibytes = number
  })
}

variable "filestore_jail" {
  description = "Shared filesystem to be used on controller, worker, and login nodes."
  type = object({
    size_gibibytes       = number
    block_size_kibibytes = number
  })
}

variable "filestore_jail_submounts" {
  description = "Shared filesystems to be mounted inside jail."
  type = list(object({
    name                 = string
    size_gibibytes       = number
    block_size_kibibytes = number
    mount_path           = string
  }))
}

# endregion Storage

# region k8s

variable "k8s_version" {
  description = "Version of the k8s to be used."
  type        = string
  default     = "1.30"

  validation {
    condition     = length(regexall("^[\\d]+\\.[\\d]+$", var.k8s_version)) == 1
    error_message = "The k8s cluster version now only supports version in format `<MAJOR>.<MINOR>`."
  }
}

variable "k8s_cluster_name" {
  description = "Name of the k8s cluster."
  type        = string
  nullable    = false

  validation {
    condition = (
      length(var.k8s_cluster_name) >= 1 &&
      length(var.k8s_cluster_name) <= 64 &&
      length(regexall("^[a-z][a-z\\d\\-]*[a-z\\d]+$", var.k8s_cluster_name)) == 1
    )
    error_message = <<EOF
      The k8s cluster name must:
      - be 1 to 64 characters long
      - start with a letter
      - end with a letter or digit
      - consist of letters, digits, or hyphens (-)
      - contain only lowercase letters
    EOF
  }
}

variable "k8s_cluster_node_group_cpu" {
  description = "CPU-only node group specification."
  type = object({
    resource = object({
      platform = string
      preset   = string
    })
    boot_disk = object({
      type           = string
      size_gibibytes = number
    })
  })
  nullable = false
  default = {
    resource = {
      platform = "cpu-e2"
      preset   = "16vcpu-64gb"
    }
    boot_disk = {
      type           = "NETWORK_SSD"
      size_gibibytes = 128
    }
  }
}

variable "k8s_cluster_node_group_gpu" {
  description = "GPU node group specification."
  type = object({
    resource = object({
      platform = string
      preset   = string
    })
    boot_disk = object({
      type           = string
      size_gibibytes = number
    })
    gpu_cluster = object({
      infiniband_fabric = string
    })
  })
  nullable = false
  default = {
    resource = {
      platform = "gpu-h100-sxm"
      preset   = "8gpu-128vcpu-1600gb"
    }
    boot_disk = {
      type           = "NETWORK_SSD"
      size_gibibytes = 1024
    }
    gpu_cluster = {
      infiniband_fabric = "fabric-2"
    }
  }

  validation {
    condition = (
      (var.k8s_cluster_node_group_gpu.resource.platform == "gpu-h100-sxm") &&
      (contains(["8gpu-128vcpu-1600gb", "1gpu-20vcpu-200gb"], var.k8s_cluster_node_group_gpu.resource.preset))
    )
    error_message = <<EOF
      Invalid resource specification for GPU node group.
      - The only platform supported is `gpu-h100-sxm`
      - Preset must be one of `8gpu-128vcpu-1600gb` or `1gpu-20vcpu-200gb`
    EOF
  }
}

# endregion k8s

# endregion Infrastructure

# region Slurm

variable "slurm_cluster_name" {
  description = "Name of the Slurm cluster in k8s cluster."
  type        = string
  nullable    = false

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

variable "slurm_operator_version" {
  description = "Version of soperator."
  type        = string
  nullable    = false
}

# region Nodes

variable "slurm_node_count" {
  description = "Count of Slurm nodes."
  type = object({
    controller = number
    worker     = number
  })
  nullable = false
}

# region Login

variable "slurm_login_service_type" {
  description = "Type of the k8s service to connect to login nodes."
  type        = string
  nullable    = false

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

# endregion Nodes

# region Config

variable "slurm_shared_memory_size_gibibytes" {
  description = "Shared memory size for Slurm controller and worker nodes in GiB."
  type        = number
  default     = 64
}

# endregion Config

# region NCCL benchmark

variable "nccl_benchmark_enable" {
  description = "Whether to enable NCCL benchmark CronJob to benchmark GPU performance. It won't take effect in case of 1-GPU hosts."
  type        = bool
  default     = true
}

variable "nccl_benchmark_schedule" {
  description = "NCCL benchmark's CronJob schedule."
  type        = string
  default     = "0 */3 * * *"
}

variable "nccl_benchmark_min_threshold" {
  description = "Minimal threshold of NCCL benchmark for GPU performance to be considered as acceptable."
  type        = number
  default     = 420
}

# region NCCL benchmark

# region Telemetry

variable "telemetry_enable_otel_collector" {
  description = "Whether to enable Open Telemetry collector."
  type        = bool
  default     = true
}

variable "telemetry_enable_prometheus" {
  description = "Whether to enable Prometheus."
  type        = bool
  default     = true
}

variable "telemetry_send_job_events" {
  description = "Whether to send job events."
  type        = bool
  default     = true
}

variable "telemetry_send_otel_metrics" {
  description = "Whether to send Open Telemetry metrics."
  type        = bool
  default     = true
}

# endregion Telemetry

# endregion Slurm
