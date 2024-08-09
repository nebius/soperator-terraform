locals {
  otel_operator_version = "0.66.0"
  otel_repository       = "https://open-telemetry.github.io/opentelemetry-helm-charts"
  otel_chart            = "opentelemetry-operator"
  otel_name             = "otel"
  otel_namespace        = "opentelemetry-operator-system"
}

resource "helm_release" "open-telemetry" {
  count            = var.k8s_cluster_operator_opentelemetry_operator_enabled ? 1 : 0
  name             = local.otel_name
  repository       = local.otel_repository
  chart            = local.otel_chart
  version          = local.otel_operator_version
  namespace        = local.otel_namespace
  create_namespace = true
  wait             = true
  set {
    name  = "manager.collectorImage.repository"
    value = "otel/opentelemetry-collector-k8s"
  }
  set {
    name  = "admissionWebhooks.certManager.enabled"
    value = false
  }
  set {
    name  = "admissionWebhooks.autoGenerateCert.enabled"
    value = true
  }
}
