locals {
  monitoring_namespace                    = "monitoring-system"
  logs_namespace                         = "logs-system"
  cert_manager_version                    = "v1.15.2"
  cert_manager_chart                      = "cert-manager"
  cert_manager_namespace                  = "cert-manager"
  chart_victoria_metrics_operator         = "victoria-metrics-operator"
  chart_victoria_metrics_operator_version = "0.33.6"
  chart_vm_logs                           = "victoria-logs-single"
  chart_vm_logs_version                   = "0.5.4"
  chart_prometheus_stack                  = "kube-prometheus-stack"
  chart_prometheus_stack_version          = "61.8.0"
  memory_vmsingle                        = "1024Mi"
  requests_cpu_vmsingle                  = "250m"
  memory_vmagent                         = "256Mi"
  requests_cpu_vmagent                   = "250m"
  memory_logs_collector                  = "256Mi"
  requests_cpu_logs_collector            = "200m"
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
  name       = "prometheus-stack"
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
    name  = "grafana.alertmanager.enabled"
    value = "false"
  }

   set {
    name  = "grafana.sidecar.datasources.url"
    value = "http://${local.otel_collector_http_host}.:${local.otel_collector_port}"
  }

  set {
    name  = "grafana.defaultDashboardsEnabled"
    value = "false"
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
              memory: ${local.memory_vmsingle}
              cpu: ${local.requests_cpu_vmsingle}
            limits:
              memory: ${local.memory_vmsingle}
      - apiVersion: operator.victoriametrics.com/v1beta1
        kind: VMAgent
        metadata:
          name: select-all
        spec:
          remoteWrite:
            - url: "http://${local.otel_collector_http_host}.:${local.otel_collector_port}/api/v1/write"
          # Replication:
          scrapeInterval: 30s
          selectAllByDefault: true
          resources:
            requests:
              memory: ${local.memory_vmagent}
              cpu: ${local.requests_cpu_vmagent}
            limits:
              memory: ${local.memory_vmagent}

      - apiVersion: v1
        kind: Service
        metadata:
          name: kubelet-metrics
          labels:
            k8s-app: kubelet
        spec:
          selector:
            app.kubernetes.io/name: prometheus-node-exporter
          ports:
            - port: 10250
              targetPort: 10250
              protocol: TCP
              name: https-metrics
          clusterIP: None
      - apiVersion: monitoring.coreos.com/v1
        kind: ServiceMonitor
        metadata:
          name: kubelet
        spec:
          attachMetadata:
            node: false
          endpoints:
          - bearerTokenFile: /var/run/secrets/kubernetes.io/serviceaccount/token
            honorLabels: true
            honorTimestamps: true
            port: https-metrics
            relabelings:
            - action: replace
              sourceLabels:
              - __metrics_path__
              targetLabel: metrics_path
            scheme: https
            tlsConfig:
              caFile: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
              insecureSkipVerify: true
          - bearerTokenFile: /var/run/secrets/kubernetes.io/serviceaccount/token
            honorLabels: true
            honorTimestamps: true
            metricRelabelings:
            - action: drop
              regex: container_cpu_(cfs_throttled_seconds_total|load_average_10s|system_seconds_total|user_seconds_total)
              sourceLabels:
              - __name__
            - action: drop
              regex: container_fs_(io_current|io_time_seconds_total|io_time_weighted_seconds_total|reads_merged_total|sector_reads_total|sector_writes_total|writes_merged_total)
              sourceLabels:
              - __name__
            - action: drop
              regex: container_memory_(mapped_file|swap)
              sourceLabels:
              - __name__
            - action: drop
              regex: container_(file_descriptors|tasks_state|threads_max)
              sourceLabels:
              - __name__
            - action: drop
              regex: container_spec.*
              sourceLabels:
              - __name__
            - action: drop
              regex: .+;
              sourceLabels:
              - id
              - pod
            path: /metrics/cadvisor
            port: https-metrics
            relabelings:
            - action: replace
              sourceLabels:
              - __metrics_path__
              targetLabel: metrics_path
            scheme: https
            tlsConfig:
              caFile: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
              insecureSkipVerify: true
          - bearerTokenFile: /var/run/secrets/kubernetes.io/serviceaccount/token
            honorLabels: true
            honorTimestamps: true
            path: /metrics/probes
            port: https-metrics
            relabelings:
            - action: replace
              sourceLabels:
              - __metrics_path__
              targetLabel: metrics_path
            scheme: https
            tlsConfig:
              caFile: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
              insecureSkipVerify: true
          jobLabel: k8s-app
          selector:
            matchLabels:
              k8s-app: kubelet
    EOF
  ]
}


