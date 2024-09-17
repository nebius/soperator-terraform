variable "name" {
  description = "Name of the Slurm cluster in k8s cluster."
  type        = string
}

variable "operator_version" {
  type = string
}

# region Nodes

variable "node_count" {
  description = "Count of Slurm nodes."
  type = object({
    controller = number
    worker     = number
  })
}

# region Worker

variable "worker_resources" {
  description = "Slurmd resources on worker nodes."
  type = object({
    cpu_cores                   = number
    memory_gibibytes            = number
    ephemeral_storage_gibibytes = number
    gpus                        = number
  })
}

# endregion Worker

# region Login

variable "login_service_type" {
  description = "Type of the k8s service to connect to login nodes."
  type        = string
}

variable "login_node_port" {
  description = "Port of the host to be opened in case of use of `NodePort` service type."
  type        = number
}

variable "login_load_balancer_ip" {
  description = "External IP of the LoadBalancer in case of use of `LoadBalancer` service type."
  type        = string
  default     = ""
}

variable "login_ssh_root_public_keys" {
  description = "Authorized keys accepted for connecting to Slurm login nodes via SSH as 'root' user."
  type        = list(string)
}

# endregion Login

# endregion Nodes

# region Filestore

variable "filestores" {
  description = "Filestores to be used in Slurm cluster."
  type = object({
    controller_spool = object({
      size_gibibytes = number
      device         = string
    })
    jail = object({
      size_gibibytes = number
      device         = string
    })
    jail_submounts = list(object({
      name           = string
      size_gibibytes = number
      device         = string
      mount_path     = string
    }))
  })
}

# endregion Filestore

# region Config

variable "shared_memory_size_gibibytes" {
  description = "Shared memory size for Slurm controller and worker nodes in GiB."
  type        = number
  default     = 64
}

# endregion Config

# region NCCL

variable "nccl_topology_type" {
  description = "NCCL topology type."
  type        = string
  default     = "auto"
}

# Benchmark

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

# endregion NCCL benchmark

# endregion NCCL

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
