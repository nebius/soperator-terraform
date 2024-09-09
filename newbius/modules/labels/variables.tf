variable "custom_labels" {
  description = "Custom labels to be used for all created resources."
  type        = map(string)
  default     = {}
}

variable "ng_name_cpu" {
  description = "Name of the 'cpu' node group."
  type        = string
  default     = "cpu"
}

variable "ng_name_gpu" {
  description = "Name of the 'gpu' node group."
  type        = string
  default     = "gpu"
}

variable "ng_name_nlb" {
  description = "Name of the 'gpu' node group."
  type        = string
  default     = "gpu"
}
