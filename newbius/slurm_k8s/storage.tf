module "filestore" {
  source = "../modules/filestore"

  iam_project_id   = data.nebius_iam_v1_project.this.id
  k8s_cluster_id   = nebius_mk8s_v1alpha1_cluster.this.id
  k8s_cluster_name = var.k8s_cluster_name

  jail = {
    disk_type            = "NETWORK_SSD"
    size_gibibytes       = var.filestore_jail.size_gibibytes
    block_size_kibibytes = var.filestore_jail.block_size_kibibytes
  }

  controller_spool = {
    disk_type            = "NETWORK_SSD"
    size_gibibytes       = var.filestore_controller_spool.size_gibibytes
    block_size_kibibytes = var.filestore_controller_spool.block_size_kibibytes
  }

  jail_submounts = [for submount in var.filestore_jail_submounts : {
    name                 = submount.name
    disk_type            = "NETWORK_SSD"
    size_gibibytes       = submount.size_gibibytes
    block_size_kibibytes = submount.block_size_kibibytes
  }]

  common_labels = module.labels.labels_common

  providers = {
    nebius = nebius
    units  = units
  }
}