resource "helm_release" "logs_collector" {
    count = var.k8s_monitoring_enabled ? 1 : 0
  depends_on = [
    module.k8s_cluster,
    helm_release.cert_manager,
    helm_release.prometheus,
    helm_release.vm_logs,
  ]
  name       = "logs-collector"
  namespace  = local.logs_namespace
  repository = "https://fluent.github.io/helm-charts"
  chart      = "fluent-bit"
  version    = "0.47.7"
  values = [
    <<-EOF
rbac:
  create: true
  nodeAccess: false
  eventsAccess: true

serviceMonitor:
  enabled: true
  interval: 30s
  scrapeTimeout: 20s

dashboards:
  enabled: true
  labelKey: grafana_dashboard
  labelValue: 1
  annotations: {}
  namespace: ""


resources:
  limits:
    cpu: 100m
    memory: 128Mi
  requests:
    cpu: 100m
    memory: 128Mi

config:
  service: |
    [SERVICE]
        Daemon Off
        Flush {{ .Values.flush }}
        Log_Level {{ .Values.logLevel }}
        Parsers_File /fluent-bit/etc/parsers.conf
        Parsers_File /fluent-bit/etc/conf/custom_parsers.conf
        HTTP_Server On
        HTTP_Listen 0.0.0.0
        HTTP_Port {{ .Values.metricsPort }}
        Health_Check On

  inputs: |
    [INPUT]
        Name tail
        Path /var/log/containers/*.log
        multiline.parser docker, cri
        Tag kube.*
        Mem_Buf_Limit 5MB
        Skip_Long_Lines On

    [INPUT]
        Name systemd
        Tag host.*
        Systemd_Filter _SYSTEMD_UNIT=kubelet.service
        Read_From_Tail On

  filters: |
    [FILTER]
        Name kubernetes
        Match kube.*
        Merge_Log On
        Keep_Log Off
        K8S-Logging.Parser On
        K8S-Logging.Exclude On

  outputs: |
    [Output]
        Name http
        Match *
        host collect-victoria-logs-single-server.${local.logs_namespace}.svc.cluster.local.
        port 9428
        compress gzip
        uri /insert/jsonline?_stream_fields=stream&_msg_field=log&_time_field=date
        format json_lines
        json_date_format iso8601
        header AccountID 0
        header ProjectID 0

  customParsers: |
    [PARSER]
        Name docker_no_time
        Format json
        Time_Keep Off
        Time_Key time
        Time_Format %Y-%m-%dT%H:%M:%S.%L

volumeMounts:
  - name: config
    mountPath: /fluent-bit/etc/conf

daemonSetVolumes:
  - name: varlog
    hostPath:
      path: /var/log
  - name: varlibdockercontainers
    hostPath:
      path: /var/lib/docker/containers
  - name: etcmachineid
    hostPath:
      path: /etc/machine-id
      type: File

daemonSetVolumeMounts:
  - name: varlog
    mountPath: /var/log
  - name: varlibdockercontainers
    mountPath: /var/lib/docker/containers
    readOnly: true
  - name: etcmachineid
    mountPath: /etc/machine-id
    readOnly: true

command:
  - /fluent-bit/bin/fluent-bit

args:
  - --workdir=/fluent-bit/etc
  - --config=/fluent-bit/etc/conf/fluent-bit.conf

logLevel: info

hotReload:
  enabled: true
  image:
    repository: ghcr.io/jimmidyson/configmap-reload
    tag: v0.11.1
    digest:
    pullPolicy: IfNotPresent
  resources: {}
EOF
  ]
}

resource "helm_release" "vm_logs" {
  count = var.k8s_monitoring_enabled ? 1 : 0
  depends_on = [
    module.k8s_cluster,
    helm_release.cert_manager,
  ]
  name       = "collect"
  repository = "https://victoriametrics.github.io/helm-charts/"
  chart      = local.chart_vm_logs
  version    = local.chart_vm_logs_version
  namespace  = local.logs_namespace
  create_namespace = true
  wait             = true
  timeout = 600
}
