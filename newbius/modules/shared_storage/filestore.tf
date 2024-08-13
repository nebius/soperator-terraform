locals {
  name_suffixes = {
    filesystem = {
      shared = "shared"
    }
  }

  names = {
    filesystem = {
      shared = join("-", [
        trimsuffix(
          substr(
            var.k8s_cluster_name,
            0,
            64 - (length(local.name_suffixes.filesystem.shared) + 1)
          ),
          "-"
        ),
        local.name_suffixes.filesystem.shared
      ])
    }
  }
}

data "units_data_size" "storage" {
  count = var.filestore_create ? 1 : 0

  gibibytes = var.filestore_create_spec.size_gibibytes
}

data "units_data_size" "block" {
  count = var.filestore_create ? 1 : 0

  kibibytes = var.filestore_create_spec.block_size_kibibytes
}

resource "nebius_compute_v1alpha1_filesystem" "shared" {
  count = var.filestore_create ? 1 : 0

  parent_id = var.iam_project_id

  name   = local.names.filesystem.shared
  labels = var.filestore_labels

  type             = var.filestore_create_spec.disk_type
  size_bytes       = one(data.units_data_size.storage).bytes
  block_size_bytes = one(data.units_data_size.block).bytes
}

data "nebius_compute_v1alpha1_filesystem" "shared" {
  count = var.filestore_create ? 0 : 1

  id = var.filestore_existing_id
}

locals {
  filestore_id = coalesce(
    one(nebius_compute_v1alpha1_filesystem.shared[*].id),
    one(data.nebius_compute_v1alpha1_filesystem.shared[*].id)
  )
}
