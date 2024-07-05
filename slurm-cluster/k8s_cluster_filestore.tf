locals {
  jail_filestore = var.slurm_cluster_storages.jail.type == "filestore" ? [var.slurm_cluster_storages.jail] : []

  all_filestores = concat(
    local.jail_filestore,
    [var.slurm_cluster_storages.controller_spool],
    var.slurm_cluster_storages.jail_submounts
  )
}

resource "nebius_compute_filesystem" "filestores" {
  for_each = {
    for f in local.all_filestores : f.name => f.size
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

resource "null_resource" "filestore_attachment" {
  for_each = nebius_compute_filesystem.filestores

  depends_on = [
    nebius_vpc_subnet.this,
    module.k8s_cluster,
    nebius_compute_filesystem.filestores
  ]

  provisioner "local-exec" {
    # language=basha
    command = <<EOF
      # Define the subnet_id to filter the instances
      subnet_id="${nebius_vpc_subnet.this.id}"

      # Define the filesystem details to attach
      filesystem_id="${each.value.id}"

      # Fetch the list of instance IDs that are connected to the specified subnet
      instance_ids=$(ncp compute instance list --format json | jq -r ".[] | select(.network_interfaces[].subnet_id == \"$subnet_id\") | .id")

      echo "Attaching filesystem ${each.value.name} ($filesystem_id)"

      # Loop through each instance ID and attach the filesystem
      for id in $instance_ids; do
          echo "Instance $id"
          ncp compute instance attach-filesystem $id \
              --filesystem-id $filesystem_id \
              --device-name ${each.value.labels.slurm-filestore}
          echo "Filesystem attached to instance $id"
      done

      echo "All operations have been initiated."
    EOF
  }
}
