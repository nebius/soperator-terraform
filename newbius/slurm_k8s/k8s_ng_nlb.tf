data "units_data_size" "ng_nlb_boot_disk" {
  count = local.login.create_nlb_ng ? 1 : 0

  gibibytes = "64"
}

resource "nebius_mk8s_v1_node_group" "nlb" {
  count = local.login.create_nlb_ng ? 1 : 0

  depends_on = [
    nebius_mk8s_v1_cluster.this,
  ]

  parent_id = nebius_mk8s_v1_cluster.this.id

  name = local.name.node_group.nlb
  labels = merge(
    module.labels.labels_common,
    module.labels.label_group_name_nlb
  )

  version          = var.k8s_version
  fixed_node_count = 1

  template = {
    metadata = {
      labels = module.labels.label_group_name_nlb
    }

    resources = {
      platform = "cpu-e2"
      preset   = "2vcpu-8gb"
    }

    boot_disk = {
      type       = "NETWORK_SSD"
      size_bytes = one(data.units_data_size.ng_nlb_boot_disk).bytes
    }

    network_interfaces = [{
      public_ip_address = {}
      subnet_id         = data.nebius_vpc_v1alpha1_subnet.this.id
    }]
  }
}
