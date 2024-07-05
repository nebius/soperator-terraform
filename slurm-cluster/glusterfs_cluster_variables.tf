variable "glusterfs_cluster_folder_id" {
  description = "Folder ID to create GlusterFS"
}

variable "glusterfs_cluster_ssh_public_key" {
  description = "Public SSH key to access the cluster nodes."
  type        = string
  default     = null
}

variable "glusterfs_cluster_ssh_public_key_path" {
  description = "Path to a SSH public key to access the cluster nodes."
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "glusterfs_cluster_disk_size" {
  description = "Size of the disk on each GlusterFS node in GiB"
  type        = number
  default     = 372
}

variable "glusterfs_cluster_nodes" {
  description = "Number of nodes constituting the GlusterFS cluster"
  type        = number
  default     = 3
}

variable "glusterfs_cluster_disks_per_node" {
  description = "Number of disks attached to each GlusterFS node"
  type        = number
  default     = 1
}
