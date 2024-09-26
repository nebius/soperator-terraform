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

# region Exporter

variable "exporter_enabled" {
  description = "Whether to enable Slurm metrics exporter."
  type        = bool
  default     = true
}

# endregion Exporter

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
    accounting_storage = optional(object({
      size_gibibytes = number
      device         = string
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

variable "telemetry_enabled" {
  description = "Whether to enable telemetry."
  type        = bool
  default     = true
}

variable "telemetry_grafana_admin_password" {
  description = "Password of `admin` user of Grafana."
  type        = string
}

# endregion Telemetry

# region Accounting

variable "mariadb_operator_namespace" {
  description = "Namespace for MariaDB operator."
  type        = string
  default     = "mariadb-operator-system"
}

variable "accounting_enabled" {
  description = "Whether to enable accounting."
  type        = bool
  default     = false
}

# endregion Accounting
