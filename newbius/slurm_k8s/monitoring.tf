module "monitoring" {
  depends_on = [
    helm_release.gpu-operator,
  ]

  source = "../modules/monitoring"

  slurm_cluster_name = var.slurm_cluster_name

  providers = {
    nebius = nebius
    helm   = helm
  }
}
