resource "nebius_mk8s_v1alpha1_cluster" "this" {
  depends_on = [
    data.nebius_vpc_v1alpha1_subnet.this,
  ]

  parent_id = data.nebius_iam_v1_project.this.id

  name   = var.k8s_cluster_name
  labels = module.labels.labels_common

  control_plane = {
    subnet_id = data.nebius_vpc_v1alpha1_subnet.this.id

    version = var.k8s_version
    endpoints = {
      public_endpoint = {}
    }
  }
}
