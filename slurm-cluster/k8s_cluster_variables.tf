variable "k8s_folder_id" {
  description = "ID of the folder the k8s cluster belongs to."
  type        = string
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
  default     = "1.27"
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

variable "k8s_cluster_gpu_node_groups" {
  description = "GPU node group specifications."
  type = list(object({
    platform  = string
    size      = number
    cores     = number
    memory    = number
    gpus      = number
    disk_type = string
    disk_size = number
  }))
  default = [{
    platform  = "h100"
    size      = 2
    cores     = 160
    memory    = 1280
    gpus      = 8
    disk_type = "network-ssd-nonreplicated"
    disk_size = 372
  }]
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

# endregion operator
