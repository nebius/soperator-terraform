resource "helm_release" "pod_resources" {
    count = var.k8s_monitoring_enabled ? 1 : 0
  depends_on = [
    module.k8s_cluster,
    helm_release.cert_manager,
    helm_release.prometheus,
    helm_release.victoria_metrics_operator,
  ]
  name       = "slurm-pod-resources"
  namespace  = local.monitoring_namespace
  repository = "https://bedag.github.io/helm-charts/"
  chart      = "raw"
  version    = "2.0.0"
  values = [
    <<-EOF
    resources:
      - apiVersion: v1
        data:
          pod_resources.json: |-
            {
              "annotations": {
                "list": [
                  {
                    "builtIn": 1,
                    "datasource": {
                      "type": "prometheus",
                      "uid": "prometheus"
                    },
                    "enable": true,
                    "hide": true,
                    "iconColor": "rgba(0, 211, 255, 1)",
                    "name": "Annotations & Alerts",
                    "target": {
                      "limit": 100,
                      "matchAny": false,
                      "tags": [],
                      "type": "dashboard"
                    },
                    "type": "dashboard"
                  }
                ]
              },
              "description": "",
              "editable": true,
              "fiscalYearStartMonth": 0,
              "gnetId": 14678,
              "graphTooltip": 0,
              "id": 4,
              "links": [],
              "liveNow": false,
              "panels": [
                {
                  "datasource": {
                    "type": "prometheus",
                    "uid": "prometheus"
                  },
                  "fieldConfig": {
                    "defaults": {
                      "color": {
                        "mode": "thresholds"
                      },
                      "mappings": [],
                      "thresholds": {
                        "mode": "absolute",
                        "steps": [
                          {
                            "color": "green",
                            "value": null
                          }
                        ]
                      }
                    },
                    "overrides": []
                  },
                  "gridPos": {
                    "h": 8,
                    "w": 12,
                    "x": 0,
                    "y": 0
                  },
                  "id": 19,
                  "options": {
                    "colorMode": "value",
                    "graphMode": "none",
                    "justifyMode": "center",
                    "orientation": "auto",
                    "percentChangeColorMode": "standard",
                    "reduceOptions": {
                      "calcs": [
                        "mean"
                      ],
                      "fields": "",
                      "values": false
                    },
                    "showPercentChange": false,
                    "textMode": "auto",
                    "wideLayout": true
                  },
                  "pluginVersion": "11.1.0",
                  "targets": [
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "exemplar": true,
                      "expr": "sum(rate(container_cpu_usage_seconds_total{namespace=~\"$namespace\"}[$__rate_interval]))",
                      "interval": "",
                      "legendFormat": "Real",
                      "refId": "A"
                    },
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "exemplar": true,
                      "expr": "sum(kube_pod_container_resource_requests{namespace=~\"$namespace\", unit=\"core\"})",
                      "hide": false,
                      "interval": "",
                      "legendFormat": "Requests (deployments)",
                      "refId": "B"
                    },
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "exemplar": true,
                      "expr": "sum(kube_pod_container_resource_limits{namespace=~\"$namespace\", unit=\"core\"})",
                      "hide": false,
                      "interval": "",
                      "legendFormat": "Limits (deployments)",
                      "refId": "C"
                    },
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "exemplar": true,
                      "expr": "kube_resourcequota{namespace=~\"$namespace\", resource=\"requests.cpu\",type=\"hard\"}",
                      "hide": false,
                      "interval": "",
                      "legendFormat": "Requests (quotas)",
                      "refId": "D"
                    },
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "exemplar": true,
                      "expr": "kube_resourcequota{namespace=~\"$namespace\", resource=\"limits.cpu\",type=\"hard\"}",
                      "hide": false,
                      "interval": "",
                      "legendFormat": "Limits  (quotas)",
                      "refId": "E"
                    }
                  ],
                  "title": "Namespace(s) CPU Usage in cores",
                  "type": "stat"
                },
                {
                  "datasource": {
                    "type": "prometheus",
                    "uid": "prometheus"
                  },
                  "fieldConfig": {
                    "defaults": {
                      "color": {
                        "mode": "thresholds"
                      },
                      "mappings": [],
                      "thresholds": {
                        "mode": "absolute",
                        "steps": [
                          {
                            "color": "green",
                            "value": null
                          }
                        ]
                      },
                      "unit": "bytes"
                    },
                    "overrides": []
                  },
                  "gridPos": {
                    "h": 8,
                    "w": 12,
                    "x": 12,
                    "y": 0
                  },
                  "id": 20,
                  "options": {
                    "colorMode": "value",
                    "graphMode": "none",
                    "justifyMode": "center",
                    "orientation": "auto",
                    "percentChangeColorMode": "standard",
                    "reduceOptions": {
                      "calcs": [
                        "mean"
                      ],
                      "fields": "",
                      "values": false
                    },
                    "showPercentChange": false,
                    "textMode": "auto",
                    "wideLayout": true
                  },
                  "pluginVersion": "11.1.0",
                  "targets": [
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "exemplar": true,
                      "expr": "sum(rate(container_memory_working_set_bytes{namespace=~\"$namespace\"}[$__rate_interval]))",
                      "interval": "",
                      "legendFormat": "Real",
                      "refId": "A"
                    },
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "exemplar": true,
                      "expr": "sum(kube_pod_container_resource_requests{namespace=~\"$namespace\", unit=\"byte\"})",
                      "hide": false,
                      "interval": "",
                      "legendFormat": "Requests (deployments)",
                      "refId": "B"
                    },
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "exemplar": true,
                      "expr": "sum(kube_pod_container_resource_limits{namespace=~\"$namespace\", unit=\"byte\"})",
                      "hide": false,
                      "interval": "",
                      "legendFormat": "Limits (deployments)",
                      "refId": "C"
                    },
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "exemplar": true,
                      "expr": "kube_resourcequota{namespace=~\"$namespace\", resource=\"requests.memory\",type=\"hard\"}",
                      "hide": false,
                      "interval": "",
                      "legendFormat": "Requests (quotas)",
                      "refId": "D"
                    },
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "exemplar": true,
                      "expr": "kube_resourcequota{namespace=~\"$namespace\", resource=\"limits.memory\",type=\"hard\"}",
                      "hide": false,
                      "interval": "",
                      "legendFormat": "Limits (quotas)",
                      "refId": "E"
                    }
                  ],
                  "title": "Namespace(s) CPU Usage Memory",
                  "type": "stat"
                },
                {
                  "datasource": {
                    "type": "prometheus",
                    "uid": "prometheus"
                  },
                  "fieldConfig": {
                    "defaults": {
                      "color": {
                        "mode": "palette-classic"
                      },
                      "custom": {
                        "axisBorderShow": false,
                        "axisCenteredZero": false,
                        "axisColorMode": "text",
                        "axisLabel": "",
                        "axisPlacement": "auto",
                        "barAlignment": 0,
                        "drawStyle": "line",
                        "fillOpacity": 0,
                        "gradientMode": "none",
                        "hideFrom": {
                          "legend": false,
                          "tooltip": false,
                          "viz": false
                        },
                        "insertNulls": false,
                        "lineInterpolation": "linear",
                        "lineWidth": 1,
                        "pointSize": 5,
                        "scaleDistribution": {
                          "type": "linear"
                        },
                        "showPoints": "auto",
                        "spanNulls": false,
                        "stacking": {
                          "group": "A",
                          "mode": "none"
                        },
                        "thresholdsStyle": {
                          "mode": "off"
                        }
                      },
                      "mappings": [],
                      "thresholds": {
                        "mode": "absolute",
                        "steps": [
                          {
                            "color": "green",
                            "value": null
                          },
                          {
                            "color": "red",
                            "value": 80
                          }
                        ]
                      }
                    },
                    "overrides": []
                  },
                  "gridPos": {
                    "h": 8,
                    "w": 12,
                    "x": 0,
                    "y": 8
                  },
                  "id": 8,
                  "options": {
                    "legend": {
                      "calcs": [],
                      "displayMode": "list",
                      "placement": "bottom",
                      "showLegend": true
                    },
                    "tooltip": {
                      "mode": "single",
                      "sort": "none"
                    }
                  },
                  "targets": [
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "exemplar": true,
                      "expr": "max (rate(container_cpu_usage_seconds_total{image!=\"\", image!~\".*pause:.*$\", namespace=\"$namespace\"}[5m])) by (pod)",
                      "interval": "",
                      "legendFormat": "{{ pod }}",
                      "refId": "A"
                    }
                  ],
                  "title": "CPU Namespace",
                  "type": "timeseries"
                },
                {
                  "datasource": {
                    "type": "prometheus",
                    "uid": "prometheus"
                  },
                  "fieldConfig": {
                    "defaults": {
                      "color": {
                        "mode": "palette-classic"
                      },
                      "custom": {
                        "axisBorderShow": false,
                        "axisCenteredZero": false,
                        "axisColorMode": "text",
                        "axisLabel": "",
                        "axisPlacement": "auto",
                        "barAlignment": 0,
                        "drawStyle": "line",
                        "fillOpacity": 0,
                        "gradientMode": "none",
                        "hideFrom": {
                          "legend": false,
                          "tooltip": false,
                          "viz": false
                        },
                        "insertNulls": false,
                        "lineInterpolation": "linear",
                        "lineWidth": 1,
                        "pointSize": 5,
                        "scaleDistribution": {
                          "type": "linear"
                        },
                        "showPoints": "auto",
                        "spanNulls": false,
                        "stacking": {
                          "group": "A",
                          "mode": "none"
                        },
                        "thresholdsStyle": {
                          "mode": "off"
                        }
                      },
                      "mappings": [],
                      "thresholds": {
                        "mode": "absolute",
                        "steps": [
                          {
                            "color": "green",
                            "value": null
                          },
                          {
                            "color": "red",
                            "value": 80
                          }
                        ]
                      },
                      "unit": "bytes"
                    },
                    "overrides": []
                  },
                  "gridPos": {
                    "h": 8,
                    "w": 12,
                    "x": 12,
                    "y": 8
                  },
                  "id": 10,
                  "options": {
                    "legend": {
                      "calcs": [],
                      "displayMode": "list",
                      "placement": "bottom",
                      "showLegend": true
                    },
                    "tooltip": {
                      "mode": "single",
                      "sort": "none"
                    }
                  },
                  "targets": [
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "exemplar": true,
                      "expr": "max (container_memory_working_set_bytes{namespace=\"$namespace\"}) by (pod)",
                      "interval": "",
                      "legendFormat": "{{ pod }}",
                      "refId": "A"
                    }
                  ],
                  "title": "Memory Namespace",
                  "type": "timeseries"
                },
                {
                  "datasource": {
                    "type": "prometheus",
                    "uid": "prometheus"
                  },
                  "fieldConfig": {
                    "defaults": {
                      "color": {
                        "mode": "palette-classic"
                      },
                      "custom": {
                        "axisBorderShow": false,
                        "axisCenteredZero": false,
                        "axisColorMode": "text",
                        "axisLabel": "",
                        "axisPlacement": "auto",
                        "barAlignment": 0,
                        "drawStyle": "line",
                        "fillOpacity": 0,
                        "gradientMode": "none",
                        "hideFrom": {
                          "legend": false,
                          "tooltip": false,
                          "viz": false
                        },
                        "insertNulls": false,
                        "lineInterpolation": "linear",
                        "lineWidth": 1,
                        "pointSize": 5,
                        "scaleDistribution": {
                          "type": "linear"
                        },
                        "showPoints": "auto",
                        "spanNulls": false,
                        "stacking": {
                          "group": "A",
                          "mode": "none"
                        },
                        "thresholdsStyle": {
                          "mode": "off"
                        }
                      },
                      "mappings": [],
                      "thresholds": {
                        "mode": "absolute",
                        "steps": [
                          {
                            "color": "green",
                            "value": null
                          },
                          {
                            "color": "red",
                            "value": 80
                          }
                        ]
                      }
                    },
                    "overrides": []
                  },
                  "gridPos": {
                    "h": 9,
                    "w": 12,
                    "x": 0,
                    "y": 16
                  },
                  "id": 5,
                  "options": {
                    "legend": {
                      "calcs": [],
                      "displayMode": "list",
                      "placement": "bottom",
                      "showLegend": true
                    },
                    "tooltip": {
                      "mode": "multi",
                      "sort": "none"
                    }
                  },
                  "targets": [
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "exemplar": true,
                      "expr": "max (kube_pod_container_resource_requests{resource=\"cpu\", namespace=\"$namespace\", pod=\"$pod\"})",
                      "interval": "",
                      "legendFormat": "requests",
                      "queryType": "randomWalk",
                      "refId": "A"
                    },
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "exemplar": true,
                      "expr": "max (kube_pod_container_resource_limits{resource=\"cpu\", namespace=\"$namespace\", pod=\"$pod\"})",
                      "hide": false,
                      "interval": "",
                      "legendFormat": "limits",
                      "queryType": "randomWalk",
                      "refId": "B"
                    },
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "exemplar": true,
                      "expr": "max (rate(container_cpu_usage_seconds_total{image!=\"\", image!~\"^k8s.gcr.io/pause:.*$\", namespace=\"$namespace\", pod=\"$pod\"}[5m]))",
                      "hide": false,
                      "interval": "",
                      "legendFormat": "usage",
                      "queryType": "randomWalk",
                      "refId": "C"
                    }
                  ],
                  "title": "CPU Pod",
                  "type": "timeseries"
                },
                {
                  "datasource": {
                    "type": "prometheus",
                    "uid": "prometheus"
                  },
                  "fieldConfig": {
                    "defaults": {
                      "color": {
                        "mode": "palette-classic"
                      },
                      "custom": {
                        "axisBorderShow": false,
                        "axisCenteredZero": false,
                        "axisColorMode": "text",
                        "axisLabel": "",
                        "axisPlacement": "auto",
                        "barAlignment": 0,
                        "drawStyle": "line",
                        "fillOpacity": 0,
                        "gradientMode": "none",
                        "hideFrom": {
                          "legend": false,
                          "tooltip": false,
                          "viz": false
                        },
                        "insertNulls": false,
                        "lineInterpolation": "linear",
                        "lineWidth": 1,
                        "pointSize": 5,
                        "scaleDistribution": {
                          "type": "linear"
                        },
                        "showPoints": "auto",
                        "spanNulls": false,
                        "stacking": {
                          "group": "A",
                          "mode": "none"
                        },
                        "thresholdsStyle": {
                          "mode": "off"
                        }
                      },
                      "mappings": [],
                      "thresholds": {
                        "mode": "absolute",
                        "steps": [
                          {
                            "color": "green",
                            "value": null
                          },
                          {
                            "color": "red",
                            "value": 80
                          }
                        ]
                      },
                      "unit": "bytes"
                    },
                    "overrides": []
                  },
                  "gridPos": {
                    "h": 9,
                    "w": 12,
                    "x": 12,
                    "y": 16
                  },
                  "id": 6,
                  "options": {
                    "legend": {
                      "calcs": [],
                      "displayMode": "list",
                      "placement": "bottom",
                      "showLegend": true
                    },
                    "tooltip": {
                      "mode": "multi",
                      "sort": "none"
                    }
                  },
                  "targets": [
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "exemplar": true,
                      "expr": "max (kube_pod_container_resource_requests{resource=\"memory\", namespace=\"$namespace\", pod=\"$pod\"})",
                      "interval": "",
                      "legendFormat": "requests",
                      "queryType": "randomWalk",
                      "refId": "A"
                    },
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "exemplar": true,
                      "expr": "max (kube_pod_container_resource_limits{resource=\"memory\", namespace=\"$namespace\", pod=\"$pod\"})",
                      "hide": false,
                      "interval": "",
                      "legendFormat": "limits",
                      "queryType": "randomWalk",
                      "refId": "B"
                    },
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "exemplar": true,
                      "expr": "max (container_memory_working_set_bytes{namespace=\"$namespace\", pod=\"$pod\"})",
                      "hide": false,
                      "interval": "",
                      "legendFormat": "usage",
                      "queryType": "randomWalk",
                      "refId": "C"
                    }
                  ],
                  "title": "Memory Pod",
                  "type": "timeseries"
                },
                {
                  "datasource": {
                    "type": "prometheus",
                    "uid": "prometheus"
                  },
                  "fieldConfig": {
                    "defaults": {
                      "color": {
                        "mode": "palette-classic"
                      },
                      "custom": {
                        "axisBorderShow": false,
                        "axisCenteredZero": false,
                        "axisColorMode": "text",
                        "axisLabel": "",
                        "axisPlacement": "auto",
                        "barAlignment": 0,
                        "drawStyle": "line",
                        "fillOpacity": 0,
                        "gradientMode": "none",
                        "hideFrom": {
                          "legend": false,
                          "tooltip": false,
                          "viz": false
                        },
                        "insertNulls": false,
                        "lineInterpolation": "linear",
                        "lineWidth": 1,
                        "pointSize": 5,
                        "scaleDistribution": {
                          "type": "linear"
                        },
                        "showPoints": "auto",
                        "spanNulls": false,
                        "stacking": {
                          "group": "A",
                          "mode": "none"
                        },
                        "thresholdsStyle": {
                          "mode": "off"
                        }
                      },
                      "mappings": [],
                      "thresholds": {
                        "mode": "absolute",
                        "steps": [
                          {
                            "color": "green",
                            "value": null
                          },
                          {
                            "color": "red",
                            "value": 80
                          }
                        ]
                      },
                      "unit": "percent"
                    },
                    "overrides": []
                  },
                  "gridPos": {
                    "h": 8,
                    "w": 12,
                    "x": 0,
                    "y": 25
                  },
                  "id": 12,
                  "options": {
                    "legend": {
                      "calcs": [],
                      "displayMode": "list",
                      "placement": "bottom",
                      "showLegend": true
                    },
                    "tooltip": {
                      "mode": "single",
                      "sort": "none"
                    }
                  },
                  "targets": [
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "editorMode": "code",
                      "exemplar": true,
                      "expr": "100*sum by (pod, namespace)(increase(container_cpu_cfs_throttled_periods_total{namespace=\"$namespace\",pod=\"$pod\",container=\"$container\"}[5m]))/\nsum by (pod, namespace)(increase(container_cpu_cfs_periods_total{namespace=\"$namespace\",pod=\"$pod\", container=\"$container\"}[5m]))",
                      "interval": "",
                      "legendFormat": "{{ pod }} {{ container }}",
                      "range": true,
                      "refId": "A"
                    }
                  ],
                  "title": "Throttling containers",
                  "type": "timeseries"
                },
                {
                  "datasource": {
                    "type": "prometheus",
                    "uid": "prometheus"
                  },
                  "fieldConfig": {
                    "defaults": {
                      "color": {
                        "mode": "palette-classic"
                      },
                      "custom": {
                        "axisBorderShow": false,
                        "axisCenteredZero": false,
                        "axisColorMode": "text",
                        "axisLabel": "",
                        "axisPlacement": "auto",
                        "barAlignment": 0,
                        "drawStyle": "line",
                        "fillOpacity": 25,
                        "gradientMode": "opacity",
                        "hideFrom": {
                          "legend": false,
                          "tooltip": false,
                          "viz": false
                        },
                        "insertNulls": false,
                        "lineInterpolation": "smooth",
                        "lineWidth": 2,
                        "pointSize": 5,
                        "scaleDistribution": {
                          "type": "linear"
                        },
                        "showPoints": "never",
                        "spanNulls": true,
                        "stacking": {
                          "group": "A",
                          "mode": "none"
                        },
                        "thresholdsStyle": {
                          "mode": "off"
                        }
                      },
                      "mappings": [],
                      "thresholds": {
                        "mode": "absolute",
                        "steps": [
                          {
                            "color": "green",
                            "value": null
                          },
                          {
                            "color": "red",
                            "value": 80
                          }
                        ]
                      },
                      "unit": "short"
                    },
                    "overrides": []
                  },
                  "gridPos": {
                    "h": 8,
                    "w": 12,
                    "x": 12,
                    "y": 25
                  },
                  "id": 22,
                  "options": {
                    "legend": {
                      "calcs": [
                        "min",
                        "max",
                        "mean"
                      ],
                      "displayMode": "table",
                      "placement": "right",
                      "showLegend": true,
                      "sortBy": "Max",
                      "sortDesc": true
                    },
                    "tooltip": {
                      "mode": "multi",
                      "sort": "desc"
                    }
                  },
                  "pluginVersion": "8.3.3",
                  "targets": [
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "exemplar": true,
                      "expr": "sum(kube_pod_container_status_running{namespace=\"$namespace\"})",
                      "interval": "",
                      "legendFormat": "Running Pods",
                      "refId": "A"
                    },
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "exemplar": true,
                      "expr": "sum(kube_service_info{namespace=\"$namespace\"})",
                      "interval": "",
                      "legendFormat": "Services",
                      "refId": "B"
                    },
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "exemplar": true,
                      "expr": "sum(kube_ingress_info{namespace=\"$namespace\"})",
                      "interval": "",
                      "legendFormat": "Ingresses",
                      "refId": "C"
                    },
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "exemplar": true,
                      "expr": "sum(kube_deployment_labels{namespace=\"$namespace\"})",
                      "interval": "",
                      "legendFormat": "Deployments",
                      "refId": "D"
                    },
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "exemplar": true,
                      "expr": "sum(kube_statefulset_labels{namespace=\"$namespace\"})",
                      "interval": "",
                      "legendFormat": "Statefulsets",
                      "refId": "E"
                    },
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "exemplar": true,
                      "expr": "sum(kube_daemonset_labels{namespace=\"$namespace\"})",
                      "interval": "",
                      "legendFormat": "Daemonsets",
                      "refId": "F"
                    },
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "exemplar": true,
                      "expr": "sum(kube_persistentvolumeclaim_info{namespace=~\"$namespace\"})",
                      "interval": "",
                      "legendFormat": "Persistent Volume Claims",
                      "refId": "G"
                    },
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "exemplar": true,
                      "expr": "sum(kube_hpa_labels{namespace=\"$namespace\"})",
                      "interval": "",
                      "legendFormat": "Horizontal Pod Autoscalers",
                      "refId": "H"
                    },
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "exemplar": true,
                      "expr": "sum(kube_configmap_info{namespace=\"$namespace\"})",
                      "interval": "",
                      "legendFormat": "Configmaps",
                      "refId": "I"
                    },
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "exemplar": true,
                      "expr": "sum(kube_secret_info{namespace=~\"$namespace\"})",
                      "interval": "",
                      "legendFormat": "Secrets",
                      "refId": "J"
                    },
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "exemplar": true,
                      "expr": "sum(kube_networkpolicy_labels{namespace=\"$namespace\"})",
                      "interval": "",
                      "legendFormat": "Network Policies",
                      "refId": "K"
                    },
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "exemplar": true,
                      "expr": "sum(kube_job_labels{namespace=\"$namespace\"})",
                      "hide": false,
                      "interval": "",
                      "legendFormat": "jobs",
                      "refId": "L"
                    },
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "exemplar": true,
                      "expr": "sum(kube_cronjob_labels{namespace=\"$namespace\"})",
                      "hide": false,
                      "interval": "",
                      "legendFormat": "cronjob",
                      "refId": "N"
                    }
                  ],
                  "title": "Resource used on Namespace",
                  "type": "timeseries"
                },
                {
                  "datasource": {
                    "type": "prometheus",
                    "uid": "prometheus"
                  },
                  "fieldConfig": {
                    "defaults": {
                      "color": {
                        "mode": "palette-classic"
                      },
                      "custom": {
                        "axisBorderShow": false,
                        "axisCenteredZero": false,
                        "axisColorMode": "text",
                        "axisLabel": "",
                        "axisPlacement": "auto",
                        "barAlignment": 0,
                        "drawStyle": "line",
                        "fillOpacity": 0,
                        "gradientMode": "none",
                        "hideFrom": {
                          "legend": false,
                          "tooltip": false,
                          "viz": false
                        },
                        "insertNulls": false,
                        "lineInterpolation": "linear",
                        "lineWidth": 1,
                        "pointSize": 5,
                        "scaleDistribution": {
                          "type": "linear"
                        },
                        "showPoints": "auto",
                        "spanNulls": false,
                        "stacking": {
                          "group": "A",
                          "mode": "none"
                        },
                        "thresholdsStyle": {
                          "mode": "off"
                        }
                      },
                      "mappings": [],
                      "thresholds": {
                        "mode": "absolute",
                        "steps": [
                          {
                            "color": "green",
                            "value": null
                          },
                          {
                            "color": "red",
                            "value": 80
                          }
                        ]
                      }
                    },
                    "overrides": []
                  },
                  "gridPos": {
                    "h": 8,
                    "w": 12,
                    "x": 0,
                    "y": 33
                  },
                  "id": 17,
                  "options": {
                    "legend": {
                      "calcs": [],
                      "displayMode": "table",
                      "placement": "right",
                      "showLegend": true
                    },
                    "tooltip": {
                      "mode": "single",
                      "sort": "none"
                    }
                  },
                  "pluginVersion": "8.4.2",
                  "targets": [
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "exemplar": true,
                      "expr": "kube_pod_container_status_restarts_total{namespace=\"$namespace\", pod=~\"$pod\"}",
                      "interval": "",
                      "legendFormat": "{{container}}  {{reason}}",
                      "refId": "A"
                    }
                  ],
                  "title": "container restarts total",
                  "type": "timeseries"
                },
                {
                  "datasource": {
                    "type": "prometheus",
                    "uid": "prometheus"
                  },
                  "fieldConfig": {
                    "defaults": {
                      "color": {
                        "mode": "palette-classic"
                      },
                      "custom": {
                        "axisBorderShow": false,
                        "axisCenteredZero": false,
                        "axisColorMode": "text",
                        "axisLabel": "",
                        "axisPlacement": "auto",
                        "barAlignment": 0,
                        "drawStyle": "line",
                        "fillOpacity": 0,
                        "gradientMode": "none",
                        "hideFrom": {
                          "legend": false,
                          "tooltip": false,
                          "viz": false
                        },
                        "insertNulls": false,
                        "lineInterpolation": "linear",
                        "lineWidth": 1,
                        "pointSize": 5,
                        "scaleDistribution": {
                          "type": "linear"
                        },
                        "showPoints": "auto",
                        "spanNulls": false,
                        "stacking": {
                          "group": "A",
                          "mode": "none"
                        },
                        "thresholdsStyle": {
                          "mode": "off"
                        }
                      },
                      "mappings": [],
                      "thresholds": {
                        "mode": "absolute",
                        "steps": [
                          {
                            "color": "green",
                            "value": null
                          },
                          {
                            "color": "red",
                            "value": 80
                          }
                        ]
                      },
                      "unit": "binbps"
                    },
                    "overrides": []
                  },
                  "gridPos": {
                    "h": 8,
                    "w": 12,
                    "x": 12,
                    "y": 33
                  },
                  "id": 14,
                  "options": {
                    "legend": {
                      "calcs": [],
                      "displayMode": "list",
                      "placement": "bottom",
                      "showLegend": true
                    },
                    "tooltip": {
                      "mode": "single",
                      "sort": "none"
                    }
                  },
                  "targets": [
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "editorMode": "code",
                      "exemplar": true,
                      "expr": "rate(container_network_receive_bytes_total{image!=\"\",namespace=\"$namespace\"}[1m]) * 8",
                      "interval": "",
                      "legendFormat": "receive -> {{ pod }}",
                      "range": true,
                      "refId": "A"
                    },
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "editorMode": "code",
                      "exemplar": true,
                      "expr": "rate(container_network_transmit_bytes_total{image!=\"\",namespace=\"$namespace\"}[1m]) * -8",
                      "hide": false,
                      "interval": "",
                      "legendFormat": "transmit <- {{ pod }}",
                      "range": true,
                      "refId": "B"
                    }
                  ],
                  "title": "Pods network I/O (1m avg)",
                  "type": "timeseries"
                }
              ],
              "refresh": "",
              "schemaVersion": 39,
              "tags": [],
              "templating": {
                "list": [
                  {
                    "datasource": {
                      "type": "prometheus",
                      "uid": "prometheus"
                    },
                    "definition": "label_values(kube_pod_container_info, namespace)",
                    "hide": 0,
                    "includeAll": false,
                    "multi": false,
                    "name": "namespace",
                    "options": [],
                    "query": {
                      "query": "label_values(kube_pod_container_info, namespace)",
                      "refId": "StandardVariableQuery"
                    },
                    "refresh": 2,
                    "regex": "",
                    "skipUrlSync": false,
                    "sort": 1,
                    "type": "query"
                  },
                  {
                    "datasource": {
                      "type": "prometheus",
                      "uid": "prometheus"
                    },
                    "definition": "label_values(kube_pod_container_info{namespace=\"$namespace\"}, pod)",
                    "hide": 0,
                    "includeAll": false,
                    "multi": false,
                    "name": "pod",
                    "options": [],
                    "query": {
                      "query": "label_values(kube_pod_container_info{namespace=\"$namespace\"}, pod)",
                      "refId": "StandardVariableQuery"
                    },
                    "refresh": 2,
                    "regex": "",
                    "skipUrlSync": false,
                    "sort": 1,
                    "type": "query"
                  },
                  {
                    "datasource": {
                      "type": "prometheus",
                      "uid": "prometheus"
                    },
                    "definition": "label_values(kube_pod_container_info{namespace=\"$namespace\", pod=\"$pod\", image!~\".*pause:.*$\"}, container)",
                    "hide": 0,
                    "includeAll": false,
                    "multi": false,
                    "name": "container",
                    "options": [],
                    "query": {
                      "query": "label_values(kube_pod_container_info{namespace=\"$namespace\", pod=\"$pod\", image!~\".*pause:.*$\"}, container)",
                      "refId": "StandardVariableQuery"
                    },
                    "refresh": 2,
                    "regex": "",
                    "skipUrlSync": false,
                    "sort": 1,
                    "type": "query"
                  }
                ]
              },
              "time": {
                "from": "now-1h",
                "to": "now"
              },
              "timepicker": {},
              "timezone": "",
              "title": "Pod Resources",
              "uid": "px1WKJznk",
              "version": 1,
              "weekStart": ""
            }
        kind: ConfigMap
        metadata:
          labels:
            grafana_dashboard: "1"
          name: slurm-pod-resources
          namespace: ${local.monitoring_namespace}
    EOF
  ]
}
