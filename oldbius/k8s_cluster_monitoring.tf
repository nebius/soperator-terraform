locals {
  monitoring_namespace                    = "monitoring-system"
  cert_manager_version                    = "v1.15.2"
  cert_manager_chart                      = "cert-manager"
  cert_manager_namespace                  = "cert-manager"
  chart_victoria_metrics_operator         = "victoria-metrics-operator"
  chart_victoria_metrics_operator_version = "0.33.6"
  chart_prometheus_stack                  = "kube-prometheus-stack"
  chart_prometheus_stack_version          = "61.8.0"
  otel_operator_version                   = "0.66.0"
  otel_chart                              = "opentelemetry-operator"
  otel_name                               = "otel"
  otel_namespace                          = "opentelemetry-operator-system"
}

resource "helm_release" "open-telemetry" {
  count            = var.k8s_cluster_operator_opentelemetry_operator_enabled ? 1 : 0
  depends_on = [
    module.k8s_cluster,
    helm_release.cert_manager,
    helm_release.prometheus,
  ]
  name             = local.otel_name
  repository       = "https://open-telemetry.github.io/opentelemetry-helm-charts"
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

resource "helm_release" "cert_manager" {
  count = var.k8s_monitoring_enabled ? 1 : 0
  depends_on = [
    module.k8s_cluster,
  ]
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = local.cert_manager_chart
  version          = local.cert_manager_version
  namespace        = local.cert_manager_namespace
  create_namespace = true
  wait             = true
  set {
    name  = "crds.enabled"
    value = "true"
  }
  set {
    name  = "prometheus.enabled"
    value = "false"
  }
}


resource "helm_release" "victoria_metrics_operator" {
  count = var.k8s_monitoring_enabled ? 1 : 0
  depends_on = [
    module.k8s_cluster,
    helm_release.cert_manager,
    helm_release.prometheus,
  ]
  name             = "vm"
  repository       = "https://victoriametrics.github.io/helm-charts/"
  chart            = local.chart_victoria_metrics_operator
  version          = local.chart_victoria_metrics_operator_version
  namespace        = local.monitoring_namespace
  create_namespace = true
  wait             = true

  set {
    name  = "replicaCount"
    value = "1"
  }

  set {
    name  = "createCRD"
    value = "true"
  }

  set {
    name  = "operator.enable_converter_ownership"
    value = "true"
  }
  # -- By default, operator converts prometheus-operator objects.
  set {
    name  = "operator.disable_prometheus_converter"
    value = "false"
  }

  set {
    name  = "podDisruptionBudget.enabled"
    value = "false"
  }

  set {
    name  = "resources.limits.memory"
    value = "256Mi"
  }

  set {
    name  = "resources.requests.cpu"
    value = "50m"
  }

  set {
    name  = "resources.requests.memory"
    value = "256Mi"
  }

  set {
    name  = "admissionWebhooks.enabled"
    value = "true"
  }
  set {
    name  = "admissionWebhooks.certManager.enabled"
    value = true
  }
  set {
    name  = "admissionWebhooks.enabledCRDValidation.vmsingle"
    value = "true"
  }
}

resource "helm_release" "prometheus" {
  count = var.k8s_monitoring_enabled ? 1 : 0
  depends_on = [
    module.k8s_cluster,
    helm_release.cert_manager,
  ]
  name       = "prometheus-operator-crds"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = local.chart_prometheus_stack
  version    = local.chart_prometheus_stack_version
  namespace  = local.monitoring_namespace
  create_namespace = true
  wait             = true
  timeout = 600
  set {
    name  = "prometheusOperator.enabled"
    value = "false"
  }

  set {
    name  = "alertmanager.enabled"
    value = "false"
  }

  set {
    name  = "grafana.enabled"
    value = "true"
  }

  set {
    name  = "kubeStateMetrics.enabled"
    value = "true"
  }

  set {
    name  = "nodeExporter.enabled"
    value = "true"
  }

  set {
    name  = "prometheus.enabled"
    value = "false"
  }
}

resource "helm_release" "vmsingle" {
    count = var.k8s_monitoring_enabled ? 1 : 0
  depends_on = [
    module.k8s_cluster,
    helm_release.cert_manager,
    helm_release.prometheus,
    helm_release.victoria_metrics_operator,
  ]
  name       = "slurm-monitor"
  namespace  = local.monitoring_namespace
  repository = "https://bedag.github.io/helm-charts/"
  chart      = "raw"
  version    = "2.0.0"
  values = [
    <<-EOF
    resources:
      - apiVersion: operator.victoriametrics.com/v1beta1
        kind: VMSingle
        metadata:
          name: slurm
        spec:
          replicas: 1
          retentionPeriod: "30"
          extraArgs:
            dedup.minScrapeInterval: 30s
          resources:
            requests:
              memory: "64Mi"
              cpu: "250m"
            limits:
              memory: "128Mi"
              cpu: "250m"
      - apiVersion: operator.victoriametrics.com/v1beta1
        kind: VMAgent
        metadata:
          name: select-all
        spec:
          remoteWrite:
            - url: "http://vmsingle-slurm:8429/api/v1/write"
          # Replication:
          scrapeInterval: 30s
          selectAllByDefault: true
          resources:
            requests:
              memory: "64Mi"
              cpu: "250m"
            limits:
              memory: "128Mi"
              cpu: "250m"
    EOF
  ]
}
