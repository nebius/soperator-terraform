locals {
  ssh_public_key = var.glusterfs_cluster_ssh_public_key != null ? var.glusterfs_cluster_ssh_public_key : (
  fileexists(var.glusterfs_cluster_ssh_public_key_path) ? file(var.glusterfs_cluster_ssh_public_key_path) : null)
}

module "gluster-module" {
  providers = {
    nebius = nebius
  }
  count             = var.slurm_cluster_storages.jail.type == "glusterfs" ? 1 : 0
  source            = "./gluster-module"
  folder_id         = var.glusterfs_cluster_folder_id
  ext_subnet_id     = nebius_vpc_subnet.this.id
  disk_size         = var.glusterfs_cluster_disk_size
  storage_nodes     = var.glusterfs_cluster_nodes
  disk_count_per_vm = var.glusterfs_cluster_disks_per_node
  ssh_pubkey        = local.ssh_public_key
  is_standalone     = false
}
