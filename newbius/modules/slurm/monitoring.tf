module "monitoring" {
  source = "../monitoring"

  slurm_cluster_name = var.name

  providers = {
    helm = helm
  }
}
