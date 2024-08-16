variable "k8s_folder_id" {
  description = "ID of the folder the k8s cluster belongs to."
  type        = string
}

variable "k8s_network_id" {
  description = "ID of the existing VPC network to crate subnet into."
  type        = string
  default     = ""
}

# region meta

variable "k8s_cluster_name" {
  description = "Name of the k8s cluster."
  type        = string
  default     = "k8s-cluster"
}

variable "k8s_cluster_description" {
  description = "Description of the k8s cluster."
  type        = string
  default     = "Nebius Managed K8S cluster"
}

variable "k8s_cluster_version" {
  description = "Version of the k8s cluster."
  type        = string
  default     = "1.28"
}

# endregion meta

variable "k8s_cluster_subnet_cidr_blocks" {
  description = "IP address space for the k8s subnet."
  type        = list(any)
  default     = ["192.168.10.0/24"]
}

variable "k8s_cluster_zone_id" {
  description = "ID of the availability zone where the master compute instance resides."
  type        = string
  default     = "eu-north1-c"
}

variable "k8s_cluster_master_maintenance_windows" {
  description = "List of structures that specifies maintenance windows, when auto update for the master is allowed."
  type        = list(map(string))
  default = [{
    day        = "monday"
    start_time = "20:00"
    duration   = "3h"
  }]
}

variable "k8s_cluster_node_group_non_gpu" {
  description = "Non-GPU node group specification."
  type = object({
    name         = string
    size         = number
    cpu_cores    = number
    memory_gb    = number
    disk_type    = string
    disk_size_gb = number
  })
  default = {
    name         = "k8s-ng-non-gpu"
    size         = 2
    cpu_cores    = 8
    memory_gb    = 32
    disk_type    = "network-ssd"
    disk_size_gb = 128
  }
}

variable "k8s_cluster_node_group_gpu" {
  description = "GPU node group specification."
  type = object({
    platform                      = string
    size                          = number
    cpu_cores                     = number
    memory_gb                     = number
    gpus                          = number
    interconnect_type             = string
    interconnect_physical_cluster = string
    disk_type                     = string
    disk_size_gb                  = number
    gke_accelerator               = string
    driver_config                 = string
    preemptible                   = bool
  })
  default = {
    platform                      = "h100"
    size                          = 2
    cpu_cores                     = 160
    memory_gb                     = 1280
    gpus                          = 8
    interconnect_type             = "InfiniBand"
    interconnect_physical_cluster = "fabric-1"
    disk_type                     = "network-ssd"
    disk_size_gb                  = 128
    gke_accelerator               = "nvidia-h100-80gb"
    driver_config                 = "535"
    preemptible                   = false
  }
}

# region ssh

variable "k8s_cluster_ssh_username" {
  description = "A username for SSH login."
  type        = string
  default     = "ubuntu"
}

variable "k8s_cluster_ssh_public_key" {
  description = "Public SSH key to access the cluster nodes."
  type        = string
  default     = null
}

variable "k8s_cluster_ssh_public_key_path" {
  description = "Path to a SSH public key to access the cluster nodes."
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

# endregion ssh

variable "k8s_cluster_filestore_block_size" {
  description = "Block size of the filestore filesystem, specified in bytes."
  type        = number
  default     = 32768
}

# region operator

variable "k8s_cluster_operator_gpu_version" {
  description = "Version of the GPU operator Helm chart."
  type        = string
  default     = "v23.9.0"
}

variable "k8s_cluster_operator_gpu_cuda_toolkit" {
  description = "Whether to enable CUDA Toolkit."
  type        = bool
  default     = true
}

variable "k8s_cluster_operator_gpu_driver_rdma" {
  description = "Whether to enable Nvidia RDMA."
  type        = bool
  default     = true
}

variable "k8s_cluster_operator_gpu_driver_version" {
  description = "Version of the driver version."
  type        = string
  default     = "535.104.12"
}

variable "k8s_cluster_operator_network_version" {
  description = "Version of the network operator Helm chart."
  type        = string
  default     = "23.7.0"
}

variable "k8s_cluster_operator_opentelemetry_operator_enabled" {
  description = "Whether to enable OpenTelemetry."
  type        = bool
  default     = false
}

# endregion operator
