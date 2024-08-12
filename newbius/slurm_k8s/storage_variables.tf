variable "filestore_create" {
  description = "Whether to create new filestore filesystem."
  type        = bool
  default     = true
}

variable "filestore_existing_id" {
  description = "ID of existing filestore to attach to."
  type        = string
  default     = null
}

variable "storage_jail_size_gibibytes" {
  description = "Size of the shared filesystem to be used on controller, worker, and login nodes."
  type        = number
  default     = 2048
}

variable "storage_controller_spool_size_gibibytes" {
  description = "Storage dedicated for controller node's spool."
  type        = number
  default     = 32
}

variable "storage_jail_sub_mounts" {
  description = "Extra filesystem mounts inside jail."
  type = list(object({
    name           = string
    device_name    = string
    size_gibibytes = number
  }))
  default = []
}
