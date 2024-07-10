resource "nebius_vpc_network" "this" {
  count     = var.k8s_network_id == "" ? 1 : 0
  name      = "k8s-${local.k8s_cluster_normalized_name}-network"
  folder_id = var.k8s_folder_id
}

locals {
  k8s_cluster_network_id = coalesce(try(nebius_vpc_network.this[0].id, ""), var.k8s_network_id)
}

resource "nebius_vpc_gateway" "this" {
  name      = "k8s-${local.k8s_cluster_normalized_name}-nat-gateway"
  folder_id = var.k8s_folder_id

  shared_egress_gateway {}
}

resource "nebius_vpc_route_table" "this" {
  name = "k8s-${local.k8s_cluster_normalized_name}-route-table"

  depends_on = [
    local.k8s_cluster_network_id,
    nebius_vpc_gateway.this
  ]

  folder_id  = var.k8s_folder_id
  network_id = local.k8s_cluster_network_id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = nebius_vpc_gateway.this.id
  }
}

resource "nebius_vpc_subnet" "this" {
  name = "k8s-${local.k8s_cluster_normalized_name}-subnet"

  depends_on = [
    local.k8s_cluster_network_id,
    nebius_vpc_route_table.this
  ]

  folder_id      = var.k8s_folder_id
  zone           = var.k8s_cluster_zone_id
  v4_cidr_blocks = var.k8s_cluster_subnet_cidr_blocks
  network_id     = local.k8s_cluster_network_id
  route_table_id = nebius_vpc_route_table.this.id
}

resource "nebius_vpc_address" "this" {
  name = "k8s-${local.k8s_cluster_normalized_name}-slurm-address-subnet"

  depends_on = [
    nebius_vpc_subnet.this
  ]

  folder_id = var.k8s_folder_id

  external_ipv4_address {
    zone_id = var.k8s_cluster_zone_id
  }
}
