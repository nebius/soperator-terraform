locals {
  slurm_chart_path      = "../../helm"
  slurm_chart_operator  = "slurm-operator"
  slurm_chart_filestore = "slurm-cluster-filestore"
  slurm_chart_cluster   = "slurm-cluster"

  slurm_cluster_name = trimsuffix(substr(replace(trimspace(var.slurm_cluster_name), " ", "-"), 0, 63), "-")
}

resource "helm_release" "slurm_operator" {
  chart   = "${local.slurm_chart_path}}/${local.slurm_chart_operator}"
  name    = "${local.slurm_chart_operator}-${var.slurm_operator_version}"
  version = var.slurm_operator_version

  depends_on = [
    module.k8s_cluster
  ]

  namespace        = local.slurm_chart_operator
  create_namespace = true

  wait = true
}

resource "helm_release" "slurm_cluster_filestore" {
  chart   = "${local.slurm_chart_path}}/${local.slurm_chart_filestore}"
  name    = "${local.slurm_chart_filestore}-${var.slurm_operator_version}"
  version = var.slurm_operator_version

  depends_on = [
    module.k8s_cluster,
    null_resource.filestore_attachment
  ]

  namespace        = local.slurm_cluster_name
  create_namespace = true

  set {
    name  = ""
    value = ""
  }

  set {
    name  = ""
    value = ""
  }

  wait          = true
  wait_for_jobs = true
}

resource "helm_release" "slurm_cluster" {
  chart   = "${local.slurm_chart_path}/${local.slurm_chart_cluster}"
  name    = "${local.slurm_chart_cluster}-${var.slurm_operator_version}"
  version = var.slurm_operator_version

  depends_on = [
    helm_release.slurm_operator,
    helm_release.slurm_cluster_filestore,
  ]

  namespace        = local.slurm_cluster_name
  create_namespace = true

  set {
    name  = ""
    value = ""
  }

  set {
    name  = ""
    value = ""
  }

  wait          = true
  wait_for_jobs = true
}
