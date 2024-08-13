variable "filestore_create" {
  description = "Whether to create new filestore filesystem."
  type        = bool
  nullable    = false
}

variable "filestore_create_spec" {
  description = "Specification for new filestore in case of creation."
  type = object({
    disk_type            = string
    size_gibibytes       = number
    block_size_kibibytes = number
  })
  nullable = true
}

variable "filestore_labels" {
  description = "Labels to set for filestore in case of creation."
  type        = map(string)
  default     = {}
}

variable "filestore_existing_id" {
  description = "ID of existing filestore to attach to."
  type        = string
  nullable    = true
}
