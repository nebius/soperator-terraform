variable "filestore_jail" {
  description = "Shared filesystem to be used on controller, worker, and login nodes."
  type = object({
    size_gibibytes       = number
    block_size_kibibytes = number
  })
  default = {
    size_gibibytes       = 2048
    block_size_kibibytes = 32
  }
}

variable "filestore_controller_spool" {
  description = "Shared filesystem to be used on controller nodes."
  type = object({
    size_gibibytes       = number
    block_size_kibibytes = number
  })
  default = {
    size_gibibytes       = 128
    block_size_kibibytes = 4
  }
}

variable "filestore_jail_submounts" {
  description = "Shared filesystems to be mounted inside jail."
  type = list(object({
    name                 = string
    size_gibibytes       = number
    block_size_kibibytes = number
    mount_path           = string
  }))
  default = []
}
