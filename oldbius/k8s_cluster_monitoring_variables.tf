variable "k8s_monitoring_enabled" {
  description = "Whether to enable monitoring."
  type        = bool
  default     = true
}

variable "memory_vmsingle" {
  type = string
  default = "1536Mi"
}

variable "requests_cpu_vmsingle" {
  type = string
  default = "250m"
}

variable "size_vmsingle" {
  type = string
  default = "40Gi"
}

variable "memory_vmagent" {
  type = string
  default = "384Mi"
  
}

variable "requests_cpu_vmagent" {
  type = string
  default = "250m"
}

variable "memory_logs_collector" {
  type = string
  default = "256Mi"
}

variable "requests_cpu_logs_collector" {
  type = string
  default = "200m"
}

variable "size_server_logs" {
  type = string
  default = "40Gi"
}

variable "memory_server_logs" {
  type = string
  default = "512Mi"
}

variable "requests_cpu_server_logs" {
  type = string
  default = "250m"
}
