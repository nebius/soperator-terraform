locals {
  new_filestores = concat(
    var.slurm_cluster_storages.jail.type == "filestore" && var.slurm_cluster_storages.jail.filestore_id == null
    ? [var.slurm_cluster_storages.jail]
    : [],
    var.slurm_cluster_storages.controller_spool.filestore_id == null
    ? [var.slurm_cluster_storages.controller_spool]
    : [],
    [for submount in var.slurm_cluster_storages.jail_submounts : submount if submount.filestore_id == null]
  )

  existing_filestores = concat(
    var.slurm_cluster_storages.jail.type == "filestore" && var.slurm_cluster_storages.jail.filestore_id != null
    ? [var.slurm_cluster_storages.jail]
    : [],
    var.slurm_cluster_storages.controller_spool.filestore_id != null
    ? [var.slurm_cluster_storages.controller_spool]
    : [],
    [for submount in var.slurm_cluster_storages.jail_submounts : submount if submount.filestore_id != null]
  )

  existing_filestores_map = zipmap(
    range(length(local.existing_filestores)),
    local.existing_filestores
  )
}

resource "nebius_compute_filesystem" "created_filestores" {
  for_each = {
    for f in local.new_filestores : f.name => f.size
  }

  name       = "k8s-${local.k8s_cluster_normalized_name}-${each.key}-filestore"
  folder_id  = var.k8s_folder_id
  size       = ceil(each.value / local.unit_gb)
  block_size = var.k8s_cluster_filestore_block_size
  zone       = var.k8s_cluster_zone_id
  type       = "network-ssd"
  labels = {
    "slurm-filestore" = each.key
  }
}

resource "null_resource" "created_filestore_attachment" {
  for_each = nebius_compute_filesystem.created_filestores

  depends_on = [
    nebius_vpc_subnet.this,
    module.k8s_cluster,
    nebius_compute_filesystem.created_filestores,
    null_resource.existing_filestore_attachment
  ]

  provisioner "local-exec" {
    # language=basha
    command = <<EOF
      set -e

      # Define the folder_id to find the instances
      folder_id="${var.k8s_folder_id}"

      # Define the subnet_id and k8s_cluster_id to filter the instances
      subnet_id="${nebius_vpc_subnet.this.id}"
      k8s_cluster_id="${module.k8s_cluster.cluster_id}"

      # Define the filesystem details to attach
      filesystem_id="${each.value.id}"

      # Fetch the list of instance IDs that are connected to the specified subnet and k8s cluster
      instance_ids=$(ncp --folder-id "$folder_id" compute instance list --format json | \
          jq -r ".[] | select(.network_interfaces[].subnet_id == \"$subnet_id\" and .labels.\"managed-kubernetes-cluster-id\" == \"$k8s_cluster_id\") | .id")

      echo "Attaching filesystem ${each.value.name} ($filesystem_id)"

      # Loop through each instance ID and attach the filesystem
      for id in $instance_ids; do
          echo "Instance $id"
          ncp --folder-id "$folder_id" compute instance attach-filesystem $id \
              --filesystem-id $filesystem_id \
              --device-name ${each.value.labels.slurm-filestore}
          echo "Filesystem attached to instance $id"
      done

      echo "All operations have been initiated."
    EOF
  }
}

resource "null_resource" "existing_filestore_attachment" {
  for_each = local.existing_filestores_map

  depends_on = [
    nebius_vpc_subnet.this,
    module.k8s_cluster,
    local.existing_filestores
  ]

  provisioner "local-exec" {
    # language=basha
    command = <<EOF
      set -e

      # Define the folder_id to find the instances
      folder_id="${var.k8s_folder_id}"

      # Define the subnet_id and k8s_cluster_id to filter the instances
      subnet_id="${nebius_vpc_subnet.this.id}"
      k8s_cluster_id="${module.k8s_cluster.cluster_id}"

      # Define the filesystem details to attach
      filesystem_id="${each.value.filestore_id}"

      # Fetch the list of instance IDs that are connected to the specified subnet and k8s cluster
      instance_ids=$(ncp --folder-id "$folder_id" compute instance list --format json | \
          jq -r ".[] | select(.network_interfaces[].subnet_id == \"$subnet_id\" and .labels.\"managed-kubernetes-cluster-id\" == \"$k8s_cluster_id\") | .id")

      echo "Attaching filesystem ${each.value.name} ($filesystem_id)"

      # Loop through each instance ID and attach the filesystem
      for id in $instance_ids; do
          echo "Instance $id"
          ncp --folder-id "$folder_id" compute instance attach-filesystem $id \
              --filesystem-id $filesystem_id \
              --device-name ${each.value.name}
          echo "Filesystem attached to instance $id"
      done

      echo "All operations have been initiated."
    EOF
  }
}
