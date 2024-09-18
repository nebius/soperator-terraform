module "monitoring" {
  source = "../monitoring"

  slurm_cluster_name = var.name

  grafana_admin_password = var.telemetry_grafana_admin_password

  providers = {
    helm = helm
  }
}
