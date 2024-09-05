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
  default     = "slurm"

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
    size = number
    resource = object({
      platform = string
      preset   = string
    })
    boot_disk = object({
      type           = string
      size_gibibytes = number
    })
  })
  default = {
    size = 2
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
data "units_data_size" "boot_disk_ng_cpu" {
  gibibytes = var.k8s_cluster_node_group_cpu.boot_disk.size_gibibytes
}

variable "k8s_cluster_node_group_gpu" {
  description = "GPU node group specification."
  type = object({
    size = number
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
  default = {
    size = 2
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
      Wrong resource specification for GPU node group.
      - The only platform supported is `gpu-h100-sxm`
      - Preset must be one of `8gpu-128vcpu-1600gb` or `1gpu-20vcpu-200gb`
    EOF
  }
}
data "units_data_size" "boot_disk_ng_gpu" {
  gibibytes = var.k8s_cluster_node_group_gpu.boot_disk.size_gibibytes
}
