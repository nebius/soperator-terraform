resource "helm_release" "node_exporter" {
    count = var.k8s_monitoring_enabled ? 1 : 0
  depends_on = [
    module.k8s_cluster,
    helm_release.cert_manager,
    helm_release.prometheus,
    helm_release.victoria_metrics_operator,
  ]
  name       = "slurm-node-exporter"
  namespace  = local.monitoring_namespace
  repository = "https://bedag.github.io/helm-charts/"
  chart      = "raw"
  version    = "2.0.0"
  values = [
    <<-EOF
    resources:
      - apiVersion: v1
        data:
          node-exporter.json: |-
            {
              "annotations": {
                "list": [
                  {
                    "$$hashKey": "object:1058",
                    "builtIn": 1,
                    "datasource": "-- Grafana --",
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
              "editable": true,
              "fiscalYearStartMonth": 0,
              "gnetId": 1860,
              "graphTooltip": 0,
              "id": 17,
              "iteration": 1648124791178,
              "links": [
                {
                  "icon": "external link",
                  "tags": [],
                  "title": "GitHub",
                  "type": "link",
                  "url": "https://github.com/rfrail3/grafana-dashboards"
                },
                {
                  "icon": "external link",
                  "tags": [],
                  "title": "Grafana",
                  "type": "link",
                  "url": "https://grafana.com/grafana/dashboards/1860"
                }
              ],
              "liveNow": false,
              "panels": [
                {
                  "collapsed": false,
                  "datasource": {
                    "type": "prometheus",
                    "uid": "prometheus"
                  },
                  "gridPos": {
                    "h": 1,
                    "w": 24,
                    "x": 0,
                    "y": 0
                  },
                  "id": 261,
                  "panels": [],
                  "title": "Quick CPU / Mem / Disk",
                  "type": "row"
                },
                {
                  "datasource": {
                    "type": "prometheus",
                    "uid": "prometheus"
                  },
                  "description": "Busy state of all CPU cores together",
                  "fieldConfig": {
                    "defaults": {
                      "color": {
                        "mode": "thresholds"
                      },
                      "mappings": [
                        {
                          "options": {
                            "match": "null",
                            "result": {
                              "text": "N/A"
                            }
                          },
                          "type": "special"
                        }
                      ],
                      "max": 100,
                      "min": 0,
                      "thresholds": {
                        "mode": "absolute",
                        "steps": [
                          {
                            "color": "rgba(50, 172, 45, 0.97)",
                            "value": null
                          },
                          {
                            "color": "rgba(237, 129, 40, 0.89)",
                            "value": 85
                          },
                          {
                            "color": "rgba(245, 54, 54, 0.9)",
                            "value": 95
                          }
                        ]
                      },
                      "unit": "percent"
                    },
                    "overrides": []
                  },
                  "gridPos": {
                    "h": 4,
                    "w": 3,
                    "x": 0,
                    "y": 1
                  },
                  "id": 20,
                  "links": [],
                  "options": {
                    "orientation": "horizontal",
                    "reduceOptions": {
                      "calcs": [
                        "lastNotNull"
                      ],
                      "fields": "",
                      "values": false
                    },
                    "showThresholdLabels": false,
                    "showThresholdMarkers": true
                  },
                  "pluginVersion": "8.4.2",
                  "targets": [
                    {
                      "expr": "(((count(count(node_cpu_seconds_total{kubernetes_node=\"$node\"}) by (cpu))) - avg(sum by (mode)(rate(node_cpu_seconds_total{mode='idle',kubernetes_node=\"$node\"}[$__rate_interval])))) * 100) / count(count(node_cpu_seconds_total{kubernetes_node=\"$node\"}) by (cpu))",
                      "hide": false,
                      "intervalFactor": 1,
                      "legendFormat": "",
                      "refId": "A",
                      "step": 240
                    }
                  ],
                  "title": "CPU Busy",
                  "type": "gauge"
                },
                {
                  "datasource": {
                    "type": "prometheus",
                    "uid": "prometheus"
                  },
                  "description": "Busy state of all CPU cores together (5 min average)",
                  "fieldConfig": {
                    "defaults": {
                      "color": {
                        "mode": "thresholds"
                      },
                      "mappings": [
                        {
                          "options": {
                            "match": "null",
                            "result": {
                              "text": "N/A"
                            }
                          },
                          "type": "special"
                        }
                      ],
                      "max": 100,
                      "min": 0,
                      "thresholds": {
                        "mode": "absolute",
                        "steps": [
                          {
                            "color": "rgba(50, 172, 45, 0.97)",
                            "value": null
                          },
                          {
                            "color": "rgba(237, 129, 40, 0.89)",
                            "value": 85
                          },
                          {
                            "color": "rgba(245, 54, 54, 0.9)",
                            "value": 95
                          }
                        ]
                      },
                      "unit": "percent"
                    },
                    "overrides": []
                  },
                  "gridPos": {
                    "h": 4,
                    "w": 3,
                    "x": 3,
                    "y": 1
                  },
                  "id": 155,
                  "links": [],
                  "options": {
                    "orientation": "horizontal",
                    "reduceOptions": {
                      "calcs": [
                        "lastNotNull"
                      ],
                      "fields": "",
                      "values": false
                    },
                    "showThresholdLabels": false,
                    "showThresholdMarkers": true
                  },
                  "pluginVersion": "8.4.2",
                  "targets": [
                    {
                      "expr": "avg(node_load5{kubernetes_node=\"$node\"}) /  count(count(node_cpu_seconds_total{kubernetes_node=\"$node\"}) by (cpu)) * 100",
                      "format": "time_series",
                      "hide": false,
                      "intervalFactor": 1,
                      "refId": "A",
                      "step": 240
                    }
                  ],
                  "title": "Sys Load (5m avg)",
                  "type": "gauge"
                },
                {
                  "datasource": {
                    "type": "prometheus",
                    "uid": "prometheus"
                  },
                  "description": "Busy state of all CPU cores together (15 min average)",
                  "fieldConfig": {
                    "defaults": {
                      "color": {
                        "mode": "thresholds"
                      },
                      "mappings": [
                        {
                          "options": {
                            "match": "null",
                            "result": {
                              "text": "N/A"
                            }
                          },
                          "type": "special"
                        }
                      ],
                      "max": 100,
                      "min": 0,
                      "thresholds": {
                        "mode": "absolute",
                        "steps": [
                          {
                            "color": "rgba(50, 172, 45, 0.97)",
                            "value": null
                          },
                          {
                            "color": "rgba(237, 129, 40, 0.89)",
                            "value": 85
                          },
                          {
                            "color": "rgba(245, 54, 54, 0.9)",
                            "value": 95
                          }
                        ]
                      },
                      "unit": "percent"
                    },
                    "overrides": []
                  },
                  "gridPos": {
                    "h": 4,
                    "w": 3,
                    "x": 6,
                    "y": 1
                  },
                  "id": 19,
                  "links": [],
                  "options": {
                    "orientation": "horizontal",
                    "reduceOptions": {
                      "calcs": [
                        "lastNotNull"
                      ],
                      "fields": "",
                      "values": false
                    },
                    "showThresholdLabels": false,
                    "showThresholdMarkers": true
                  },
                  "pluginVersion": "8.4.2",
                  "targets": [
                    {
                      "expr": "avg(node_load15{kubernetes_node=\"$node\"}) /  count(count(node_cpu_seconds_total{kubernetes_node=\"$node\"}) by (cpu)) * 100",
                      "hide": false,
                      "intervalFactor": 1,
                      "refId": "A",
                      "step": 240
                    }
                  ],
                  "title": "Sys Load (15m avg)",
                  "type": "gauge"
                },
                {
                  "datasource": {
                    "type": "prometheus",
                    "uid": "prometheus"
                  },
                  "description": "Non available RAM memory",
                  "fieldConfig": {
                    "defaults": {
                      "color": {
                        "mode": "thresholds"
                      },
                      "decimals": 0,
                      "mappings": [],
                      "max": 100,
                      "min": 0,
                      "thresholds": {
                        "mode": "absolute",
                        "steps": [
                          {
                            "color": "rgba(50, 172, 45, 0.97)",
                            "value": null
                          },
                          {
                            "color": "rgba(237, 129, 40, 0.89)",
                            "value": 80
                          },
                          {
                            "color": "rgba(245, 54, 54, 0.9)",
                            "value": 90
                          }
                        ]
                      },
                      "unit": "percent"
                    },
                    "overrides": []
                  },
                  "gridPos": {
                    "h": 4,
                    "w": 3,
                    "x": 9,
                    "y": 1
                  },
                  "hideTimeOverride": false,
                  "id": 16,
                  "links": [],
                  "options": {
                    "orientation": "horizontal",
                    "reduceOptions": {
                      "calcs": [
                        "lastNotNull"
                      ],
                      "fields": "",
                      "values": false
                    },
                    "showThresholdLabels": false,
                    "showThresholdMarkers": true
                  },
                  "pluginVersion": "8.4.2",
                  "targets": [
                    {
                      "expr": "((node_memory_MemTotal_bytes{kubernetes_node=\"$node\"} - node_memory_MemFree_bytes{kubernetes_node=\"$node\"}) / (node_memory_MemTotal_bytes{kubernetes_node=\"$node\"} )) * 100",
                      "format": "time_series",
                      "hide": true,
                      "intervalFactor": 1,
                      "refId": "A",
                      "step": 240
                    },
                    {
                      "expr": "100 - ((node_memory_MemAvailable_bytes{kubernetes_node=\"$node\"} * 100) / node_memory_MemTotal_bytes{kubernetes_node=\"$node\"})",
                      "format": "time_series",
                      "hide": false,
                      "intervalFactor": 1,
                      "refId": "B",
                      "step": 240
                    }
                  ],
                  "title": "RAM Used",
                  "type": "gauge"
                },
                {
                  "datasource": {
                    "type": "prometheus",
                    "uid": "prometheus"
                  },
                  "description": "Used Swap",
                  "fieldConfig": {
                    "defaults": {
                      "color": {
                        "mode": "thresholds"
                      },
                      "mappings": [
                        {
                          "options": {
                            "match": "null",
                            "result": {
                              "text": "N/A"
                            }
                          },
                          "type": "special"
                        }
                      ],
                      "max": 100,
                      "min": 0,
                      "thresholds": {
                        "mode": "absolute",
                        "steps": [
                          {
                            "color": "rgba(50, 172, 45, 0.97)",
                            "value": null
                          },
                          {
                            "color": "rgba(237, 129, 40, 0.89)",
                            "value": 10
                          },
                          {
                            "color": "rgba(245, 54, 54, 0.9)",
                            "value": 25
                          }
                        ]
                      },
                      "unit": "percent"
                    },
                    "overrides": []
                  },
                  "gridPos": {
                    "h": 4,
                    "w": 3,
                    "x": 12,
                    "y": 1
                  },
                  "id": 21,
                  "links": [],
                  "options": {
                    "orientation": "horizontal",
                    "reduceOptions": {
                      "calcs": [
                        "lastNotNull"
                      ],
                      "fields": "",
                      "values": false
                    },
                    "showThresholdLabels": false,
                    "showThresholdMarkers": true
                  },
                  "pluginVersion": "8.4.2",
                  "targets": [
                    {
                      "expr": "((node_memory_SwapTotal_bytes{kubernetes_node=\"$node\"} - node_memory_SwapFree_bytes{kubernetes_node=\"$node\"}) / (node_memory_SwapTotal_bytes{kubernetes_node=\"$node\"} )) * 100",
                      "intervalFactor": 1,
                      "refId": "A",
                      "step": 240
                    }
                  ],
                  "title": "SWAP Used",
                  "type": "gauge"
                },
                {
                  "datasource": {
                    "type": "prometheus",
                    "uid": "prometheus"
                  },
                  "description": "Used Root FS",
                  "fieldConfig": {
                    "defaults": {
                      "color": {
                        "mode": "thresholds"
                      },
                      "mappings": [
                        {
                          "options": {
                            "match": "null",
                            "result": {
                              "text": "N/A"
                            }
                          },
                          "type": "special"
                        }
                      ],
                      "max": 100,
                      "min": 0,
                      "thresholds": {
                        "mode": "absolute",
                        "steps": [
                          {
                            "color": "rgba(50, 172, 45, 0.97)",
                            "value": null
                          },
                          {
                            "color": "rgba(237, 129, 40, 0.89)",
                            "value": 80
                          },
                          {
                            "color": "rgba(245, 54, 54, 0.9)",
                            "value": 90
                          }
                        ]
                      },
                      "unit": "percent"
                    },
                    "overrides": []
                  },
                  "gridPos": {
                    "h": 4,
                    "w": 3,
                    "x": 15,
                    "y": 1
                  },
                  "id": 154,
                  "links": [],
                  "options": {
                    "orientation": "horizontal",
                    "reduceOptions": {
                      "calcs": [
                        "lastNotNull"
                      ],
                      "fields": "",
                      "values": false
                    },
                    "showThresholdLabels": false,
                    "showThresholdMarkers": true
                  },
                  "pluginVersion": "8.4.2",
                  "targets": [
                    {
                      "expr": "100 - ((node_filesystem_avail_bytes{kubernetes_node=\"$node\",mountpoint=\"/\",fstype!=\"rootfs\"} * 100) / node_filesystem_size_bytes{kubernetes_node=\"$node\",mountpoint=\"/\",fstype!=\"rootfs\"})",
                      "format": "time_series",
                      "intervalFactor": 1,
                      "refId": "A",
                      "step": 240
                    }
                  ],
                  "title": "Root FS Used",
                  "type": "gauge"
                },
                {
                  "datasource": {
                    "type": "prometheus",
                    "uid": "prometheus"
                  },
                  "description": "Total number of CPU cores",
                  "fieldConfig": {
                    "defaults": {
                      "color": {
                        "mode": "thresholds"
                      },
                      "mappings": [
                        {
                          "options": {
                            "match": "null",
                            "result": {
                              "text": "N/A"
                            }
                          },
                          "type": "special"
                        }
                      ],
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
                    "h": 2,
                    "w": 2,
                    "x": 18,
                    "y": 1
                  },
                  "id": 14,
                  "links": [],
                  "maxDataPoints": 100,
                  "options": {
                    "colorMode": "none",
                    "graphMode": "none",
                    "justifyMode": "auto",
                    "orientation": "horizontal",
                    "reduceOptions": {
                      "calcs": [
                        "lastNotNull"
                      ],
                      "fields": "",
                      "values": false
                    },
                    "textMode": "auto"
                  },
                  "pluginVersion": "8.4.2",
                  "targets": [
                    {
                      "expr": "count(count(node_cpu_seconds_total{kubernetes_node=\"$node\"}) by (cpu))",
                      "interval": "",
                      "intervalFactor": 1,
                      "legendFormat": "",
                      "refId": "A",
                      "step": 240
                    }
                  ],
                  "title": "CPU Cores",
                  "type": "stat"
                },
                {
                  "datasource": {
                    "type": "prometheus",
                    "uid": "prometheus"
                  },
                  "description": "System uptime",
                  "fieldConfig": {
                    "defaults": {
                      "color": {
                        "mode": "thresholds"
                      },
                      "decimals": 1,
                      "mappings": [
                        {
                          "options": {
                            "match": "null",
                            "result": {
                              "text": "N/A"
                            }
                          },
                          "type": "special"
                        }
                      ],
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
                      "unit": "s"
                    },
                    "overrides": []
                  },
                  "gridPos": {
                    "h": 2,
                    "w": 4,
                    "x": 20,
                    "y": 1
                  },
                  "hideTimeOverride": true,
                  "id": 15,
                  "links": [],
                  "maxDataPoints": 100,
                  "options": {
                    "colorMode": "none",
                    "graphMode": "none",
                    "justifyMode": "auto",
                    "orientation": "horizontal",
                    "reduceOptions": {
                      "calcs": [
                        "lastNotNull"
                      ],
                      "fields": "",
                      "values": false
                    },
                    "textMode": "auto"
                  },
                  "pluginVersion": "8.4.2",
                  "targets": [
                    {
                      "expr": "node_time_seconds{kubernetes_node=\"$node\"} - node_boot_time_seconds{kubernetes_node=\"$node\"}",
                      "intervalFactor": 1,
                      "refId": "A",
                      "step": 240
                    }
                  ],
                  "title": "Uptime",
                  "type": "stat"
                },
                {
                  "datasource": {
                    "type": "prometheus",
                    "uid": "prometheus"
                  },
                  "description": "Total RootFS",
                  "fieldConfig": {
                    "defaults": {
                      "color": {
                        "mode": "thresholds"
                      },
                      "decimals": 0,
                      "mappings": [
                        {
                          "options": {
                            "match": "null",
                            "result": {
                              "text": "N/A"
                            }
                          },
                          "type": "special"
                        }
                      ],
                      "thresholds": {
                        "mode": "absolute",
                        "steps": [
                          {
                            "color": "rgba(50, 172, 45, 0.97)",
                            "value": null
                          },
                          {
                            "color": "rgba(237, 129, 40, 0.89)",
                            "value": 70
                          },
                          {
                            "color": "rgba(245, 54, 54, 0.9)",
                            "value": 90
                          }
                        ]
                      },
                      "unit": "bytes"
                    },
                    "overrides": []
                  },
                  "gridPos": {
                    "h": 2,
                    "w": 2,
                    "x": 18,
                    "y": 3
                  },
                  "id": 23,
                  "links": [],
                  "maxDataPoints": 100,
                  "options": {
                    "colorMode": "none",
                    "graphMode": "none",
                    "justifyMode": "auto",
                    "orientation": "horizontal",
                    "reduceOptions": {
                      "calcs": [
                        "lastNotNull"
                      ],
                      "fields": "",
                      "values": false
                    },
                    "textMode": "auto"
                  },
                  "pluginVersion": "8.4.2",
                  "targets": [
                    {
                      "expr": "node_filesystem_size_bytes{kubernetes_node=\"$node\",mountpoint=\"/\",fstype!=\"rootfs\"}",
                      "format": "time_series",
                      "hide": false,
                      "intervalFactor": 1,
                      "refId": "A",
                      "step": 240
                    }
                  ],
                  "title": "RootFS Total",
                  "type": "stat"
                },
                {
                  "datasource": {
                    "type": "prometheus",
                    "uid": "prometheus"
                  },
                  "description": "Total RAM",
                  "fieldConfig": {
                    "defaults": {
                      "color": {
                        "mode": "thresholds"
                      },
                      "decimals": 0,
                      "mappings": [
                        {
                          "options": {
                            "match": "null",
                            "result": {
                              "text": "N/A"
                            }
                          },
                          "type": "special"
                        }
                      ],
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
                    "h": 2,
                    "w": 2,
                    "x": 20,
                    "y": 3
                  },
                  "id": 75,
                  "links": [],
                  "maxDataPoints": 100,
                  "options": {
                    "colorMode": "none",
                    "graphMode": "none",
                    "justifyMode": "auto",
                    "orientation": "horizontal",
                    "reduceOptions": {
                      "calcs": [
                        "lastNotNull"
                      ],
                      "fields": "",
                      "values": false
                    },
                    "textMode": "auto"
                  },
                  "pluginVersion": "8.4.2",
                  "targets": [
                    {
                      "expr": "node_memory_MemTotal_bytes{kubernetes_node=\"$node\"}",
                      "intervalFactor": 1,
                      "refId": "A",
                      "step": 240
                    }
                  ],
                  "title": "RAM Total",
                  "type": "stat"
                },
                {
                  "datasource": {
                    "type": "prometheus",
                    "uid": "prometheus"
                  },
                  "description": "Total SWAP",
                  "fieldConfig": {
                    "defaults": {
                      "color": {
                        "mode": "thresholds"
                      },
                      "decimals": 0,
                      "mappings": [
                        {
                          "options": {
                            "match": "null",
                            "result": {
                              "text": "N/A"
                            }
                          },
                          "type": "special"
                        }
                      ],
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
                    "h": 2,
                    "w": 2,
                    "x": 22,
                    "y": 3
                  },
                  "id": 18,
                  "links": [],
                  "maxDataPoints": 100,
                  "options": {
                    "colorMode": "none",
                    "graphMode": "none",
                    "justifyMode": "auto",
                    "orientation": "horizontal",
                    "reduceOptions": {
                      "calcs": [
                        "lastNotNull"
                      ],
                      "fields": "",
                      "values": false
                    },
                    "textMode": "auto"
                  },
                  "pluginVersion": "8.4.2",
                  "targets": [
                    {
                      "expr": "node_memory_SwapTotal_bytes{kubernetes_node=\"$node\"}",
                      "intervalFactor": 1,
                      "refId": "A",
                      "step": 240
                    }
                  ],
                  "title": "SWAP Total",
                  "type": "stat"
                },
                {
                  "collapsed": false,
                  "datasource": {
                    "type": "prometheus",
                    "uid": "prometheus"
                  },
                  "gridPos": {
                    "h": 1,
                    "w": 24,
                    "x": 0,
                    "y": 5
                  },
                  "id": 263,
                  "panels": [],
                  "title": "Basic CPU / Mem / Net / Disk",
                  "type": "row"
                },
                {
                  "aliasColors": {
                    "Busy": "#EAB839",
                    "Busy Iowait": "#890F02",
                    "Busy other": "#1F78C1",
                    "Idle": "#052B51",
                    "Idle - Waiting for something to happen": "#052B51",
                    "guest": "#9AC48A",
                    "idle": "#052B51",
                    "iowait": "#EAB839",
                    "irq": "#BF1B00",
                    "nice": "#C15C17",
                    "softirq": "#E24D42",
                    "steal": "#FCE2DE",
                    "system": "#508642",
                    "user": "#5195CE"
                  },
                  "bars": false,
                  "dashLength": 10,
                  "dashes": false,
                  "datasource": {
                    "type": "prometheus",
                    "uid": "prometheus"
                  },
                  "decimals": 2,
                  "description": "Basic CPU info",
                  "fieldConfig": {
                    "defaults": {
                      "links": []
                    },
                    "overrides": []
                  },
                  "fill": 4,
                  "fillGradient": 0,
                  "gridPos": {
                    "h": 7,
                    "w": 12,
                    "x": 0,
                    "y": 6
                  },
                  "hiddenSeries": false,
                  "id": 77,
                  "legend": {
                    "alignAsTable": false,
                    "avg": false,
                    "current": false,
                    "max": false,
                    "min": false,
                    "rightSide": false,
                    "show": true,
                    "sideWidth": 250,
                    "total": false,
                    "values": false
                  },
                  "lines": true,
                  "linewidth": 1,
                  "links": [],
                  "maxPerRow": 6,
                  "nullPointMode": "null",
                  "options": {
                    "alertThreshold": true
                  },
                  "percentage": true,
                  "pluginVersion": "8.4.2",
                  "pointradius": 5,
                  "points": false,
                  "renderer": "flot",
                  "seriesOverrides": [
                    {
                      "alias": "Busy Iowait",
                      "color": "#890F02"
                    },
                    {
                      "alias": "Idle",
                      "color": "#7EB26D"
                    },
                    {
                      "alias": "Busy System",
                      "color": "#EAB839"
                    },
                    {
                      "alias": "Busy User",
                      "color": "#0A437C"
                    },
                    {
                      "alias": "Busy Other",
                      "color": "#6D1F62"
                    }
                  ],
                  "spaceLength": 10,
                  "stack": true,
                  "steppedLine": false,
                  "targets": [
                    {
                      "expr": "sum by (instance)(rate(node_cpu_seconds_total{mode=\"system\",kubernetes_node=\"$node\"}[$__rate_interval])) * 100",
                      "format": "time_series",
                      "hide": false,
                      "intervalFactor": 1,
                      "legendFormat": "Busy System",
                      "refId": "A",
                      "step": 240
                    },
                    {
                      "expr": "sum by (instance)(rate(node_cpu_seconds_total{mode='user',kubernetes_node=\"$node\"}[$__rate_interval])) * 100",
                      "format": "time_series",
                      "hide": false,
                      "intervalFactor": 1,
                      "legendFormat": "Busy User",
                      "refId": "B",
                      "step": 240
                    },
                    {
                      "expr": "sum by (instance)(rate(node_cpu_seconds_total{mode='iowait',kubernetes_node=\"$node\"}[$__rate_interval])) * 100",
                      "format": "time_series",
                      "intervalFactor": 1,
                      "legendFormat": "Busy Iowait",
                      "refId": "C",
                      "step": 240
                    },
                    {
                      "expr": "sum by (instance)(rate(node_cpu_seconds_total{mode=~\".*irq\",kubernetes_node=\"$node\"}[$__rate_interval])) * 100",
                      "format": "time_series",
                      "intervalFactor": 1,
                      "legendFormat": "Busy IRQs",
                      "refId": "D",
                      "step": 240
                    },
                    {
                      "expr": "sum (rate(node_cpu_seconds_total{mode!='idle',mode!='user',mode!='system',mode!='iowait',mode!='irq',mode!='softirq',kubernetes_node=\"$node\"}[$__rate_interval])) * 100",
                      "format": "time_series",
                      "intervalFactor": 1,
                      "legendFormat": "Busy Other",
                      "refId": "E",
                      "step": 240
                    },
                    {
                      "expr": "sum by (mode)(rate(node_cpu_seconds_total{mode='idle',kubernetes_node=\"$node\"}[$__rate_interval])) * 100",
                      "format": "time_series",
                      "intervalFactor": 1,
                      "legendFormat": "Idle",
                      "refId": "F",
                      "step": 240
                    }
                  ],
                  "thresholds": [],
                  "timeRegions": [],
                  "title": "CPU Basic",
                  "tooltip": {
                    "shared": true,
                    "sort": 0,
                    "value_type": "individual"
                  },
                  "type": "graph",
                  "xaxis": {
                    "mode": "time",
                    "show": true,
                    "values": []
                  },
                  "yaxes": [
                    {
                      "$$hashKey": "object:123",
                      "format": "short",
                      "label": "",
                      "logBase": 1,
                      "max": "100",
                      "min": "0",
                      "show": true
                    },
                    {
                      "$$hashKey": "object:124",
                      "format": "short",
                      "logBase": 1,
                      "show": false
                    }
                  ],
                  "yaxis": {
                    "align": false
                  }
                },
                {
                  "aliasColors": {
                    "Apps": "#629E51",
                    "Buffers": "#614D93",
                    "Cache": "#6D1F62",
                    "Cached": "#511749",
                    "Committed": "#508642",
                    "Free": "#0A437C",
                    "Hardware Corrupted - Amount of RAM that the kernel identified as corrupted / not working": "#CFFAFF",
                    "Inactive": "#584477",
                    "PageTables": "#0A50A1",
                    "Page_Tables": "#0A50A1",
                    "RAM_Free": "#E0F9D7",
                    "SWAP Used": "#BF1B00",
                    "Slab": "#806EB7",
                    "Slab_Cache": "#E0752D",
                    "Swap": "#BF1B00",
                    "Swap Used": "#BF1B00",
                    "Swap_Cache": "#C15C17",
                    "Swap_Free": "#2F575E",
                    "Unused": "#EAB839"
                  },
                  "bars": false,
                  "dashLength": 10,
                  "dashes": false,
                  "datasource": {
                    "type": "prometheus",
                    "uid": "prometheus"
                  },
                  "decimals": 2,
                  "description": "Basic memory usage",
                  "fieldConfig": {
                    "defaults": {
                      "links": []
                    },
                    "overrides": []
                  },
                  "fill": 4,
                  "fillGradient": 0,
                  "gridPos": {
                    "h": 7,
                    "w": 12,
                    "x": 12,
                    "y": 6
                  },
                  "hiddenSeries": false,
                  "id": 78,
                  "legend": {
                    "alignAsTable": false,
                    "avg": false,
                    "current": false,
                    "max": false,
                    "min": false,
                    "rightSide": false,
                    "show": true,
                    "sideWidth": 350,
                    "total": false,
                    "values": false
                  },
                  "lines": true,
                  "linewidth": 1,
                  "links": [],
                  "maxPerRow": 6,
                  "nullPointMode": "null",
                  "options": {
                    "alertThreshold": true
                  },
                  "percentage": false,
                  "pluginVersion": "8.4.2",
                  "pointradius": 5,
                  "points": false,
                  "renderer": "flot",
                  "seriesOverrides": [
                    {
                      "alias": "RAM Total",
                      "color": "#E0F9D7",
                      "fill": 0,
                      "stack": false
                    },
                    {
                      "alias": "RAM Cache + Buffer",
                      "color": "#052B51"
                    },
                    {
                      "alias": "RAM Free",
                      "color": "#7EB26D"
                    },
                    {
                      "alias": "Avaliable",
                      "color": "#DEDAF7",
                      "fill": 0,
                      "stack": false
                    }
                  ],
                  "spaceLength": 10,
                  "stack": true,
                  "steppedLine": false,
                  "targets": [
                    {
                      "expr": "node_memory_MemTotal_bytes{kubernetes_node=\"$node\"}",
                      "format": "time_series",
                      "hide": false,
                      "intervalFactor": 1,
                      "legendFormat": "RAM Total",
                      "refId": "A",
                      "step": 240
                    },
                    {
                      "expr": "node_memory_MemTotal_bytes{kubernetes_node=\"$node\"} - node_memory_MemFree_bytes{kubernetes_node=\"$node\"} - (node_memory_Cached_bytes{kubernetes_node=\"$node\"} + node_memory_Buffers_bytes{kubernetes_node=\"$node\"})",
                      "format": "time_series",
                      "hide": false,
                      "intervalFactor": 1,
                      "legendFormat": "RAM Used",
                      "refId": "B",
                      "step": 240
                    },
                    {
                      "expr": "node_memory_Cached_bytes{kubernetes_node=\"$node\"} + node_memory_Buffers_bytes{kubernetes_node=\"$node\"}",
                      "format": "time_series",
                      "intervalFactor": 1,
                      "legendFormat": "RAM Cache + Buffer",
                      "refId": "C",
                      "step": 240
                    },
                    {
                      "expr": "node_memory_MemFree_bytes{kubernetes_node=\"$node\"}",
                      "format": "time_series",
                      "intervalFactor": 1,
                      "legendFormat": "RAM Free",
                      "refId": "D",
                      "step": 240
                    },
                    {
                      "expr": "(node_memory_SwapTotal_bytes{kubernetes_node=\"$node\"} - node_memory_SwapFree_bytes{kubernetes_node=\"$node\"})",
                      "format": "time_series",
                      "intervalFactor": 1,
                      "legendFormat": "SWAP Used",
                      "refId": "E",
                      "step": 240
                    }
                  ],
                  "thresholds": [],
                  "timeRegions": [],
                  "title": "Memory Basic",
                  "tooltip": {
                    "shared": true,
                    "sort": 0,
                    "value_type": "individual"
                  },
                  "type": "graph",
                  "xaxis": {
                    "mode": "time",
                    "show": true,
                    "values": []
                  },
                  "yaxes": [
                    {
                      "format": "bytes",
                      "label": "",
                      "logBase": 1,
                      "min": "0",
                      "show": true
                    },
                    {
                      "format": "short",
                      "logBase": 1,
                      "show": false
                    }
                  ],
                  "yaxis": {
                    "align": false
                  }
                },
                {
                  "aliasColors": {
                    "Recv_bytes_eth2": "#7EB26D",
                    "Recv_bytes_lo": "#0A50A1",
                    "Recv_drop_eth2": "#6ED0E0",
                    "Recv_drop_lo": "#E0F9D7",
                    "Recv_errs_eth2": "#BF1B00",
                    "Recv_errs_lo": "#CCA300",
                    "Trans_bytes_eth2": "#7EB26D",
                    "Trans_bytes_lo": "#0A50A1",
                    "Trans_drop_eth2": "#6ED0E0",
                    "Trans_drop_lo": "#E0F9D7",
                    "Trans_errs_eth2": "#BF1B00",
                    "Trans_errs_lo": "#CCA300",
                    "recv_bytes_lo": "#0A50A1",
                    "recv_drop_eth0": "#99440A",
                    "recv_drop_lo": "#967302",
                    "recv_errs_eth0": "#BF1B00",
                    "recv_errs_lo": "#890F02",
                    "trans_bytes_eth0": "#7EB26D",
                    "trans_bytes_lo": "#0A50A1",
                    "trans_drop_eth0": "#99440A",
                    "trans_drop_lo": "#967302",
                    "trans_errs_eth0": "#BF1B00",
                    "trans_errs_lo": "#890F02"
                  },
                  "bars": false,
                  "dashLength": 10,
                  "dashes": false,
                  "datasource": {
                    "type": "prometheus",
                    "uid": "prometheus"
                  },
                  "description": "Basic network info per interface",
                  "fieldConfig": {
                    "defaults": {
                      "links": []
                    },
                    "overrides": []
                  },
                  "fill": 4,
                  "fillGradient": 0,
                  "gridPos": {
                    "h": 7,
                    "w": 12,
                    "x": 0,
                    "y": 13
                  },
                  "hiddenSeries": false,
                  "id": 74,
                  "legend": {
                    "alignAsTable": false,
                    "avg": false,
                    "current": false,
                    "hideEmpty": false,
                    "hideZero": false,
                    "max": false,
                    "min": false,
                    "rightSide": false,
                    "show": true,
                    "sort": "current",
                    "sortDesc": true,
                    "total": false,
                    "values": false
                  },
                  "lines": true,
                  "linewidth": 1,
                  "links": [],
                  "nullPointMode": "null",
                  "options": {
                    "alertThreshold": true
                  },
                  "percentage": false,
                  "pluginVersion": "8.4.2",
                  "pointradius": 5,
                  "points": false,
                  "renderer": "flot",
                  "seriesOverrides": [
                    {
                      "alias": "/.*trans.*/",
                      "transform": "negative-Y"
                    }
                  ],
                  "spaceLength": 10,
                  "stack": false,
                  "steppedLine": false,
                  "targets": [
                    {
                      "expr": "rate(node_network_receive_bytes_total{kubernetes_node=\"$node\"}[$__rate_interval])*8",
                      "format": "time_series",
                      "intervalFactor": 1,
                      "legendFormat": "recv {{device}}",
                      "refId": "A",
                      "step": 240
                    },
                    {
                      "expr": "rate(node_network_transmit_bytes_total{kubernetes_node=\"$node\"}[$__rate_interval])*8",
                      "format": "time_series",
                      "intervalFactor": 1,
                      "legendFormat": "trans {{device}} ",
                      "refId": "B",
                      "step": 240
                    }
                  ],
                  "thresholds": [],
                  "timeRegions": [],
                  "title": "Network Traffic Basic",
                  "tooltip": {
                    "shared": true,
                    "sort": 0,
                    "value_type": "individual"
                  },
                  "type": "graph",
                  "xaxis": {
                    "mode": "time",
                    "show": true,
                    "values": []
                  },
                  "yaxes": [
                    {
                      "format": "bps",
                      "logBase": 1,
                      "show": true
                    },
                    {
                      "format": "pps",
                      "label": "",
                      "logBase": 1,
                      "show": false
                    }
                  ],
                  "yaxis": {
                    "align": false
                  }
                },
                {
                  "aliasColors": {},
                  "bars": false,
                  "dashLength": 10,
                  "dashes": false,
                  "datasource": {
                    "type": "prometheus",
                    "uid": "prometheus"
                  },
                  "decimals": 3,
                  "description": "Disk space used of all filesystems mounted",
                  "fieldConfig": {
                    "defaults": {
                      "links": []
                    },
                    "overrides": []
                  },
                  "fill": 4,
                  "fillGradient": 0,
                  "gridPos": {
                    "h": 7,
                    "w": 12,
                    "x": 12,
                    "y": 13
                  },
                  "height": "",
                  "hiddenSeries": false,
                  "id": 152,
                  "legend": {
                    "alignAsTable": false,
                    "avg": false,
                    "current": false,
                    "max": false,
                    "min": false,
                    "rightSide": false,
                    "show": true,
                    "sort": "current",
                    "sortDesc": false,
                    "total": false,
                    "values": false
                  },
                  "lines": true,
                  "linewidth": 1,
                  "links": [],
                  "maxPerRow": 6,
                  "nullPointMode": "null",
                  "options": {
                    "alertThreshold": true
                  },
                  "percentage": false,
                  "pluginVersion": "8.4.2",
                  "pointradius": 5,
                  "points": false,
                  "renderer": "flot",
                  "seriesOverrides": [],
                  "spaceLength": 10,
                  "stack": false,
                  "steppedLine": false,
                  "targets": [
                    {
                      "expr": "100 - ((node_filesystem_avail_bytes{kubernetes_node=\"$node\",device!~'rootfs'} * 100) / node_filesystem_size_bytes{kubernetes_node=\"$node\",device!~'rootfs'})",
                      "format": "time_series",
                      "intervalFactor": 1,
                      "legendFormat": "{{mountpoint}}",
                      "refId": "A",
                      "step": 240
                    }
                  ],
                  "thresholds": [],
                  "timeRegions": [],
                  "title": "Disk Space Used Basic",
                  "tooltip": {
                    "shared": true,
                    "sort": 0,
                    "value_type": "individual"
                  },
                  "type": "graph",
                  "xaxis": {
                    "mode": "time",
                    "show": true,
                    "values": []
                  },
                  "yaxes": [
                    {
                      "format": "percent",
                      "logBase": 1,
                      "max": "100",
                      "min": "0",
                      "show": true
                    },
                    {
                      "format": "short",
                      "logBase": 1,
                      "show": true
                    }
                  ],
                  "yaxis": {
                    "align": false
                  }
                },
                {
                  "collapsed": true,
                  "datasource": {
                    "type": "prometheus",
                    "uid": "prometheus"
                  },
                  "gridPos": {
                    "h": 1,
                    "w": 24,
                    "x": 0,
                    "y": 20
                  },
                  "id": 265,
                  "panels": [
                    {
                      "aliasColors": {
                        "Idle - Waiting for something to happen": "#052B51",
                        "guest": "#9AC48A",
                        "idle": "#052B51",
                        "iowait": "#EAB839",
                        "irq": "#BF1B00",
                        "nice": "#C15C17",
                        "softirq": "#E24D42",
                        "steal": "#FCE2DE",
                        "system": "#508642",
                        "user": "#5195CE"
                      },
                      "bars": false,
                      "dashLength": 10,
                      "dashes": false,
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "decimals": 2,
                      "description": "",
                      "fieldConfig": {
                        "defaults": {
                          "links": []
                        },
                        "overrides": []
                      },
                      "fill": 4,
                      "fillGradient": 0,
                      "gridPos": {
                        "h": 12,
                        "w": 12,
                        "x": 0,
                        "y": 7
                      },
                      "hiddenSeries": false,
                      "id": 3,
                      "legend": {
                        "alignAsTable": true,
                        "avg": true,
                        "current": true,
                        "max": true,
                        "min": true,
                        "rightSide": false,
                        "show": true,
                        "sideWidth": 250,
                        "total": false,
                        "values": true
                      },
                      "lines": true,
                      "linewidth": 1,
                      "links": [],
                      "maxPerRow": 6,
                      "nullPointMode": "null",
                      "options": {
                        "alertThreshold": true
                      },
                      "percentage": true,
                      "pluginVersion": "8.4.2",
                      "pointradius": 5,
                      "points": false,
                      "renderer": "flot",
                      "seriesOverrides": [],
                      "spaceLength": 10,
                      "stack": true,
                      "steppedLine": false,
                      "targets": [
                        {
                          "expr": "sum by (mode)(rate(node_cpu_seconds_total{mode=\"system\",kubernetes_node=\"$node\"}[$__rate_interval])) * 100",
                          "format": "time_series",
                          "interval": "10s",
                          "intervalFactor": 1,
                          "legendFormat": "System - Processes executing in kernel mode",
                          "refId": "A",
                          "step": 240
                        },
                        {
                          "expr": "sum by (mode)(rate(node_cpu_seconds_total{mode='user',kubernetes_node=\"$node\"}[$__rate_interval])) * 100",
                          "format": "time_series",
                          "intervalFactor": 1,
                          "legendFormat": "User - Normal processes executing in user mode",
                          "refId": "B",
                          "step": 240
                        },
                        {
                          "expr": "sum by (mode)(rate(node_cpu_seconds_total{mode='nice',kubernetes_node=\"$node\"}[$__rate_interval])) * 100",
                          "format": "time_series",
                          "intervalFactor": 1,
                          "legendFormat": "Nice - Niced processes executing in user mode",
                          "refId": "C",
                          "step": 240
                        },
                        {
                          "expr": "sum by (mode)(rate(node_cpu_seconds_total{mode='idle',kubernetes_node=\"$node\"}[$__rate_interval])) * 100",
                          "format": "time_series",
                          "intervalFactor": 1,
                          "legendFormat": "Idle - Waiting for something to happen",
                          "refId": "D",
                          "step": 240
                        },
                        {
                          "expr": "sum by (mode)(rate(node_cpu_seconds_total{mode='iowait',kubernetes_node=\"$node\"}[$__rate_interval])) * 100",
                          "format": "time_series",
                          "intervalFactor": 1,
                          "legendFormat": "Iowait - Waiting for I/O to complete",
                          "refId": "E",
                          "step": 240
                        },
                        {
                          "expr": "sum by (mode)(rate(node_cpu_seconds_total{mode='irq',kubernetes_node=\"$node\"}[$__rate_interval])) * 100",
                          "format": "time_series",
                          "intervalFactor": 1,
                          "legendFormat": "Irq - Servicing interrupts",
                          "refId": "F",
                          "step": 240
                        },
                        {
                          "expr": "sum by (mode)(rate(node_cpu_seconds_total{mode='softirq',kubernetes_node=\"$node\"}[$__rate_interval])) * 100",
                          "format": "time_series",
                          "intervalFactor": 1,
                          "legendFormat": "Softirq - Servicing softirqs",
                          "refId": "G",
                          "step": 240
                        },
                        {
                          "expr": "sum by (mode)(rate(node_cpu_seconds_total{mode='steal',kubernetes_node=\"$node\"}[$__rate_interval])) * 100",
                          "format": "time_series",
                          "intervalFactor": 1,
                          "legendFormat": "Steal - Time spent in other operating systems when running in a virtualized environment",
                          "refId": "H",
                          "step": 240
                        },
                        {
                          "expr": "sum by (mode)(rate(node_cpu_seconds_total{mode='guest',kubernetes_node=\"$node\"}[$__rate_interval])) * 100",
                          "format": "time_series",
                          "intervalFactor": 1,
                          "legendFormat": "Guest - Time spent running a virtual CPU for a guest operating system",
                          "refId": "I",
                          "step": 240
                        }
                      ],
                      "thresholds": [],
                      "timeRegions": [],
                      "title": "CPU",
                      "tooltip": {
                        "shared": true,
                        "sort": 0,
                        "value_type": "individual"
                      },
                      "type": "graph",
                      "xaxis": {
                        "mode": "time",
                        "show": true,
                        "values": []
                      },
                      "yaxes": [
                        {
                          "format": "short",
                          "label": "percentage",
                          "logBase": 1,
                          "max": "100",
                          "min": "0",
                          "show": true
                        },
                        {
                          "format": "short",
                          "logBase": 1,
                          "show": false
                        }
                      ],
                      "yaxis": {
                        "align": false
                      }
                    },
                    {
                      "aliasColors": {
                        "Apps": "#629E51",
                        "Buffers": "#614D93",
                        "Cache": "#6D1F62",
                        "Cached": "#511749",
                        "Committed": "#508642",
                        "Free": "#0A437C",
                        "Hardware Corrupted - Amount of RAM that the kernel identified as corrupted / not working": "#CFFAFF",
                        "Inactive": "#584477",
                        "PageTables": "#0A50A1",
                        "Page_Tables": "#0A50A1",
                        "RAM_Free": "#E0F9D7",
                        "Slab": "#806EB7",
                        "Slab_Cache": "#E0752D",
                        "Swap": "#BF1B00",
                        "Swap - Swap memory usage": "#BF1B00",
                        "Swap_Cache": "#C15C17",
                        "Swap_Free": "#2F575E",
                        "Unused": "#EAB839",
                        "Unused - Free memory unassigned": "#052B51"
                      },
                      "bars": false,
                      "dashLength": 10,
                      "dashes": false,
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "decimals": 2,
                      "description": "",
                      "fieldConfig": {
                        "defaults": {
                          "links": []
                        },
                        "overrides": []
                      },
                      "fill": 4,
                      "fillGradient": 0,
                      "gridPos": {
                        "h": 12,
                        "w": 12,
                        "x": 12,
                        "y": 7
                      },
                      "hiddenSeries": false,
                      "id": 24,
                      "legend": {
                        "alignAsTable": true,
                        "avg": true,
                        "current": true,
                        "max": true,
                        "min": true,
                        "rightSide": false,
                        "show": true,
                        "sideWidth": 350,
                        "total": false,
                        "values": true
                      },
                      "lines": true,
                      "linewidth": 1,
                      "links": [],
                      "maxPerRow": 6,
                      "nullPointMode": "null",
                      "options": {
                        "alertThreshold": true
                      },
                      "percentage": false,
                      "pluginVersion": "8.4.2",
                      "pointradius": 5,
                      "points": false,
                      "renderer": "flot",
                      "seriesOverrides": [
                        {
                          "alias": "/.*Hardware Corrupted - *./",
                          "stack": false
                        }
                      ],
                      "spaceLength": 10,
                      "stack": true,
                      "steppedLine": false,
                      "targets": [
                        {
                          "expr": "node_memory_MemTotal_bytes{kubernetes_node=\"$node\"} - node_memory_MemFree_bytes{kubernetes_node=\"$node\"} - node_memory_Buffers_bytes{kubernetes_node=\"$node\"} - node_memory_Cached_bytes{kubernetes_node=\"$node\"} - node_memory_Slab_bytes{kubernetes_node=\"$node\"} - node_memory_PageTables_bytes{kubernetes_node=\"$node\"} - node_memory_SwapCached_bytes{kubernetes_node=\"$node\"}",
                          "format": "time_series",
                          "hide": false,
                          "intervalFactor": 1,
                          "legendFormat": "Apps - Memory used by user-space applications",
                          "refId": "A",
                          "step": 240
                        },
                        {
                          "expr": "node_memory_PageTables_bytes{kubernetes_node=\"$node\"}",
                          "format": "time_series",
                          "hide": false,
                          "intervalFactor": 1,
                          "legendFormat": "PageTables - Memory used to map between virtual and physical memory addresses",
                          "refId": "B",
                          "step": 240
                        },
                        {
                          "expr": "node_memory_SwapCached_bytes{kubernetes_node=\"$node\"}",
                          "format": "time_series",
                          "intervalFactor": 1,
                          "legendFormat": "SwapCache - Memory that keeps track of pages that have been fetched from swap but not yet been modified",
                          "refId": "C",
                          "step": 240
                        },
                        {
                          "expr": "node_memory_Slab_bytes{kubernetes_node=\"$node\"}",
                          "format": "time_series",
                          "hide": false,
                          "intervalFactor": 1,
                          "legendFormat": "Slab - Memory used by the kernel to cache data structures for its own use (caches like inode, dentry, etc)",
                          "refId": "D",
                          "step": 240
                        },
                        {
                          "expr": "node_memory_Cached_bytes{kubernetes_node=\"$node\"}",
                          "format": "time_series",
                          "hide": false,
                          "intervalFactor": 1,
                          "legendFormat": "Cache - Parked file data (file content) cache",
                          "refId": "E",
                          "step": 240
                        },
                        {
                          "expr": "node_memory_Buffers_bytes{kubernetes_node=\"$node\"}",
                          "format": "time_series",
                          "hide": false,
                          "intervalFactor": 1,
                          "legendFormat": "Buffers - Block device (e.g. harddisk) cache",
                          "refId": "F",
                          "step": 240
                        },
                        {
                          "expr": "node_memory_MemFree_bytes{kubernetes_node=\"$node\"}",
                          "format": "time_series",
                          "hide": false,
                          "intervalFactor": 1,
                          "legendFormat": "Unused - Free memory unassigned",
                          "refId": "G",
                          "step": 240
                        },
                        {
                          "expr": "(node_memory_SwapTotal_bytes{kubernetes_node=\"$node\"} - node_memory_SwapFree_bytes{kubernetes_node=\"$node\"})",
                          "format": "time_series",
                          "hide": false,
                          "intervalFactor": 1,
                          "legendFormat": "Swap - Swap space used",
                          "refId": "H",
                          "step": 240
                        },
                        {
                          "expr": "node_memory_HardwareCorrupted_bytes{kubernetes_node=\"$node\"}",
                          "format": "time_series",
                          "hide": false,
                          "intervalFactor": 1,
                          "legendFormat": "Hardware Corrupted - Amount of RAM that the kernel identified as corrupted / not working",
                          "refId": "I",
                          "step": 240
                        }
                      ],
                      "thresholds": [],
                      "timeRegions": [],
                      "title": "Memory Stack",
                      "tooltip": {
                        "shared": true,
                        "sort": 0,
                        "value_type": "individual"
                      },
                      "type": "graph",
                      "xaxis": {
                        "mode": "time",
                        "show": true,
                        "values": []
                      },
                      "yaxes": [
                        {
                          "format": "bytes",
                          "label": "bytes",
                          "logBase": 1,
                          "min": "0",
                          "show": true
                        },
                        {
                          "format": "short",
                          "logBase": 1,
                          "show": false
                        }
                      ],
                      "yaxis": {
                        "align": false
                      }
                    },
                    {
                      "aliasColors": {
                        "receive_packets_eth0": "#7EB26D",
                        "receive_packets_lo": "#E24D42",
                        "transmit_packets_eth0": "#7EB26D",
                        "transmit_packets_lo": "#E24D42"
                      },
                      "bars": false,
                      "dashLength": 10,
                      "dashes": false,
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "fieldConfig": {
                        "defaults": {
                          "links": []
                        },
                        "overrides": []
                      },
                      "fill": 4,
                      "fillGradient": 0,
                      "gridPos": {
                        "h": 12,
                        "w": 12,
                        "x": 0,
                        "y": 19
                      },
                      "hiddenSeries": false,
                      "id": 84,
                      "legend": {
                        "alignAsTable": true,
                        "avg": true,
                        "current": true,
                        "max": true,
                        "min": true,
                        "rightSide": false,
                        "show": true,
                        "total": false,
                        "values": true
                      },
                      "lines": true,
                      "linewidth": 1,
                      "links": [],
                      "nullPointMode": "null",
                      "options": {
                        "alertThreshold": true
                      },
                      "percentage": false,
                      "pluginVersion": "8.4.2",
                      "pointradius": 5,
                      "points": false,
                      "renderer": "flot",
                      "seriesOverrides": [
                        {
                          "$$hashKey": "object:5871",
                          "alias": "/.*Trans.*/",
                          "transform": "negative-Y"
                        }
                      ],
                      "spaceLength": 10,
                      "stack": false,
                      "steppedLine": false,
                      "targets": [
                        {
                          "expr": "rate(node_network_receive_bytes_total{kubernetes_node=\"$node\"}[$__rate_interval])*8",
                          "format": "time_series",
                          "intervalFactor": 1,
                          "legendFormat": "{{device}} - Receive",
                          "refId": "A",
                          "step": 240
                        },
                        {
                          "expr": "rate(node_network_transmit_bytes_total{kubernetes_node=\"$node\"}[$__rate_interval])*8",
                          "format": "time_series",
                          "intervalFactor": 1,
                          "legendFormat": "{{device}} - Transmit",
                          "refId": "B",
                          "step": 240
                        }
                      ],
                      "thresholds": [],
                      "timeRegions": [],
                      "title": "Network Traffic",
                      "tooltip": {
                        "shared": true,
                        "sort": 0,
                        "value_type": "individual"
                      },
                      "type": "graph",
                      "xaxis": {
                        "mode": "time",
                        "show": true,
                        "values": []
                      },
                      "yaxes": [
                        {
                          "$$hashKey": "object:5884",
                          "format": "bps",
                          "label": "bits out (-) / in (+)",
                          "logBase": 1,
                          "show": true
                        },
                        {
                          "$$hashKey": "object:5885",
                          "format": "short",
                          "logBase": 1,
                          "show": false
                        }
                      ],
                      "yaxis": {
                        "align": false
                      }
                    },
                    {
                      "aliasColors": {},
                      "bars": false,
                      "dashLength": 10,
                      "dashes": false,
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "decimals": 3,
                      "description": "",
                      "fieldConfig": {
                        "defaults": {
                          "links": []
                        },
                        "overrides": []
                      },
                      "fill": 4,
                      "fillGradient": 0,
                      "gridPos": {
                        "h": 12,
                        "w": 12,
                        "x": 12,
                        "y": 19
                      },
                      "height": "",
                      "hiddenSeries": false,
                      "id": 156,
                      "legend": {
                        "alignAsTable": true,
                        "avg": true,
                        "current": true,
                        "max": true,
                        "min": true,
                        "rightSide": false,
                        "show": true,
                        "sort": "current",
                        "sortDesc": false,
                        "total": false,
                        "values": true
                      },
                      "lines": true,
                      "linewidth": 1,
                      "links": [],
                      "maxPerRow": 6,
                      "nullPointMode": "null",
                      "options": {
                        "alertThreshold": true
                      },
                      "percentage": false,
                      "pluginVersion": "8.4.2",
                      "pointradius": 5,
                      "points": false,
                      "renderer": "flot",
                      "seriesOverrides": [],
                      "spaceLength": 10,
                      "stack": false,
                      "steppedLine": false,
                      "targets": [
                        {
                          "expr": "node_filesystem_size_bytes{kubernetes_node=\"$node\",device!~'rootfs'} - node_filesystem_avail_bytes{kubernetes_node=\"$node\",device!~'rootfs'}",
                          "format": "time_series",
                          "intervalFactor": 1,
                          "legendFormat": "{{mountpoint}}",
                          "refId": "A",
                          "step": 240
                        }
                      ],
                      "thresholds": [],
                      "timeRegions": [],
                      "title": "Disk Space Used",
                      "tooltip": {
                        "shared": true,
                        "sort": 0,
                        "value_type": "individual"
                      },
                      "type": "graph",
                      "xaxis": {
                        "mode": "time",
                        "show": true,
                        "values": []
                      },
                      "yaxes": [
                        {
                          "format": "bytes",
                          "label": "bytes",
                          "logBase": 1,
                          "min": "0",
                          "show": true
                        },
                        {
                          "format": "short",
                          "logBase": 1,
                          "show": false
                        }
                      ],
                      "yaxis": {
                        "align": false
                      }
                    },
                    {
                      "aliasColors": {},
                      "bars": false,
                      "dashLength": 10,
                      "dashes": false,
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "description": "",
                      "fieldConfig": {
                        "defaults": {
                          "links": []
                        },
                        "overrides": []
                      },
                      "fill": 2,
                      "fillGradient": 0,
                      "gridPos": {
                        "h": 12,
                        "w": 12,
                        "x": 0,
                        "y": 31
                      },
                      "hiddenSeries": false,
                      "id": 229,
                      "legend": {
                        "alignAsTable": true,
                        "avg": true,
                        "current": true,
                        "hideZero": true,
                        "max": true,
                        "min": true,
                        "rightSide": false,
                        "show": true,
                        "total": false,
                        "values": true
                      },
                      "lines": true,
                      "linewidth": 1,
                      "links": [],
                      "maxPerRow": 6,
                      "nullPointMode": "null",
                      "options": {
                        "alertThreshold": true
                      },
                      "percentage": false,
                      "pluginVersion": "8.4.2",
                      "pointradius": 5,
                      "points": false,
                      "renderer": "flot",
                      "seriesOverrides": [
                        {
                          "alias": "/.*Read.*/",
                          "transform": "negative-Y"
                        },
                        {
                          "alias": "/.*sda_.*/",
                          "color": "#7EB26D"
                        },
                        {
                          "alias": "/.*sdb_.*/",
                          "color": "#EAB839"
                        },
                        {
                          "alias": "/.*sdc_.*/",
                          "color": "#6ED0E0"
                        },
                        {
                          "alias": "/.*sdd_.*/",
                          "color": "#EF843C"
                        },
                        {
                          "alias": "/.*sde_.*/",
                          "color": "#E24D42"
                        },
                        {
                          "alias": "/.*sda1.*/",
                          "color": "#584477"
                        },
                        {
                          "alias": "/.*sda2_.*/",
                          "color": "#BA43A9"
                        },
                        {
                          "alias": "/.*sda3_.*/",
                          "color": "#F4D598"
                        },
                        {
                          "alias": "/.*sdb1.*/",
                          "color": "#0A50A1"
                        },
                        {
                          "alias": "/.*sdb2.*/",
                          "color": "#BF1B00"
                        },
                        {
                          "alias": "/.*sdb2.*/",
                          "color": "#BF1B00"
                        },
                        {
                          "alias": "/.*sdb3.*/",
                          "color": "#E0752D"
                        },
                        {
                          "alias": "/.*sdc1.*/",
                          "color": "#962D82"
                        },
                        {
                          "alias": "/.*sdc2.*/",
                          "color": "#614D93"
                        },
                        {
                          "alias": "/.*sdc3.*/",
                          "color": "#9AC48A"
                        },
                        {
                          "alias": "/.*sdd1.*/",
                          "color": "#65C5DB"
                        },
                        {
                          "alias": "/.*sdd2.*/",
                          "color": "#F9934E"
                        },
                        {
                          "alias": "/.*sdd3.*/",
                          "color": "#EA6460"
                        },
                        {
                          "alias": "/.*sde1.*/",
                          "color": "#E0F9D7"
                        },
                        {
                          "alias": "/.*sdd2.*/",
                          "color": "#FCEACA"
                        },
                        {
                          "alias": "/.*sde3.*/",
                          "color": "#F9E2D2"
                        }
                      ],
                      "spaceLength": 10,
                      "stack": false,
                      "steppedLine": false,
                      "targets": [
                        {
                          "expr": "rate(node_disk_reads_completed_total{kubernetes_node=\"$node\",device=~\"$diskdevices\"}[$__rate_interval])",
                          "intervalFactor": 4,
                          "legendFormat": "{{device}} - Reads completed",
                          "refId": "A",
                          "step": 240
                        },
                        {
                          "expr": "rate(node_disk_writes_completed_total{kubernetes_node=\"$node\",device=~\"$diskdevices\"}[$__rate_interval])",
                          "intervalFactor": 1,
                          "legendFormat": "{{device}} - Writes completed",
                          "refId": "B",
                          "step": 240
                        }
                      ],
                      "thresholds": [],
                      "timeRegions": [],
                      "title": "Disk IOps",
                      "tooltip": {
                        "shared": false,
                        "sort": 0,
                        "value_type": "individual"
                      },
                      "type": "graph",
                      "xaxis": {
                        "mode": "time",
                        "show": true,
                        "values": []
                      },
                      "yaxes": [
                        {
                          "format": "iops",
                          "label": "IO read (-) / write (+)",
                          "logBase": 1,
                          "show": true
                        },
                        {
                          "format": "short",
                          "logBase": 1,
                          "show": false
                        }
                      ],
                      "yaxis": {
                        "align": false
                      }
                    },
                    {
                      "aliasColors": {
                        "io time": "#890F02"
                      },
                      "bars": false,
                      "dashLength": 10,
                      "dashes": false,
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "decimals": 3,
                      "description": "",
                      "fieldConfig": {
                        "defaults": {
                          "links": []
                        },
                        "overrides": []
                      },
                      "fill": 4,
                      "fillGradient": 0,
                      "gridPos": {
                        "h": 12,
                        "w": 12,
                        "x": 12,
                        "y": 31
                      },
                      "hiddenSeries": false,
                      "id": 42,
                      "legend": {
                        "alignAsTable": true,
                        "avg": true,
                        "current": true,
                        "max": true,
                        "min": true,
                        "rightSide": false,
                        "show": true,
                        "total": false,
                        "values": true
                      },
                      "lines": true,
                      "linewidth": 1,
                      "links": [],
                      "maxPerRow": 6,
                      "nullPointMode": "null",
                      "options": {
                        "alertThreshold": true
                      },
                      "percentage": false,
                      "pluginVersion": "8.4.2",
                      "pointradius": 5,
                      "points": false,
                      "renderer": "flot",
                      "seriesOverrides": [
                        {
                          "alias": "/.*read*./",
                          "transform": "negative-Y"
                        },
                        {
                          "alias": "/.*sda.*/",
                          "color": "#7EB26D"
                        },
                        {
                          "alias": "/.*sdb.*/",
                          "color": "#EAB839"
                        },
                        {
                          "alias": "/.*sdc.*/",
                          "color": "#6ED0E0"
                        },
                        {
                          "alias": "/.*sdd.*/",
                          "color": "#EF843C"
                        },
                        {
                          "alias": "/.*sde.*/",
                          "color": "#E24D42"
                        }
                      ],
                      "spaceLength": 10,
                      "stack": false,
                      "steppedLine": false,
                      "targets": [
                        {
                          "expr": "rate(node_disk_read_bytes_total{kubernetes_node=\"$node\",device=~\"$diskdevices\"}[$__rate_interval])",
                          "format": "time_series",
                          "hide": false,
                          "intervalFactor": 1,
                          "legendFormat": "{{device}} - Successfully read bytes",
                          "refId": "A",
                          "step": 240
                        },
                        {
                          "expr": "rate(node_disk_written_bytes_total{kubernetes_node=\"$node\",device=~\"$diskdevices\"}[$__rate_interval])",
                          "format": "time_series",
                          "hide": false,
                          "intervalFactor": 1,
                          "legendFormat": "{{device}} - Successfully written bytes",
                          "refId": "B",
                          "step": 240
                        }
                      ],
                      "thresholds": [],
                      "timeRegions": [],
                      "title": "I/O Usage Read / Write",
                      "tooltip": {
                        "shared": true,
                        "sort": 0,
                        "value_type": "individual"
                      },
                      "type": "graph",
                      "xaxis": {
                        "mode": "time",
                        "show": false,
                        "values": []
                      },
                      "yaxes": [
                        {
                          "$$hashKey": "object:965",
                          "format": "Bps",
                          "label": "bytes read (-) / write (+)",
                          "logBase": 1,
                          "show": true
                        },
                        {
                          "$$hashKey": "object:966",
                          "format": "ms",
                          "label": "",
                          "logBase": 1,
                          "show": true
                        }
                      ],
                      "yaxis": {
                        "align": false
                      }
                    },
                    {
                      "aliasColors": {
                        "io time": "#890F02"
                      },
                      "bars": false,
                      "dashLength": 10,
                      "dashes": false,
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "decimals": 3,
                      "description": "",
                      "fieldConfig": {
                        "defaults": {
                          "links": []
                        },
                        "overrides": []
                      },
                      "fill": 4,
                      "fillGradient": 0,
                      "gridPos": {
                        "h": 12,
                        "w": 12,
                        "x": 0,
                        "y": 43
                      },
                      "hiddenSeries": false,
                      "id": 127,
                      "legend": {
                        "alignAsTable": true,
                        "avg": true,
                        "current": true,
                        "max": true,
                        "min": true,
                        "rightSide": false,
                        "show": true,
                        "total": false,
                        "values": true
                      },
                      "lines": true,
                      "linewidth": 1,
                      "links": [],
                      "maxPerRow": 6,
                      "nullPointMode": "null",
                      "options": {
                        "alertThreshold": true
                      },
                      "percentage": false,
                      "pluginVersion": "8.4.2",
                      "pointradius": 5,
                      "points": false,
                      "renderer": "flot",
                      "seriesOverrides": [],
                      "spaceLength": 10,
                      "stack": false,
                      "steppedLine": false,
                      "targets": [
                        {
                          "expr": "rate(node_disk_io_time_seconds_total{kubernetes_node=\"$node\",device=~\"$diskdevices\"} [$__rate_interval])",
                          "format": "time_series",
                          "hide": false,
                          "interval": "",
                          "intervalFactor": 1,
                          "legendFormat": "{{device}}",
                          "refId": "A",
                          "step": 240
                        }
                      ],
                      "thresholds": [],
                      "timeRegions": [],
                      "title": "I/O Utilization",
                      "tooltip": {
                        "shared": true,
                        "sort": 0,
                        "value_type": "individual"
                      },
                      "type": "graph",
                      "xaxis": {
                        "mode": "time",
                        "show": false,
                        "values": []
                      },
                      "yaxes": [
                        {
                          "$$hashKey": "object:1041",
                          "format": "percentunit",
                          "label": "%util",
                          "logBase": 1,
                          "min": "0",
                          "show": true
                        },
                        {
                          "$$hashKey": "object:1042",
                          "format": "s",
                          "label": "",
                          "logBase": 1,
                          "show": false
                        }
                      ],
                      "yaxis": {
                        "align": false
                      }
                    },
                    {
                      "aliasColors": {
                        "Apps": "#629E51",
                        "Buffers": "#614D93",
                        "Cache": "#6D1F62",
                        "Cached": "#511749",
                        "Committed": "#508642",
                        "Free": "#0A437C",
                        "Hardware Corrupted - Amount of RAM that the kernel identified as corrupted / not working": "#CFFAFF",
                        "Inactive": "#584477",
                        "PageTables": "#0A50A1",
                        "Page_Tables": "#0A50A1",
                        "RAM_Free": "#E0F9D7",
                        "Slab": "#806EB7",
                        "Slab_Cache": "#E0752D",
                        "Swap": "#BF1B00",
                        "Swap_Cache": "#C15C17",
                        "Swap_Free": "#2F575E",
                        "Unused": "#EAB839"
                      },
                      "bars": false,
                      "dashLength": 10,
                      "dashes": false,
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "decimals": 2,
                      "fieldConfig": {
                        "defaults": {
                          "links": []
                        },
                        "overrides": []
                      },
                      "fill": 2,
                      "fillGradient": 0,
                      "gridPos": {
                        "h": 10,
                        "w": 12,
                        "x": 12,
                        "y": 43
                      },
                      "hiddenSeries": false,
                      "id": 135,
                      "legend": {
                        "alignAsTable": true,
                        "avg": true,
                        "current": true,
                        "max": true,
                        "min": true,
                        "rightSide": false,
                        "show": true,
                        "sideWidth": 350,
                        "total": false,
                        "values": true
                      },
                      "lines": true,
                      "linewidth": 1,
                      "links": [],
                      "maxPerRow": 6,
                      "nullPointMode": "null",
                      "options": {
                        "alertThreshold": true
                      },
                      "percentage": false,
                      "pluginVersion": "8.4.2",
                      "pointradius": 5,
                      "points": false,
                      "renderer": "flot",
                      "seriesOverrides": [
                        {
                          "alias": "/.*Committed_AS - *./"
                        },
                        {
                          "alias": "/.*CommitLimit - *./",
                          "color": "#BF1B00",
                          "fill": 0
                        }
                      ],
                      "spaceLength": 10,
                      "stack": false,
                      "steppedLine": false,
                      "targets": [
                        {
                          "expr": "node_memory_Committed_AS_bytes{kubernetes_node=\"$node\"}",
                          "format": "time_series",
                          "intervalFactor": 1,
                          "legendFormat": "Committed_AS - Amount of memory presently allocated on the system",
                          "refId": "A",
                          "step": 240
                        },
                        {
                          "expr": "node_memory_CommitLimit_bytes{kubernetes_node=\"$node\"}",
                          "format": "time_series",
                          "intervalFactor": 1,
                          "legendFormat": "CommitLimit - Amount of  memory currently available to be allocated on the system",
                          "refId": "B",
                          "step": 240
                        }
                      ],
                      "thresholds": [],
                      "timeRegions": [],
                      "title": "Memory Commited",
                      "tooltip": {
                        "shared": true,
                        "sort": 0,
                        "value_type": "cumulative"
                      },
                      "type": "graph",
                      "xaxis": {
                        "mode": "time",
                        "show": true,
                        "values": []
                      },
                      "yaxes": [
                        {
                          "format": "bytes",
                          "label": "bytes",
                          "logBase": 1,
                          "min": "0",
                          "show": true
                        },
                        {
                          "format": "short",
                          "logBase": 1,
                          "show": false
                        }
                      ],
                      "yaxis": {
                        "align": false
                      }
                    },
                    {
                      "aliasColors": {
                        "Active": "#99440A",
                        "Buffers": "#58140C",
                        "Cache": "#6D1F62",
                        "Cached": "#511749",
                        "Committed": "#508642",
                        "Dirty": "#6ED0E0",
                        "Free": "#B7DBAB",
                        "Inactive": "#EA6460",
                        "Mapped": "#052B51",
                        "PageTables": "#0A50A1",
                        "Page_Tables": "#0A50A1",
                        "Slab_Cache": "#EAB839",
                        "Swap": "#BF1B00",
                        "Swap_Cache": "#C15C17",
                        "Total": "#511749",
                        "Total RAM": "#052B51",
                        "Total RAM + Swap": "#052B51",
                        "Total Swap": "#614D93",
                        "VmallocUsed": "#EA6460"
                      },
                      "bars": false,
                      "dashLength": 10,
                      "dashes": false,
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "decimals": 2,
                      "fieldConfig": {
                        "defaults": {
                          "links": []
                        },
                        "overrides": []
                      },
                      "fill": 2,
                      "fillGradient": 0,
                      "gridPos": {
                        "h": 10,
                        "w": 12,
                        "x": 12,
                        "y": 53
                      },
                      "hiddenSeries": false,
                      "id": 130,
                      "legend": {
                        "alignAsTable": true,
                        "avg": true,
                        "current": true,
                        "max": true,
                        "min": true,
                        "rightSide": false,
                        "show": true,
                        "total": false,
                        "values": true
                      },
                      "lines": true,
                      "linewidth": 1,
                      "links": [],
                      "maxPerRow": 2,
                      "nullPointMode": "null",
                      "options": {
                        "alertThreshold": true
                      },
                      "percentage": false,
                      "pluginVersion": "8.4.2",
                      "pointradius": 5,
                      "points": false,
                      "renderer": "flot",
                      "seriesOverrides": [],
                      "spaceLength": 10,
                      "stack": false,
                      "steppedLine": false,
                      "targets": [
                        {
                          "expr": "node_memory_Writeback_bytes{kubernetes_node=\"$node\"}",
                          "format": "time_series",
                          "intervalFactor": 1,
                          "legendFormat": "Writeback - Memory which is actively being written back to disk",
                          "refId": "A",
                          "step": 240
                        },
                        {
                          "expr": "node_memory_WritebackTmp_bytes{kubernetes_node=\"$node\"}",
                          "format": "time_series",
                          "intervalFactor": 1,
                          "legendFormat": "WritebackTmp - Memory used by FUSE for temporary writeback buffers",
                          "refId": "B",
                          "step": 240
                        },
                        {
                          "expr": "node_memory_Dirty_bytes{kubernetes_node=\"$node\"}",
                          "format": "time_series",
                          "intervalFactor": 1,
                          "legendFormat": "Dirty - Memory which is waiting to get written back to the disk",
                          "refId": "C",
                          "step": 240
                        }
                      ],
                      "thresholds": [],
                      "timeRegions": [],
                      "title": "Memory Writeback and Dirty",
                      "tooltip": {
                        "shared": true,
                        "sort": 0,
                        "value_type": "individual"
                      },
                      "type": "graph",
                      "xaxis": {
                        "mode": "time",
                        "show": true,
                        "values": []
                      },
                      "yaxes": [
                        {
                          "format": "bytes",
                          "label": "bytes",
                          "logBase": 1,
                          "min": "0",
                          "show": true
                        },
                        {
                          "format": "short",
                          "logBase": 1,
                          "show": false
                        }
                      ],
                      "yaxis": {
                        "align": false
                      }
                    },
                    {
                      "aliasColors": {
                        "Apps": "#629E51",
                        "Buffers": "#614D93",
                        "Cache": "#6D1F62",
                        "Cached": "#511749",
                        "Committed": "#508642",
                        "Free": "#0A437C",
                        "Hardware Corrupted - Amount of RAM that the kernel identified as corrupted / not working": "#CFFAFF",
                        "Inactive": "#584477",
                        "PageTables": "#0A50A1",
                        "Page_Tables": "#0A50A1",
                        "RAM_Free": "#E0F9D7",
                        "Slab": "#806EB7",
                        "Slab_Cache": "#E0752D",
                        "Swap": "#BF1B00",
                        "Swap_Cache": "#C15C17",
                        "Swap_Free": "#2F575E",
                        "Unused": "#EAB839"
                      },
                      "bars": false,
                      "dashLength": 10,
                      "dashes": false,
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "decimals": 2,
                      "fieldConfig": {
                        "defaults": {
                          "links": []
                        },
                        "overrides": []
                      },
                      "fill": 2,
                      "fillGradient": 0,
                      "gridPos": {
                        "h": 10,
                        "w": 12,
                        "x": 0,
                        "y": 55
                      },
                      "hiddenSeries": false,
                      "id": 136,
                      "legend": {
                        "alignAsTable": true,
                        "avg": true,
                        "current": true,
                        "max": true,
                        "min": true,
                        "rightSide": false,
                        "show": true,
                        "sideWidth": 350,
                        "total": false,
                        "values": true
                      },
                      "lines": true,
                      "linewidth": 1,
                      "links": [],
                      "maxPerRow": 2,
                      "nullPointMode": "null",
                      "options": {
                        "alertThreshold": true
                      },
                      "percentage": false,
                      "pluginVersion": "8.4.2",
                      "pointradius": 5,
                      "points": false,
                      "renderer": "flot",
                      "seriesOverrides": [],
                      "spaceLength": 10,
                      "stack": true,
                      "steppedLine": false,
                      "targets": [
                        {
                          "expr": "node_memory_Inactive_bytes{kubernetes_node=\"$node\"}",
                          "format": "time_series",
                          "intervalFactor": 1,
                          "legendFormat": "Inactive - Memory which has been less recently used.  It is more eligible to be reclaimed for other purposes",
                          "refId": "A",
                          "step": 240
                        },
                        {
                          "expr": "node_memory_Active_bytes{kubernetes_node=\"$node\"}",
                          "format": "time_series",
                          "intervalFactor": 1,
                          "legendFormat": "Active - Memory that has been used more recently and usually not reclaimed unless absolutely necessary",
                          "refId": "B",
                          "step": 240
                        }
                      ],
                      "thresholds": [],
                      "timeRegions": [],
                      "title": "Memory Active / Inactive",
                      "tooltip": {
                        "shared": true,
                        "sort": 0,
                        "value_type": "cumulative"
                      },
                      "type": "graph",
                      "xaxis": {
                        "mode": "time",
                        "show": true,
                        "values": []
                      },
                      "yaxes": [
                        {
                          "format": "bytes",
                          "label": "bytes",
                          "logBase": 1,
                          "min": "0",
                          "show": true
                        },
                        {
                          "format": "short",
                          "logBase": 1,
                          "show": false
                        }
                      ],
                      "yaxis": {
                        "align": false
                      }
                    },
                    {
                      "aliasColors": {
                        "Active": "#99440A",
                        "Buffers": "#58140C",
                        "Cache": "#6D1F62",
                        "Cached": "#511749",
                        "Committed": "#508642",
                        "Dirty": "#6ED0E0",
                        "Free": "#B7DBAB",
                        "Inactive": "#EA6460",
                        "Mapped": "#052B51",
                        "PageTables": "#0A50A1",
                        "Page_Tables": "#0A50A1",
                        "Slab_Cache": "#EAB839",
                        "Swap": "#BF1B00",
                        "Swap_Cache": "#C15C17",
                        "Total": "#511749",
                        "Total RAM": "#052B51",
                        "Total RAM + Swap": "#052B51",
                        "Total Swap": "#614D93",
                        "VmallocUsed": "#EA6460"
                      },
                      "bars": false,
                      "dashLength": 10,
                      "dashes": false,
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "decimals": 2,
                      "fieldConfig": {
                        "defaults": {
                          "links": []
                        },
                        "overrides": []
                      },
                      "fill": 2,
                      "fillGradient": 0,
                      "gridPos": {
                        "h": 10,
                        "w": 12,
                        "x": 12,
                        "y": 63
                      },
                      "hiddenSeries": false,
                      "id": 131,
                      "legend": {
                        "alignAsTable": true,
                        "avg": true,
                        "current": true,
                        "max": true,
                        "min": true,
                        "rightSide": false,
                        "show": true,
                        "total": false,
                        "values": true
                      },
                      "lines": true,
                      "linewidth": 1,
                      "links": [],
                      "maxPerRow": 2,
                      "nullPointMode": "null",
                      "options": {
                        "alertThreshold": true
                      },
                      "percentage": false,
                      "pluginVersion": "8.4.2",
                      "pointradius": 5,
                      "points": false,
                      "renderer": "flot",
                      "seriesOverrides": [],
                      "spaceLength": 10,
                      "stack": true,
                      "steppedLine": false,
                      "targets": [
                        {
                          "expr": "node_memory_SUnreclaim_bytes{kubernetes_node=\"$node\"}",
                          "format": "time_series",
                          "intervalFactor": 1,
                          "legendFormat": "SUnreclaim - Part of Slab, that cannot be reclaimed on memory pressure",
                          "refId": "A",
                          "step": 240
                        },
                        {
                          "expr": "node_memory_SReclaimable_bytes{kubernetes_node=\"$node\"}",
                          "format": "time_series",
                          "intervalFactor": 1,
                          "legendFormat": "SReclaimable - Part of Slab, that might be reclaimed, such as caches",
                          "refId": "B",
                          "step": 240
                        }
                      ],
                      "thresholds": [],
                      "timeRegions": [],
                      "title": "Memory Slab",
                      "tooltip": {
                        "shared": true,
                        "sort": 0,
                        "value_type": "individual"
                      },
                      "type": "graph",
                      "xaxis": {
                        "mode": "time",
                        "show": true,
                        "values": []
                      },
                      "yaxes": [
                        {
                          "format": "bytes",
                          "label": "bytes",
                          "logBase": 1,
                          "min": "0",
                          "show": true
                        },
                        {
                          "format": "short",
                          "logBase": 1,
                          "show": false
                        }
                      ],
                      "yaxis": {
                        "align": false
                      }
                    },
                    {
                      "aliasColors": {
                        "Apps": "#629E51",
                        "Buffers": "#614D93",
                        "Cache": "#6D1F62",
                        "Cached": "#511749",
                        "Committed": "#508642",
                        "Free": "#0A437C",
                        "Hardware Corrupted - Amount of RAM that the kernel identified as corrupted / not working": "#CFFAFF",
                        "Inactive": "#584477",
                        "PageTables": "#0A50A1",
                        "Page_Tables": "#0A50A1",
                        "RAM_Free": "#E0F9D7",
                        "Slab": "#806EB7",
                        "Slab_Cache": "#E0752D",
                        "Swap": "#BF1B00",
                        "Swap_Cache": "#C15C17",
                        "Swap_Free": "#2F575E",
                        "Unused": "#EAB839"
                      },
                      "bars": false,
                      "dashLength": 10,
                      "dashes": false,
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "decimals": 2,
                      "fieldConfig": {
                        "defaults": {
                          "links": []
                        },
                        "overrides": []
                      },
                      "fill": 2,
                      "fillGradient": 0,
                      "gridPos": {
                        "h": 10,
                        "w": 12,
                        "x": 0,
                        "y": 65
                      },
                      "hiddenSeries": false,
                      "id": 191,
                      "legend": {
                        "alignAsTable": true,
                        "avg": true,
                        "current": true,
                        "max": true,
                        "min": true,
                        "rightSide": false,
                        "show": true,
                        "sideWidth": 350,
                        "total": false,
                        "values": true
                      },
                      "lines": true,
                      "linewidth": 1,
                      "links": [],
                      "maxPerRow": 6,
                      "nullPointMode": "null",
                      "options": {
                        "alertThreshold": true
                      },
                      "percentage": false,
                      "pluginVersion": "8.4.2",
                      "pointradius": 5,
                      "points": false,
                      "renderer": "flot",
                      "seriesOverrides": [],
                      "spaceLength": 10,
                      "stack": true,
                      "steppedLine": false,
                      "targets": [
                        {
                          "expr": "node_memory_Inactive_file_bytes{kubernetes_node=\"$node\"}",
                          "format": "time_series",
                          "hide": false,
                          "intervalFactor": 1,
                          "legendFormat": "Inactive_file - File-backed memory on inactive LRU list",
                          "refId": "A",
                          "step": 240
                        },
                        {
                          "expr": "node_memory_Inactive_anon_bytes{kubernetes_node=\"$node\"}",
                          "format": "time_series",
                          "hide": false,
                          "intervalFactor": 1,
                          "legendFormat": "Inactive_anon - Anonymous and swap cache on inactive LRU list, including tmpfs (shmem)",
                          "refId": "B",
                          "step": 240
                        },
                        {
                          "expr": "node_memory_Active_file_bytes{kubernetes_node=\"$node\"}",
                          "format": "time_series",
                          "hide": false,
                          "intervalFactor": 1,
                          "legendFormat": "Active_file - File-backed memory on active LRU list",
                          "refId": "C",
                          "step": 240
                        },
                        {
                          "expr": "node_memory_Active_anon_bytes{kubernetes_node=\"$node\"}",
                          "format": "time_series",
                          "hide": false,
                          "intervalFactor": 1,
                          "legendFormat": "Active_anon - Anonymous and swap cache on active least-recently-used (LRU) list, including tmpfs",
                          "refId": "D",
                          "step": 240
                        }
                      ],
                      "thresholds": [],
                      "timeRegions": [],
                      "title": "Memory Active / Inactive Detail",
                      "tooltip": {
                        "shared": true,
                        "sort": 0,
                        "value_type": "cumulative"
                      },
                      "type": "graph",
                      "xaxis": {
                        "mode": "time",
                        "show": true,
                        "values": []
                      },
                      "yaxes": [
                        {
                          "format": "bytes",
                          "label": "bytes",
                          "logBase": 1,
                          "min": "0",
                          "show": true
                        },
                        {
                          "format": "bytes",
                          "logBase": 1,
                          "show": true
                        }
                      ],
                      "yaxis": {
                        "align": false
                      }
                    },
                    {
                      "aliasColors": {
                        "Apps": "#629E51",
                        "Buffers": "#614D93",
                        "Cache": "#6D1F62",
                        "Cached": "#511749",
                        "Committed": "#508642",
                        "Free": "#0A437C",
                        "Hardware Corrupted - Amount of RAM that the kernel identified as corrupted / not working": "#CFFAFF",
                        "Inactive": "#584477",
                        "PageTables": "#0A50A1",
                        "Page_Tables": "#0A50A1",
                        "RAM_Free": "#E0F9D7",
                        "Slab": "#806EB7",
                        "Slab_Cache": "#E0752D",
                        "Swap": "#BF1B00",
                        "Swap_Cache": "#C15C17",
                        "Swap_Free": "#2F575E",
                        "Unused": "#EAB839"
                      },
                      "bars": false,
                      "dashLength": 10,
                      "dashes": false,
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "decimals": 2,
                      "fieldConfig": {
                        "defaults": {
                          "links": []
                        },
                        "overrides": []
                      },
                      "fill": 2,
                      "fillGradient": 0,
                      "gridPos": {
                        "h": 10,
                        "w": 12,
                        "x": 12,
                        "y": 73
                      },
                      "hiddenSeries": false,
                      "id": 159,
                      "legend": {
                        "alignAsTable": true,
                        "avg": true,
                        "current": true,
                        "max": true,
                        "min": true,
                        "rightSide": false,
                        "show": true,
                        "sideWidth": 350,
                        "total": false,
                        "values": true
                      },
                      "lines": true,
                      "linewidth": 1,
                      "links": [],
                      "maxPerRow": 6,
                      "nullPointMode": "null",
                      "options": {
                        "alertThreshold": true
                      },
                      "percentage": false,
                      "pluginVersion": "8.4.2",
                      "pointradius": 5,
                      "points": false,
                      "renderer": "flot",
                      "seriesOverrides": [],
                      "spaceLength": 10,
                      "stack": false,
                      "steppedLine": false,
                      "targets": [
                        {
                          "expr": "node_memory_Bounce_bytes{kubernetes_node=\"$node\"}",
                          "format": "time_series",
                          "intervalFactor": 1,
                          "legendFormat": "Bounce - Memory used for block device bounce buffers",
                          "refId": "A",
                          "step": 240
                        }
                      ],
                      "thresholds": [],
                      "timeRegions": [],
                      "title": "Memory Bounce",
                      "tooltip": {
                        "shared": true,
                        "sort": 0,
                        "value_type": "cumulative"
                      },
                      "type": "graph",
                      "xaxis": {
                        "mode": "time",
                        "show": true,
                        "values": []
                      },
                      "yaxes": [
                        {
                          "format": "bytes",
                          "label": "bytes",
                          "logBase": 1,
                          "min": "0",
                          "show": true
                        },
                        {
                          "format": "short",
                          "logBase": 1,
                          "show": false
                        }
                      ],
                      "yaxis": {
                        "align": false
                      }
                    },
                    {
                      "aliasColors": {
                        "Apps": "#629E51",
                        "Buffers": "#614D93",
                        "Cache": "#6D1F62",
                        "Cached": "#511749",
                        "Committed": "#508642",
                        "Free": "#0A437C",
                        "Hardware Corrupted - Amount of RAM that the kernel identified as corrupted / not working": "#CFFAFF",
                        "Inactive": "#584477",
                        "PageTables": "#0A50A1",
                        "Page_Tables": "#0A50A1",
                        "RAM_Free": "#E0F9D7",
                        "Slab": "#806EB7",
                        "Slab_Cache": "#E0752D",
                        "Swap": "#BF1B00",
                        "Swap_Cache": "#C15C17",
                        "Swap_Free": "#2F575E",
                        "Unused": "#EAB839"
                      },
                      "bars": false,
                      "dashLength": 10,
                      "dashes": false,
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "decimals": 2,
                      "fieldConfig": {
                        "defaults": {
                          "links": []
                        },
                        "overrides": []
                      },
                      "fill": 2,
                      "fillGradient": 0,
                      "gridPos": {
                        "h": 10,
                        "w": 12,
                        "x": 0,
                        "y": 75
                      },
                      "hiddenSeries": false,
                      "id": 138,
                      "legend": {
                        "alignAsTable": true,
                        "avg": true,
                        "current": true,
                        "max": true,
                        "min": true,
                        "rightSide": false,
                        "show": true,
                        "sideWidth": 350,
                        "total": false,
                        "values": true
                      },
                      "lines": true,
                      "linewidth": 1,
                      "links": [],
                      "maxPerRow": 6,
                      "nullPointMode": "null",
                      "options": {
                        "alertThreshold": true
                      },
                      "percentage": false,
                      "pluginVersion": "8.4.2",
                      "pointradius": 5,
                      "points": false,
                      "renderer": "flot",
                      "seriesOverrides": [
                        {
                          "$$hashKey": "object:4131",
                          "alias": "ShmemHugePages - Memory used by shared memory (shmem) and tmpfs allocated  with huge pages",
                          "fill": 0
                        },
                        {
                          "$$hashKey": "object:4138",
                          "alias": "ShmemHugePages - Memory used by shared memory (shmem) and tmpfs allocated  with huge pages",
                          "fill": 0
                        }
                      ],
                      "spaceLength": 10,
                      "stack": false,
                      "steppedLine": false,
                      "targets": [
                        {
                          "expr": "node_memory_Mapped_bytes{kubernetes_node=\"$node\"}",
                          "format": "time_series",
                          "intervalFactor": 1,
                          "legendFormat": "Mapped - Used memory in mapped pages files which have been mmaped, such as libraries",
                          "refId": "A",
                          "step": 240
                        },
                        {
                          "expr": "node_memory_Shmem_bytes{kubernetes_node=\"$node\"}",
                          "format": "time_series",
                          "intervalFactor": 1,
                          "legendFormat": "Shmem - Used shared memory (shared between several processes, thus including RAM disks)",
                          "refId": "B",
                          "step": 240
                        },
                        {
                          "expr": "node_memory_ShmemHugePages_bytes{kubernetes_node=\"$node\"}",
                          "format": "time_series",
                          "interval": "",
                          "intervalFactor": 1,
                          "legendFormat": "ShmemHugePages - Memory used by shared memory (shmem) and tmpfs allocated  with huge pages",
                          "refId": "C",
                          "step": 240
                        },
                        {
                          "expr": "node_memory_ShmemPmdMapped_bytes{kubernetes_node=\"$node\"}",
                          "format": "time_series",
                          "interval": "",
                          "intervalFactor": 1,
                          "legendFormat": "ShmemPmdMapped - Ammount of shared (shmem/tmpfs) memory backed by huge pages",
                          "refId": "D",
                          "step": 240
                        }
                      ],
                      "thresholds": [],
                      "timeRegions": [],
                      "title": "Memory Shared and Mapped",
                      "tooltip": {
                        "shared": true,
                        "sort": 0,
                        "value_type": "cumulative"
                      },
                      "type": "graph",
                      "xaxis": {
                        "mode": "time",
                        "show": true,
                        "values": []
                      },
                      "yaxes": [
                        {
                          "$$hashKey": "object:4106",
                          "format": "bytes",
                          "label": "bytes",
                          "logBase": 1,
                          "min": "0",
                          "show": true
                        },
                        {
                          "$$hashKey": "object:4107",
                          "format": "short",
                          "logBase": 1,
                          "show": false
                        }
                      ],
                      "yaxis": {
                        "align": false
                      }
                    },
                    {
                      "aliasColors": {
                        "Apps": "#629E51",
                        "Buffers": "#614D93",
                        "Cache": "#6D1F62",
                        "Cached": "#511749",
                        "Committed": "#508642",
                        "Free": "#0A437C",
                        "Hardware Corrupted - Amount of RAM that the kernel identified as corrupted / not working": "#CFFAFF",
                        "Inactive": "#584477",
                        "PageTables": "#0A50A1",
                        "Page_Tables": "#0A50A1",
                        "RAM_Free": "#E0F9D7",
                        "Slab": "#806EB7",
                        "Slab_Cache": "#E0752D",
                        "Swap": "#BF1B00",
                        "Swap_Cache": "#C15C17",
                        "Swap_Free": "#2F575E",
                        "Unused": "#EAB839"
                      },
                      "bars": false,
                      "dashLength": 10,
                      "dashes": false,
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "decimals": 2,
                      "fieldConfig": {
                        "defaults": {
                          "links": []
                        },
                        "overrides": []
                      },
                      "fill": 2,
                      "fillGradient": 0,
                      "gridPos": {
                        "h": 10,
                        "w": 12,
                        "x": 12,
                        "y": 83
                      },
                      "hiddenSeries": false,
                      "id": 160,
                      "legend": {
                        "alignAsTable": true,
                        "avg": true,
                        "current": true,
                        "max": true,
                        "min": true,
                        "rightSide": false,
                        "show": true,
                        "sideWidth": 350,
                        "total": false,
                        "values": true
                      },
                      "lines": true,
                      "linewidth": 1,
                      "links": [],
                      "maxPerRow": 2,
                      "nullPointMode": "null",
                      "percentage": false,
                      "pluginVersion": "8.4.2",
                      "pointradius": 5,
                      "points": false,
                      "renderer": "flot",
                      "seriesOverrides": [],
                      "spaceLength": 10,
                      "stack": false,
                      "steppedLine": false,
                      "targets": [
                        {
                          "expr": "node_memory_KernelStack_bytes{kubernetes_node=\"$node\"}",
                          "format": "time_series",
                          "intervalFactor": 1,
                          "legendFormat": "KernelStack - Kernel memory stack. This is not reclaimable",
                          "refId": "A",
                          "step": 240
                        },
                        {
                          "expr": "node_memory_Percpu_bytes{kubernetes_node=\"$node\"}",
                          "format": "time_series",
                          "interval": "",
                          "intervalFactor": 1,
                          "legendFormat": "PerCPU - Per CPU memory allocated dynamically by loadable modules",
                          "refId": "B",
                          "step": 240
                        }
                      ],
                      "thresholds": [],
                      "timeRegions": [],
                      "title": "Memory Kernel / CPU",
                      "tooltip": {
                        "shared": true,
                        "sort": 0,
                        "value_type": "cumulative"
                      },
                      "type": "graph",
                      "xaxis": {
                        "mode": "time",
                        "show": true,
                        "values": []
                      },
                      "yaxes": [
                        {
                          "format": "bytes",
                          "label": "bytes",
                          "logBase": 1,
                          "min": "0",
                          "show": true
                        },
                        {
                          "format": "short",
                          "logBase": 1,
                          "show": false
                        }
                      ],
                      "yaxis": {
                        "align": false
                      }
                    },
                    {
                      "aliasColors": {
                        "Active": "#99440A",
                        "Buffers": "#58140C",
                        "Cache": "#6D1F62",
                        "Cached": "#511749",
                        "Committed": "#508642",
                        "Dirty": "#6ED0E0",
                        "Free": "#B7DBAB",
                        "Inactive": "#EA6460",
                        "Mapped": "#052B51",
                        "PageTables": "#0A50A1",
                        "Page_Tables": "#0A50A1",
                        "Slab_Cache": "#EAB839",
                        "Swap": "#BF1B00",
                        "Swap_Cache": "#C15C17",
                        "Total": "#511749",
                        "Total RAM": "#052B51",
                        "Total RAM + Swap": "#052B51",
                        "VmallocUsed": "#EA6460"
                      },
                      "bars": false,
                      "dashLength": 10,
                      "dashes": false,
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "decimals": 2,
                      "fieldConfig": {
                        "defaults": {
                          "links": []
                        },
                        "overrides": []
                      },
                      "fill": 2,
                      "fillGradient": 0,
                      "gridPos": {
                        "h": 10,
                        "w": 12,
                        "x": 0,
                        "y": 85
                      },
                      "hiddenSeries": false,
                      "id": 70,
                      "legend": {
                        "alignAsTable": true,
                        "avg": true,
                        "current": true,
                        "max": true,
                        "min": true,
                        "rightSide": false,
                        "show": true,
                        "total": false,
                        "values": true
                      },
                      "lines": true,
                      "linewidth": 1,
                      "links": [],
                      "maxPerRow": 6,
                      "nullPointMode": "null",
                      "options": {
                        "alertThreshold": true
                      },
                      "percentage": false,
                      "pluginVersion": "8.4.2",
                      "pointradius": 5,
                      "points": false,
                      "renderer": "flot",
                      "seriesOverrides": [],
                      "spaceLength": 10,
                      "stack": false,
                      "steppedLine": false,
                      "targets": [
                        {
                          "expr": "node_memory_VmallocChunk_bytes{kubernetes_node=\"$node\"}",
                          "format": "time_series",
                          "hide": false,
                          "intervalFactor": 1,
                          "legendFormat": "VmallocChunk - Largest contigious block of vmalloc area which is free",
                          "refId": "A",
                          "step": 240
                        },
                        {
                          "expr": "node_memory_VmallocTotal_bytes{kubernetes_node=\"$node\"}",
                          "format": "time_series",
                          "hide": false,
                          "intervalFactor": 1,
                          "legendFormat": "VmallocTotal - Total size of vmalloc memory area",
                          "refId": "B",
                          "step": 240
                        },
                        {
                          "expr": "node_memory_VmallocUsed_bytes{kubernetes_node=\"$node\"}",
                          "format": "time_series",
                          "hide": false,
                          "intervalFactor": 1,
                          "legendFormat": "VmallocUsed - Amount of vmalloc area which is used",
                          "refId": "C",
                          "step": 240
                        }
                      ],
                      "thresholds": [],
                      "timeRegions": [],
                      "title": "Memory Vmalloc",
                      "tooltip": {
                        "shared": true,
                        "sort": 0,
                        "value_type": "individual"
                      },
                      "type": "graph",
                      "xaxis": {
                        "mode": "time",
                        "show": true,
                        "values": []
                      },
                      "yaxes": [
                        {
                          "format": "bytes",
                          "label": "bytes",
                          "logBase": 1,
                          "min": "0",
                          "show": true
                        },
                        {
                          "format": "short",
                          "logBase": 1,
                          "show": false
                        }
                      ],
                      "yaxis": {
                        "align": false
                      }
                    },
                    {
                      "aliasColors": {
                        "Active": "#99440A",
                        "Buffers": "#58140C",
                        "Cache": "#6D1F62",
                        "Cached": "#511749",
                        "Committed": "#508642",
                        "Dirty": "#6ED0E0",
                        "Free": "#B7DBAB",
                        "Inactive": "#EA6460",
                        "Mapped": "#052B51",
                        "PageTables": "#0A50A1",
                        "Page_Tables": "#0A50A1",
                        "Slab_Cache": "#EAB839",
                        "Swap": "#BF1B00",
                        "Swap_Cache": "#C15C17",
                        "Total": "#511749",
                        "Total RAM": "#806EB7",
                        "Total RAM + Swap": "#806EB7",
                        "VmallocUsed": "#EA6460"
                      },
                      "bars": false,
                      "dashLength": 10,
                      "dashes": false,
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "decimals": 2,
                      "fieldConfig": {
                        "defaults": {
                          "links": []
                        },
                        "overrides": []
                      },
                      "fill": 2,
                      "fillGradient": 0,
                      "gridPos": {
                        "h": 10,
                        "w": 12,
                        "x": 12,
                        "y": 93
                      },
                      "hiddenSeries": false,
                      "id": 71,
                      "legend": {
                        "alignAsTable": true,
                        "avg": false,
                        "current": true,
                        "max": true,
                        "min": true,
                        "rightSide": false,
                        "show": true,
                        "total": false,
                        "values": true
                      },
                      "lines": true,
                      "linewidth": 1,
                      "links": [],
                      "maxPerRow": 2,
                      "nullPointMode": "null",
                      "percentage": false,
                      "pluginVersion": "8.4.2",
                      "pointradius": 5,
                      "points": false,
                      "renderer": "flot",
                      "seriesOverrides": [],
                      "spaceLength": 10,
                      "stack": false,
                      "steppedLine": false,
                      "targets": [
                        {
                          "expr": "node_memory_HugePages_Total{kubernetes_node=\"$node\"}",
                          "format": "time_series",
                          "intervalFactor": 1,
                          "legendFormat": "HugePages - Total size of the pool of huge pages",
                          "refId": "A",
                          "step": 240
                        },
                        {
                          "expr": "node_memory_Hugepagesize_bytes{kubernetes_node=\"$node\"}",
                          "format": "time_series",
                          "intervalFactor": 1,
                          "legendFormat": "Hugepagesize - Huge Page size",
                          "refId": "B",
                          "step": 240
                        }
                      ],
                      "thresholds": [],
                      "timeRegions": [],
                      "title": "Memory HugePages Size",
                      "tooltip": {
                        "shared": true,
                        "sort": 0,
                        "value_type": "individual"
                      },
                      "type": "graph",
                      "xaxis": {
                        "mode": "time",
                        "show": true,
                        "values": []
                      },
                      "yaxes": [
                        {
                          "format": "bytes",
                          "label": "bytes",
                          "logBase": 1,
                          "min": "0",
                          "show": true
                        },
                        {
                          "format": "short",
                          "label": "",
                          "logBase": 1,
                          "show": false
                        }
                      ],
                      "yaxis": {
                        "align": false
                      }
                    },
                    {
                      "aliasColors": {
                        "Active": "#99440A",
                        "Buffers": "#58140C",
                        "Cache": "#6D1F62",
                        "Cached": "#511749",
                        "Committed": "#508642",
                        "Dirty": "#6ED0E0",
                        "Free": "#B7DBAB",
                        "Inactive": "#EA6460",
                        "Mapped": "#052B51",
                        "PageTables": "#0A50A1",
                        "Page_Tables": "#0A50A1",
                        "Slab_Cache": "#EAB839",
                        "Swap": "#BF1B00",
                        "Swap_Cache": "#C15C17",
                        "Total": "#511749",
                        "Total RAM": "#052B51",
                        "Total RAM + Swap": "#052B51",
                        "VmallocUsed": "#EA6460"
                      },
                      "bars": false,
                      "dashLength": 10,
                      "dashes": false,
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "decimals": 2,
                      "fieldConfig": {
                        "defaults": {
                          "links": []
                        },
                        "overrides": []
                      },
                      "fill": 2,
                      "fillGradient": 0,
                      "gridPos": {
                        "h": 10,
                        "w": 12,
                        "x": 0,
                        "y": 95
                      },
                      "hiddenSeries": false,
                      "id": 129,
                      "legend": {
                        "alignAsTable": true,
                        "avg": true,
                        "current": true,
                        "max": true,
                        "min": true,
                        "rightSide": false,
                        "show": true,
                        "total": false,
                        "values": true
                      },
                      "lines": true,
                      "linewidth": 1,
                      "links": [],
                      "maxPerRow": 6,
                      "nullPointMode": "null",
                      "percentage": false,
                      "pluginVersion": "8.4.2",
                      "pointradius": 5,
                      "points": false,
                      "renderer": "flot",
                      "seriesOverrides": [
                        {
                          "alias": "/.*Inactive *./",
                          "transform": "negative-Y"
                        }
                      ],
                      "spaceLength": 10,
                      "stack": false,
                      "steppedLine": false,
                      "targets": [
                        {
                          "expr": "node_memory_AnonHugePages_bytes{kubernetes_node=\"$node\"}",
                          "format": "time_series",
                          "intervalFactor": 1,
                          "legendFormat": "AnonHugePages - Memory in anonymous huge pages",
                          "refId": "A",
                          "step": 240
                        },
                        {
                          "expr": "node_memory_AnonPages_bytes{kubernetes_node=\"$node\"}",
                          "format": "time_series",
                          "intervalFactor": 1,
                          "legendFormat": "AnonPages - Memory in user pages not backed by files",
                          "refId": "B",
                          "step": 240
                        }
                      ],
                      "thresholds": [],
                      "timeRegions": [],
                      "title": "Memory Anonymous",
                      "tooltip": {
                        "shared": true,
                        "sort": 0,
                        "value_type": "individual"
                      },
                      "type": "graph",
                      "xaxis": {
                        "mode": "time",
                        "show": true,
                        "values": []
                      },
                      "yaxes": [
                        {
                          "format": "bytes",
                          "label": "bytes",
                          "logBase": 1,
                          "min": "0",
                          "show": true
                        },
                        {
                          "format": "short",
                          "logBase": 1,
                          "show": false
                        }
                      ],
                      "yaxis": {
                        "align": false
                      }
                    },
                    {
                      "aliasColors": {
                        "Apps": "#629E51",
                        "Buffers": "#614D93",
                        "Cache": "#6D1F62",
                        "Cached": "#511749",
                        "Committed": "#508642",
                        "Free": "#0A437C",
                        "Hardware Corrupted - Amount of RAM that the kernel identified as corrupted / not working": "#CFFAFF",
                        "Inactive": "#584477",
                        "PageTables": "#0A50A1",
                        "Page_Tables": "#0A50A1",
                        "RAM_Free": "#E0F9D7",
                        "Slab": "#806EB7",
                        "Slab_Cache": "#E0752D",
                        "Swap": "#BF1B00",
                        "Swap_Cache": "#C15C17",
                        "Swap_Free": "#2F575E",
                        "Unused": "#EAB839"
                      },
                      "bars": false,
                      "dashLength": 10,
                      "dashes": false,
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "decimals": 2,
                      "fieldConfig": {
                        "defaults": {
                          "links": []
                        },
                        "overrides": []
                      },
                      "fill": 2,
                      "fillGradient": 0,
                      "gridPos": {
                        "h": 10,
                        "w": 12,
                        "x": 12,
                        "y": 103
                      },
                      "hiddenSeries": false,
                      "id": 137,
                      "legend": {
                        "alignAsTable": true,
                        "avg": true,
                        "current": true,
                        "max": true,
                        "min": true,
                        "rightSide": false,
                        "show": true,
                        "sideWidth": 350,
                        "total": false,
                        "values": true
                      },
                      "lines": true,
                      "linewidth": 1,
                      "links": [],
                      "maxPerRow": 6,
                      "nullPointMode": "null",
                      "percentage": false,
                      "pluginVersion": "8.4.2",
                      "pointradius": 5,
                      "points": false,
                      "renderer": "flot",
                      "seriesOverrides": [],
                      "spaceLength": 10,
                      "stack": false,
                      "steppedLine": false,
                      "targets": [
                        {
                          "expr": "node_memory_Unevictable_bytes{kubernetes_node=\"$node\"}",
                          "format": "time_series",
                          "intervalFactor": 1,
                          "legendFormat": "Unevictable - Amount of unevictable memory that can't be swapped out for a variety of reasons",
                          "refId": "A",
                          "step": 240
                        },
                        {
                          "expr": "node_memory_Mlocked_bytes{kubernetes_node=\"$node\"}",
                          "format": "time_series",
                          "intervalFactor": 1,
                          "legendFormat": "MLocked - Size of pages locked to memory using the mlock() system call",
                          "refId": "B",
                          "step": 240
                        }
                      ],
                      "thresholds": [],
                      "timeRegions": [],
                      "title": "Memory Unevictable and MLocked",
                      "tooltip": {
                        "shared": true,
                        "sort": 0,
                        "value_type": "cumulative"
                      },
                      "type": "graph",
                      "xaxis": {
                        "mode": "time",
                        "show": true,
                        "values": []
                      },
                      "yaxes": [
                        {
                          "format": "bytes",
                          "label": "bytes",
                          "logBase": 1,
                          "min": "0",
                          "show": true
                        },
                        {
                          "format": "short",
                          "logBase": 1,
                          "show": false
                        }
                      ],
                      "yaxis": {
                        "align": false
                      }
                    },
                    {
                      "aliasColors": {
                        "Active": "#99440A",
                        "Buffers": "#58140C",
                        "Cache": "#6D1F62",
                        "Cached": "#511749",
                        "Committed": "#508642",
                        "Dirty": "#6ED0E0",
                        "Free": "#B7DBAB",
                        "Inactive": "#EA6460",
                        "Mapped": "#052B51",
                        "PageTables": "#0A50A1",
                        "Page_Tables": "#0A50A1",
                        "Slab_Cache": "#EAB839",
                        "Swap": "#BF1B00",
                        "Swap_Cache": "#C15C17",
                        "Total": "#511749",
                        "Total RAM": "#806EB7",
                        "Total RAM + Swap": "#806EB7",
                        "VmallocUsed": "#EA6460"
                      },
                      "bars": false,
                      "dashLength": 10,
                      "dashes": false,
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "decimals": 2,
                      "fieldConfig": {
                        "defaults": {
                          "links": []
                        },
                        "overrides": []
                      },
                      "fill": 2,
                      "fillGradient": 0,
                      "gridPos": {
                        "h": 10,
                        "w": 12,
                        "x": 0,
                        "y": 105
                      },
                      "hiddenSeries": false,
                      "id": 140,
                      "legend": {
                        "alignAsTable": true,
                        "avg": false,
                        "current": true,
                        "max": true,
                        "min": true,
                        "rightSide": false,
                        "show": true,
                        "total": false,
                        "values": true
                      },
                      "lines": true,
                      "linewidth": 1,
                      "links": [],
                      "maxPerRow": 6,
                      "nullPointMode": "null",
                      "percentage": false,
                      "pluginVersion": "8.4.2",
                      "pointradius": 5,
                      "points": false,
                      "renderer": "flot",
                      "seriesOverrides": [],
                      "spaceLength": 10,
                      "stack": false,
                      "steppedLine": false,
                      "targets": [
                        {
                          "expr": "node_memory_HugePages_Free{kubernetes_node=\"$node\"}",
                          "format": "time_series",
                          "intervalFactor": 1,
                          "legendFormat": "HugePages_Free - Huge pages in the pool that are not yet allocated",
                          "refId": "A",
                          "step": 240
                        },
                        {
                          "expr": "node_memory_HugePages_Rsvd{kubernetes_node=\"$node\"}",
                          "format": "time_series",
                          "intervalFactor": 1,
                          "legendFormat": "HugePages_Rsvd - Huge pages for which a commitment to allocate from the pool has been made, but no allocation has yet been made",
                          "refId": "B",
                          "step": 240
                        },
                        {
                          "expr": "node_memory_HugePages_Surp{kubernetes_node=\"$node\"}",
                          "format": "time_series",
                          "intervalFactor": 1,
                          "legendFormat": "HugePages_Surp - Huge pages in the pool above the value in /proc/sys/vm/nr_hugepages",
                          "refId": "C",
                          "step": 240
                        }
                      ],
                      "thresholds": [],
                      "timeRegions": [],
                      "title": "Memory HugePages Counter",
                      "tooltip": {
                        "shared": true,
                        "sort": 0,
                        "value_type": "individual"
                      },
                      "type": "graph",
                      "xaxis": {
                        "mode": "time",
                        "show": true,
                        "values": []
                      },
                      "yaxes": [
                        {
                          "format": "short",
                          "label": "pages",
                          "logBase": 1,
                          "min": "0",
                          "show": true
                        },
                        {
                          "format": "short",
                          "label": "",
                          "logBase": 1,
                          "show": false
                        }
                      ],
                      "yaxis": {
                        "align": false
                      }
                    },
                    {
                      "aliasColors": {},
                      "bars": false,
                      "dashLength": 10,
                      "dashes": false,
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "fieldConfig": {
                        "defaults": {
                          "links": []
                        },
                        "overrides": []
                      },
                      "fill": 2,
                      "fillGradient": 0,
                      "gridPos": {
                        "h": 10,
                        "w": 12,
                        "x": 12,
                        "y": 113
                      },
                      "hiddenSeries": false,
                      "id": 22,
                      "legend": {
                        "alignAsTable": true,
                        "avg": true,
                        "current": true,
                        "max": true,
                        "min": true,
                        "rightSide": false,
                        "show": true,
                        "total": false,
                        "values": true
                      },
                      "lines": true,
                      "linewidth": 1,
                      "links": [],
                      "maxPerRow": 6,
                      "nullPointMode": "null",
                      "options": {
                        "alertThreshold": true
                      },
                      "percentage": false,
                      "pluginVersion": "8.4.2",
                      "pointradius": 5,
                      "points": false,
                      "renderer": "flot",
                      "seriesOverrides": [
                        {
                          "alias": "/.*out/",
                          "transform": "negative-Y"
                        }
                      ],
                      "spaceLength": 10,
                      "stack": false,
                      "steppedLine": false,
                      "targets": [
                        {
                          "expr": "rate(node_vmstat_pswpin{kubernetes_node=\"$node\"}[$__rate_interval])",
                          "format": "time_series",
                          "intervalFactor": 1,
                          "legendFormat": "Pswpin - Pages swapped in",
                          "refId": "A",
                          "step": 240
                        },
                        {
                          "expr": "rate(node_vmstat_pswpout{kubernetes_node=\"$node\"}[$__rate_interval])",
                          "format": "time_series",
                          "intervalFactor": 1,
                          "legendFormat": "Pswpout - Pages swapped out",
                          "refId": "B",
                          "step": 240
                        }
                      ],
                      "thresholds": [],
                      "timeRegions": [],
                      "title": "Memory Pages Swap In / Out",
                      "tooltip": {
                        "shared": true,
                        "sort": 0,
                        "value_type": "individual"
                      },
                      "type": "graph",
                      "xaxis": {
                        "mode": "time",
                        "show": true,
                        "values": []
                      },
                      "yaxes": [
                        {
                          "format": "short",
                          "label": "pages out (-) / in (+)",
                          "logBase": 1,
                          "show": true
                        },
                        {
                          "format": "short",
                          "logBase": 1,
                          "show": false
                        }
                      ],
                      "yaxis": {
                        "align": false
                      }
                    },
                    {
                      "aliasColors": {
                        "Active": "#99440A",
                        "Buffers": "#58140C",
                        "Cache": "#6D1F62",
                        "Cached": "#511749",
                        "Committed": "#508642",
                        "Dirty": "#6ED0E0",
                        "Free": "#B7DBAB",
                        "Inactive": "#EA6460",
                        "Mapped": "#052B51",
                        "PageTables": "#0A50A1",
                        "Page_Tables": "#0A50A1",
                        "Slab_Cache": "#EAB839",
                        "Swap": "#BF1B00",
                        "Swap_Cache": "#C15C17",
                        "Total": "#511749",
                        "Total RAM": "#052B51",
                        "Total RAM + Swap": "#052B51",
                        "VmallocUsed": "#EA6460"
                      },
                      "bars": false,
                      "dashLength": 10,
                      "dashes": false,
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "decimals": 2,
                      "fieldConfig": {
                        "defaults": {
                          "links": []
                        },
                        "overrides": []
                      },
                      "fill": 2,
                      "fillGradient": 0,
                      "gridPos": {
                        "h": 10,
                        "w": 12,
                        "x": 0,
                        "y": 115
                      },
                      "hiddenSeries": false,
                      "id": 128,
                      "legend": {
                        "alignAsTable": true,
                        "avg": true,
                        "current": false,
                        "hideEmpty": false,
                        "hideZero": false,
                        "max": true,
                        "min": true,
                        "rightSide": false,
                        "show": true,
                        "total": false,
                        "values": true
                      },
                      "lines": true,
                      "linewidth": 1,
                      "links": [],
                      "maxPerRow": 6,
                      "nullPointMode": "null",
                      "percentage": false,
                      "pluginVersion": "8.4.2",
                      "pointradius": 5,
                      "points": false,
                      "renderer": "flot",
                      "seriesOverrides": [],
                      "spaceLength": 10,
                      "stack": false,
                      "steppedLine": false,
                      "targets": [
                        {
                          "expr": "node_memory_DirectMap1G_bytes{kubernetes_node=\"$node\"}",
                          "format": "time_series",
                          "intervalFactor": 1,
                          "legendFormat": "DirectMap1G - Amount of pages mapped as this size",
                          "refId": "A",
                          "step": 240
                        },
                        {
                          "expr": "node_memory_DirectMap2M_bytes{kubernetes_node=\"$node\"}",
                          "format": "time_series",
                          "interval": "",
                          "intervalFactor": 1,
                          "legendFormat": "DirectMap2M - Amount of pages mapped as this size",
                          "refId": "B",
                          "step": 240
                        },
                        {
                          "expr": "node_memory_DirectMap4k_bytes{kubernetes_node=\"$node\"}",
                          "format": "time_series",
                          "interval": "",
                          "intervalFactor": 1,
                          "legendFormat": "DirectMap4K - Amount of pages mapped as this size",
                          "refId": "C",
                          "step": 240
                        }
                      ],
                      "thresholds": [],
                      "timeRegions": [],
                      "title": "Memory DirectMap",
                      "tooltip": {
                        "shared": true,
                        "sort": 0,
                        "value_type": "individual"
                      },
                      "type": "graph",
                      "xaxis": {
                        "mode": "time",
                        "show": true,
                        "values": []
                      },
                      "yaxes": [
                        {
                          "format": "bytes",
                          "label": "bytes",
                          "logBase": 1,
                          "min": "0",
                          "show": true
                        },
                        {
                          "format": "short",
                          "logBase": 1,
                          "show": false
                        }
                      ],
                      "yaxis": {
                        "align": false
                      }
                    },
                    {
                      "aliasColors": {
                        "Active": "#99440A",
                        "Buffers": "#58140C",
                        "Cache": "#6D1F62",
                        "Cached": "#511749",
                        "Committed": "#508642",
                        "Dirty": "#6ED0E0",
                        "Free": "#B7DBAB",
                        "Inactive": "#EA6460",
                        "Mapped": "#052B51",
                        "PageTables": "#0A50A1",
                        "Page_Tables": "#0A50A1",
                        "Slab_Cache": "#EAB839",
                        "Swap": "#BF1B00",
                        "Swap_Cache": "#C15C17",
                        "Total": "#511749",
                        "Total RAM": "#052B51",
                        "Total RAM + Swap": "#052B51",
                        "Total Swap": "#614D93",
                        "VmallocUsed": "#EA6460"
                      },
                      "bars": false,
                      "dashLength": 10,
                      "dashes": false,
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "decimals": 2,
                      "fieldConfig": {
                        "defaults": {
                          "links": []
                        },
                        "overrides": []
                      },
                      "fill": 2,
                      "fillGradient": 0,
                      "gridPos": {
                        "h": 10,
                        "w": 12,
                        "x": 12,
                        "y": 123
                      },
                      "hiddenSeries": false,
                      "id": 307,
                      "legend": {
                        "alignAsTable": true,
                        "avg": true,
                        "current": true,
                        "max": true,
                        "min": true,
                        "rightSide": false,
                        "show": true,
                        "total": false,
                        "values": true
                      },
                      "lines": true,
                      "linewidth": 1,
                      "links": [],
                      "maxPerRow": 6,
                      "nullPointMode": "null",
                      "options": {
                        "alertThreshold": true
                      },
                      "percentage": false,
                      "pluginVersion": "8.4.2",
                      "pointradius": 5,
                      "points": false,
                      "renderer": "flot",
                      "seriesOverrides": [],
                      "spaceLength": 10,
                      "stack": false,
                      "steppedLine": false,
                      "targets": [
                        {
                          "expr": "rate(node_vmstat_oom_kill{kubernetes_node=\"$node\"}[$__rate_interval])",
                          "format": "time_series",
                          "interval": "",
                          "intervalFactor": 1,
                          "legendFormat": "oom killer invocations ",
                          "refId": "A",
                          "step": 240
                        }
                      ],
                      "thresholds": [],
                      "timeRegions": [],
                      "title": "OOM Killer",
                      "tooltip": {
                        "shared": true,
                        "sort": 0,
                        "value_type": "individual"
                      },
                      "type": "graph",
                      "xaxis": {
                        "mode": "time",
                        "show": true,
                        "values": []
                      },
                      "yaxes": [
                        {
                          "$$hashKey": "object:5373",
                          "format": "short",
                          "label": "counter",
                          "logBase": 1,
                          "min": "0",
                          "show": true
                        },
                        {
                          "$$hashKey": "object:5374",
                          "format": "short",
                          "logBase": 1,
                          "show": false
                        }
                      ],
                      "yaxis": {
                        "align": false
                      }
                    },
                    {
                      "aliasColors": {
                        "Active": "#99440A",
                        "Buffers": "#58140C",
                        "Cache": "#6D1F62",
                        "Cached": "#511749",
                        "Committed": "#508642",
                        "Dirty": "#6ED0E0",
                        "Free": "#B7DBAB",
                        "Inactive": "#EA6460",
                        "Mapped": "#052B51",
                        "PageTables": "#0A50A1",
                        "Page_Tables": "#0A50A1",
                        "Slab_Cache": "#EAB839",
                        "Swap": "#BF1B00",
                        "Swap_Cache": "#C15C17",
                        "Total": "#511749",
                        "Total RAM": "#052B51",
                        "Total RAM + Swap": "#052B51",
                        "Total Swap": "#614D93",
                        "VmallocUsed": "#EA6460"
                      },
                      "bars": false,
                      "dashLength": 10,
                      "dashes": false,
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "decimals": 2,
                      "fieldConfig": {
                        "defaults": {
                          "links": []
                        },
                        "overrides": []
                      },
                      "fill": 2,
                      "fillGradient": 0,
                      "gridPos": {
                        "h": 10,
                        "w": 12,
                        "x": 0,
                        "y": 125
                      },
                      "hiddenSeries": false,
                      "id": 132,
                      "legend": {
                        "alignAsTable": true,
                        "avg": true,
                        "current": true,
                        "max": true,
                        "min": true,
                        "rightSide": false,
                        "show": true,
                        "total": false,
                        "values": true
                      },
                      "lines": true,
                      "linewidth": 1,
                      "links": [],
                      "maxPerRow": 6,
                      "nullPointMode": "null",
                      "percentage": false,
                      "pluginVersion": "8.4.2",
                      "pointradius": 5,
                      "points": false,
                      "renderer": "flot",
                      "seriesOverrides": [],
                      "spaceLength": 10,
                      "stack": false,
                      "steppedLine": false,
                      "targets": [
                        {
                          "expr": "node_memory_NFS_Unstable_bytes{kubernetes_node=\"$node\"}",
                          "format": "time_series",
                          "intervalFactor": 1,
                          "legendFormat": "NFS Unstable - Memory in NFS pages sent to the server, but not yet commited to the storage",
                          "refId": "A",
                          "step": 240
                        }
                      ],
                      "thresholds": [],
                      "timeRegions": [],
                      "title": "Memory NFS",
                      "tooltip": {
                        "shared": true,
                        "sort": 0,
                        "value_type": "individual"
                      },
                      "type": "graph",
                      "xaxis": {
                        "mode": "time",
                        "show": true,
                        "values": []
                      },
                      "yaxes": [
                        {
                          "format": "bytes",
                          "label": "bytes",
                          "logBase": 1,
                          "min": "0",
                          "show": true
                        },
                        {
                          "format": "short",
                          "logBase": 1,
                          "show": false
                        }
                      ],
                      "yaxis": {
                        "align": false
                      }
                    },
                    {
                      "aliasColors": {},
                      "bars": false,
                      "dashLength": 10,
                      "dashes": false,
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "fieldConfig": {
                        "defaults": {
                          "links": []
                        },
                        "overrides": []
                      },
                      "fill": 2,
                      "fillGradient": 0,
                      "gridPos": {
                        "h": 10,
                        "w": 12,
                        "x": 0,
                        "y": 135
                      },
                      "hiddenSeries": false,
                      "id": 176,
                      "legend": {
                        "alignAsTable": true,
                        "avg": true,
                        "current": true,
                        "max": true,
                        "min": true,
                        "rightSide": false,
                        "show": true,
                        "total": false,
                        "values": true
                      },
                      "lines": true,
                      "linewidth": 1,
                      "links": [],
                      "maxPerRow": 6,
                      "nullPointMode": "null",
                      "options": {
                        "alertThreshold": true
                      },
                      "percentage": false,
                      "pluginVersion": "8.4.2",
                      "pointradius": 5,
                      "points": false,
                      "renderer": "flot",
                      "seriesOverrides": [
                        {
                          "alias": "/.*out/",
                          "transform": "negative-Y"
                        }
                      ],
                      "spaceLength": 10,
                      "stack": false,
                      "steppedLine": false,
                      "targets": [
                        {
                          "expr": "rate(node_vmstat_pgpgin{kubernetes_node=\"$node\"}[$__rate_interval])",
                          "format": "time_series",
                          "intervalFactor": 1,
                          "legendFormat": "Pagesin - Page in operations",
                          "refId": "A",
                          "step": 240
                        },
                        {
                          "expr": "rate(node_vmstat_pgpgout{kubernetes_node=\"$node\"}[$__rate_interval])",
                          "format": "time_series",
                          "intervalFactor": 1,
                          "legendFormat": "Pagesout - Page out operations",
                          "refId": "B",
                          "step": 240
                        }
                      ],
                      "thresholds": [],
                      "timeRegions": [],
                      "title": "Memory Pages In / Out",
                      "tooltip": {
                        "shared": true,
                        "sort": 0,
                        "value_type": "individual"
                      },
                      "type": "graph",
                      "xaxis": {
                        "mode": "time",
                        "show": true,
                        "values": []
                      },
                      "yaxes": [
                        {
                          "format": "short",
                          "label": "pages out (-) / in (+)",
                          "logBase": 1,
                          "show": true
                        },
                        {
                          "format": "short",
                          "logBase": 1,
                          "show": false
                        }
                      ],
                      "yaxis": {
                        "align": false
                      }
                    },
                    {
                      "aliasColors": {
                        "Apps": "#629E51",
                        "Buffers": "#614D93",
                        "Cache": "#6D1F62",
                        "Cached": "#511749",
                        "Committed": "#508642",
                        "Free": "#0A437C",
                        "Hardware Corrupted - Amount of RAM that the kernel identified as corrupted / not working": "#CFFAFF",
                        "Inactive": "#584477",
                        "PageTables": "#0A50A1",
                        "Page_Tables": "#0A50A1",
                        "RAM_Free": "#E0F9D7",
                        "Slab": "#806EB7",
                        "Slab_Cache": "#E0752D",
                        "Swap": "#BF1B00",
                        "Swap_Cache": "#C15C17",
                        "Swap_Free": "#2F575E",
                        "Unused": "#EAB839"
                      },
                      "bars": false,
                      "dashLength": 10,
                      "dashes": false,
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "decimals": 2,
                      "fieldConfig": {
                        "defaults": {
                          "links": []
                        },
                        "overrides": []
                      },
                      "fill": 2,
                      "fillGradient": 0,
                      "gridPos": {
                        "h": 10,
                        "w": 12,
                        "x": 0,
                        "y": 145
                      },
                      "hiddenSeries": false,
                      "id": 175,
                      "legend": {
                        "alignAsTable": true,
                        "avg": true,
                        "current": true,
                        "max": true,
                        "min": true,
                        "rightSide": false,
                        "show": true,
                        "sideWidth": 350,
                        "total": false,
                        "values": true
                      },
                      "lines": true,
                      "linewidth": 1,
                      "links": [],
                      "maxPerRow": 6,
                      "nullPointMode": "null",
                      "options": {
                        "alertThreshold": true
                      },
                      "percentage": false,
                      "pluginVersion": "8.4.2",
                      "pointradius": 5,
                      "points": false,
                      "renderer": "flot",
                      "seriesOverrides": [
                        {
                          "$$hashKey": "object:6118",
                          "alias": "Pgfault - Page major and minor fault operations",
                          "fill": 0,
                          "stack": false
                        }
                      ],
                      "spaceLength": 10,
                      "stack": true,
                      "steppedLine": false,
                      "targets": [
                        {
                          "expr": "rate(node_vmstat_pgfault{kubernetes_node=\"$node\"}[$__rate_interval])",
                          "format": "time_series",
                          "intervalFactor": 1,
                          "legendFormat": "Pgfault - Page major and minor fault operations",
                          "refId": "A",
                          "step": 240
                        },
                        {
                          "expr": "rate(node_vmstat_pgmajfault{kubernetes_node=\"$node\"}[$__rate_interval])",
                          "format": "time_series",
                          "intervalFactor": 1,
                          "legendFormat": "Pgmajfault - Major page fault operations",
                          "refId": "B",
                          "step": 240
                        },
                        {
                          "expr": "rate(node_vmstat_pgfault{kubernetes_node=\"$node\"}[$__rate_interval])  - rate(node_vmstat_pgmajfault{kubernetes_node=\"$node\"}[$__rate_interval])",
                          "format": "time_series",
                          "intervalFactor": 1,
                          "legendFormat": "Pgminfault - Minor page fault operations",
                          "refId": "C",
                          "step": 240
                        }
                      ],
                      "thresholds": [],
                      "timeRegions": [],
                      "title": "Memory Page Faults",
                      "tooltip": {
                        "shared": true,
                        "sort": 0,
                        "value_type": "cumulative"
                      },
                      "type": "graph",
                      "xaxis": {
                        "mode": "time",
                        "show": true,
                        "values": []
                      },
                      "yaxes": [
                        {
                          "$$hashKey": "object:6133",
                          "format": "short",
                          "label": "faults",
                          "logBase": 1,
                          "min": "0",
                          "show": true
                        },
                        {
                          "$$hashKey": "object:6134",
                          "format": "short",
                          "logBase": 1,
                          "show": false
                        }
                      ],
                      "yaxis": {
                        "align": false
                      }
                    }
                  ],
                  "title": "CPU / Memory / Net / Disk",
                  "type": "row"
                },
                {
                  "collapsed": true,
                  "datasource": {
                    "type": "prometheus",
                    "uid": "prometheus"
                  },
                  "gridPos": {
                    "h": 1,
                    "w": 24,
                    "x": 0,
                    "y": 21
                  },
                  "id": 293,
                  "panels": [
                    {
                      "aliasColors": {},
                      "bars": false,
                      "dashLength": 10,
                      "dashes": false,
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "description": "",
                      "fill": 2,
                      "fillGradient": 0,
                      "gridPos": {
                        "h": 10,
                        "w": 12,
                        "x": 0,
                        "y": 24
                      },
                      "hiddenSeries": false,
                      "id": 260,
                      "legend": {
                        "alignAsTable": true,
                        "avg": true,
                        "current": true,
                        "max": true,
                        "min": true,
                        "show": true,
                        "total": false,
                        "values": true
                      },
                      "lines": true,
                      "linewidth": 1,
                      "links": [],
                      "nullPointMode": "null",
                      "options": {
                        "dataLinks": []
                      },
                      "percentage": false,
                      "pointradius": 5,
                      "points": false,
                      "renderer": "flot",
                      "seriesOverrides": [
                        {
                          "alias": "/.*Variation*./",
                          "color": "#890F02"
                        }
                      ],
                      "spaceLength": 10,
                      "stack": false,
                      "steppedLine": false,
                      "targets": [
                        {
                          "expr": "node_timex_estimated_error_seconds{kubernetes_node=\"$node\"}",
                          "format": "time_series",
                          "hide": false,
                          "interval": "",
                          "intervalFactor": 1,
                          "legendFormat": "Estimated error in seconds",
                          "refId": "A",
                          "step": 240
                        },
                        {
                          "expr": "node_timex_offset_seconds{kubernetes_node=\"$node\"}",
                          "format": "time_series",
                          "hide": false,
                          "interval": "",
                          "intervalFactor": 1,
                          "legendFormat": "Time offset in between local system and reference clock",
                          "refId": "B",
                          "step": 240
                        },
                        {
                          "expr": "node_timex_maxerror_seconds{kubernetes_node=\"$node\"}",
                          "format": "time_series",
                          "hide": false,
                          "interval": "",
                          "intervalFactor": 1,
                          "legendFormat": "Maximum error in seconds",
                          "refId": "C",
                          "step": 240
                        }
                      ],
                      "thresholds": [],
                      "timeRegions": [],
                      "title": "Time Syncronized Drift",
                      "tooltip": {
                        "shared": true,
                        "sort": 0,
                        "value_type": "individual"
                      },
                      "type": "graph",
                      "xaxis": {
                        "mode": "time",
                        "show": true,
                        "values": []
                      },
                      "yaxes": [
                        {
                          "format": "s",
                          "label": "seconds",
                          "logBase": 1,
                          "show": true
                        },
                        {
                          "format": "short",
                          "label": "counter",
                          "logBase": 1,
                          "show": false
                        }
                      ],
                      "yaxis": {
                        "align": false
                      }
                    },
                    {
                      "aliasColors": {},
                      "bars": false,
                      "dashLength": 10,
                      "dashes": false,
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "description": "",
                      "fill": 2,
                      "fillGradient": 0,
                      "gridPos": {
                        "h": 10,
                        "w": 12,
                        "x": 12,
                        "y": 24
                      },
                      "hiddenSeries": false,
                      "id": 291,
                      "legend": {
                        "alignAsTable": true,
                        "avg": true,
                        "current": true,
                        "max": true,
                        "min": true,
                        "show": true,
                        "total": false,
                        "values": true
                      },
                      "lines": true,
                      "linewidth": 1,
                      "links": [],
                      "nullPointMode": "null",
                      "options": {
                        "dataLinks": []
                      },
                      "percentage": false,
                      "pointradius": 5,
                      "points": false,
                      "renderer": "flot",
                      "seriesOverrides": [],
                      "spaceLength": 10,
                      "stack": false,
                      "steppedLine": false,
                      "targets": [
                        {
                          "expr": "node_timex_loop_time_constant{kubernetes_node=\"$node\"}",
                          "format": "time_series",
                          "interval": "",
                          "intervalFactor": 1,
                          "legendFormat": "Phase-locked loop time adjust",
                          "refId": "A",
                          "step": 240
                        }
                      ],
                      "thresholds": [],
                      "timeRegions": [],
                      "title": "Time PLL Adjust",
                      "tooltip": {
                        "shared": true,
                        "sort": 0,
                        "value_type": "individual"
                      },
                      "type": "graph",
                      "xaxis": {
                        "mode": "time",
                        "show": true,
                        "values": []
                      },
                      "yaxes": [
                        {
                          "format": "short",
                          "label": "counter",
                          "logBase": 1,
                          "show": true
                        },
                        {
                          "format": "short",
                          "logBase": 1,
                          "show": false
                        }
                      ],
                      "yaxis": {
                        "align": false
                      }
                    },
                    {
                      "aliasColors": {},
                      "bars": false,
                      "dashLength": 10,
                      "dashes": false,
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "description": "",
                      "fill": 2,
                      "fillGradient": 0,
                      "gridPos": {
                        "h": 10,
                        "w": 12,
                        "x": 0,
                        "y": 34
                      },
                      "hiddenSeries": false,
                      "id": 168,
                      "legend": {
                        "alignAsTable": true,
                        "avg": true,
                        "current": true,
                        "max": true,
                        "min": true,
                        "show": true,
                        "total": false,
                        "values": true
                      },
                      "lines": true,
                      "linewidth": 1,
                      "links": [],
                      "nullPointMode": "null",
                      "options": {
                        "dataLinks": []
                      },
                      "percentage": false,
                      "pointradius": 5,
                      "points": false,
                      "renderer": "flot",
                      "seriesOverrides": [
                        {
                          "alias": "/.*Variation*./",
                          "color": "#890F02"
                        }
                      ],
                      "spaceLength": 10,
                      "stack": false,
                      "steppedLine": false,
                      "targets": [
                        {
                          "expr": "node_timex_sync_status{kubernetes_node=\"$node\"}",
                          "format": "time_series",
                          "interval": "",
                          "intervalFactor": 1,
                          "legendFormat": "Is clock synchronized to a reliable server (1 = yes, 0 = no)",
                          "refId": "A",
                          "step": 240
                        },
                        {
                          "expr": "node_timex_frequency_adjustment_ratio{kubernetes_node=\"$node\"}",
                          "format": "time_series",
                          "interval": "",
                          "intervalFactor": 1,
                          "legendFormat": "Local clock frequency adjustment",
                          "refId": "B",
                          "step": 240
                        }
                      ],
                      "thresholds": [],
                      "timeRegions": [],
                      "title": "Time Syncronized Status",
                      "tooltip": {
                        "shared": true,
                        "sort": 0,
                        "value_type": "individual"
                      },
                      "type": "graph",
                      "xaxis": {
                        "mode": "time",
                        "show": true,
                        "values": []
                      },
                      "yaxes": [
                        {
                          "format": "short",
                          "label": "counter",
                          "logBase": 1,
                          "show": true
                        },
                        {
                          "format": "short",
                          "logBase": 1,
                          "show": false
                        }
                      ],
                      "yaxis": {
                        "align": false
                      }
                    },
                    {
                      "aliasColors": {},
                      "bars": false,
                      "dashLength": 10,
                      "dashes": false,
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "description": "",
                      "fill": 2,
                      "fillGradient": 0,
                      "gridPos": {
                        "h": 10,
                        "w": 12,
                        "x": 12,
                        "y": 34
                      },
                      "hiddenSeries": false,
                      "id": 294,
                      "legend": {
                        "alignAsTable": true,
                        "avg": true,
                        "current": true,
                        "max": true,
                        "min": true,
                        "show": true,
                        "total": false,
                        "values": true
                      },
                      "lines": true,
                      "linewidth": 1,
                      "links": [],
                      "nullPointMode": "null",
                      "options": {
                        "dataLinks": []
                      },
                      "percentage": false,
                      "pointradius": 5,
                      "points": false,
                      "renderer": "flot",
                      "seriesOverrides": [],
                      "spaceLength": 10,
                      "stack": false,
                      "steppedLine": false,
                      "targets": [
                        {
                          "expr": "node_timex_tick_seconds{kubernetes_node=\"$node\"}",
                          "format": "time_series",
                          "interval": "",
                          "intervalFactor": 1,
                          "legendFormat": "Seconds between clock ticks",
                          "refId": "A",
                          "step": 240
                        },
                        {
                          "expr": "node_timex_tai_offset_seconds{kubernetes_node=\"$node\"}",
                          "format": "time_series",
                          "interval": "",
                          "intervalFactor": 1,
                          "legendFormat": "International Atomic Time (TAI) offset",
                          "refId": "B",
                          "step": 240
                        }
                      ],
                      "thresholds": [],
                      "timeRegions": [],
                      "title": "Time Misc",
                      "tooltip": {
                        "shared": true,
                        "sort": 0,
                        "value_type": "individual"
                      },
                      "type": "graph",
                      "xaxis": {
                        "mode": "time",
                        "show": true,
                        "values": []
                      },
                      "yaxes": [
                        {
                          "format": "s",
                          "label": "seconds",
                          "logBase": 1,
                          "show": true
                        },
                        {
                          "format": "short",
                          "logBase": 1,
                          "show": false
                        }
                      ],
                      "yaxis": {
                        "align": false
                      }
                    }
                  ],
                  "title": "System Timesync",
                  "type": "row"
                },
                {
                  "collapsed": true,
                  "datasource": {
                    "type": "prometheus",
                    "uid": "prometheus"
                  },
                  "gridPos": {
                    "h": 1,
                    "w": 24,
                    "x": 0,
                    "y": 22
                  },
                  "id": 279,
                  "panels": [
                    {
                      "aliasColors": {},
                      "bars": false,
                      "dashLength": 10,
                      "dashes": false,
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "description": "",
                      "fill": 2,
                      "fillGradient": 0,
                      "gridPos": {
                        "h": 10,
                        "w": 12,
                        "x": 0,
                        "y": 54
                      },
                      "hiddenSeries": false,
                      "id": 40,
                      "legend": {
                        "alignAsTable": true,
                        "avg": true,
                        "current": true,
                        "max": true,
                        "min": true,
                        "show": true,
                        "sort": "current",
                        "sortDesc": true,
                        "total": false,
                        "values": true
                      },
                      "lines": true,
                      "linewidth": 1,
                      "links": [],
                      "nullPointMode": "null",
                      "options": {
                        "dataLinks": []
                      },
                      "percentage": false,
                      "pointradius": 5,
                      "points": false,
                      "renderer": "flot",
                      "seriesOverrides": [],
                      "spaceLength": 10,
                      "stack": true,
                      "steppedLine": false,
                      "targets": [
                        {
                          "expr": "node_scrape_collector_duration_seconds{kubernetes_node=\"$node\"}",
                          "format": "time_series",
                          "hide": false,
                          "interval": "",
                          "intervalFactor": 1,
                          "legendFormat": "{{collector}} - Scrape duration",
                          "refId": "A",
                          "step": 240
                        }
                      ],
                      "thresholds": [],
                      "timeRegions": [],
                      "title": "Node Exporter Scrape Time",
                      "tooltip": {
                        "shared": true,
                        "sort": 0,
                        "value_type": "individual"
                      },
                      "type": "graph",
                      "xaxis": {
                        "mode": "time",
                        "show": true,
                        "values": []
                      },
                      "yaxes": [
                        {
                          "format": "s",
                          "label": "seconds",
                          "logBase": 1,
                          "show": true
                        },
                        {
                          "format": "short",
                          "logBase": 1,
                          "show": false
                        }
                      ],
                      "yaxis": {
                        "align": false
                      }
                    },
                    {
                      "aliasColors": {},
                      "bars": false,
                      "dashLength": 10,
                      "dashes": false,
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "description": "",
                      "fill": 2,
                      "fillGradient": 0,
                      "gridPos": {
                        "h": 10,
                        "w": 12,
                        "x": 12,
                        "y": 54
                      },
                      "hiddenSeries": false,
                      "id": 157,
                      "legend": {
                        "alignAsTable": true,
                        "avg": true,
                        "current": true,
                        "max": true,
                        "min": true,
                        "show": true,
                        "total": false,
                        "values": true
                      },
                      "lines": true,
                      "linewidth": 1,
                      "links": [],
                      "nullPointMode": "null",
                      "options": {
                        "dataLinks": []
                      },
                      "percentage": false,
                      "pointradius": 5,
                      "points": false,
                      "renderer": "flot",
                      "seriesOverrides": [
                        {
                          "$$hashKey": "object:1969",
                          "alias": "/.*error.*/",
                          "color": "#F2495C",
                          "transform": "negative-Y"
                        }
                      ],
                      "spaceLength": 10,
                      "stack": true,
                      "steppedLine": false,
                      "targets": [
                        {
                          "expr": "node_scrape_collector_success{kubernetes_node=\"$node\"}",
                          "format": "time_series",
                          "hide": false,
                          "interval": "",
                          "intervalFactor": 1,
                          "legendFormat": "{{collector}} - Scrape success",
                          "refId": "A",
                          "step": 240
                        },
                        {
                          "expr": "node_textfile_scrape_error{kubernetes_node=\"$node\"}",
                          "format": "time_series",
                          "hide": false,
                          "interval": "",
                          "intervalFactor": 1,
                          "legendFormat": "{{collector}} - Scrape textfile error (1 = true)",
                          "refId": "B",
                          "step": 240
                        }
                      ],
                      "thresholds": [],
                      "timeRegions": [],
                      "title": "Node Exporter Scrape",
                      "tooltip": {
                        "shared": true,
                        "sort": 0,
                        "value_type": "individual"
                      },
                      "type": "graph",
                      "xaxis": {
                        "mode": "time",
                        "show": true,
                        "values": []
                      },
                      "yaxes": [
                        {
                          "$$hashKey": "object:1484",
                          "format": "short",
                          "label": "counter",
                          "logBase": 1,
                          "show": true
                        },
                        {
                          "$$hashKey": "object:1485",
                          "format": "short",
                          "logBase": 1,
                          "show": false
                        }
                      ],
                      "yaxis": {
                        "align": false
                      }
                    }
                  ],
                  "title": "Node Exporter",
                  "type": "row"
                }
              ],
              "refresh": "30s",
              "schemaVersion": 35,
              "style": "dark",
              "tags": [
                "linux"
              ],
              "templating": {
                "list": [
                  {
                    "current": {
                      "selected": true,
                      "text": "Promethues",
                      "value": "Promethues"
                    },
                    "hide": 0,
                    "includeAll": false,
                    "label": "datasource",
                    "multi": false,
                    "name": "DS_PROMETHEUS",
                    "options": [],
                    "query": "prometheus",
                    "queryValue": "",
                    "refresh": 1,
                    "regex": "",
                    "skipUrlSync": false,
                    "type": "datasource"
                  },
                  {
                    "datasource": {
                      "type": "prometheus",
                      "uid": "prometheus"
                    },
                    "definition": "label_values(node_uname_info, kubernetes_node)",
                    "hide": 0,
                    "includeAll": false,
                    "label": "Host:",
                    "multi": false,
                    "name": "node",
                    "options": [],
                    "query": {
                      "query": "label_values(node_uname_info, kubernetes_node)",
                      "refId": "StandardVariableQuery"
                    },
                    "refresh": 1,
                    "regex": "",
                    "skipUrlSync": false,
                    "sort": 1,
                    "tagValuesQuery": "",
                    "tagsQuery": "",
                    "type": "query",
                    "useTags": false
                  },
                  {
                    "current": {
                      "selected": false,
                      "text": "[a-z]+|nvme[0-9]+n[0-9]+|mmcblk[0-9]+",
                      "value": "[a-z]+|nvme[0-9]+n[0-9]+|mmcblk[0-9]+"
                    },
                    "hide": 2,
                    "includeAll": false,
                    "multi": false,
                    "name": "diskdevices",
                    "options": [
                      {
                        "selected": true,
                        "text": "[a-z]+|nvme[0-9]+n[0-9]+|mmcblk[0-9]+",
                        "value": "[a-z]+|nvme[0-9]+n[0-9]+|mmcblk[0-9]+"
                      }
                    ],
                    "query": "[a-z]+|nvme[0-9]+n[0-9]+|mmcblk[0-9]+",
                    "skipUrlSync": false,
                    "type": "custom"
                  }
                ]
              },
              "time": {
                "from": "now-30m",
                "to": "now"
              },
              "timepicker": {
                "refresh_intervals": [
                  "5s",
                  "10s",
                  "30s",
                  "1m",
                  "5m",
                  "15m",
                  "30m",
                  "1h",
                  "2h",
                  "1d"
                ],
                "time_options": [
                  "5m",
                  "15m",
                  "1h",
                  "6h",
                  "12h",
                  "24h",
                  "2d",
                  "7d",
                  "30d"
                ]
              },
              "timezone": "browser",
              "title": "Node Exporter Full",
              "uid": "rYdddlPWkrrrrrT",
              "version": 1,
              "weekStart": ""
            }
        kind: ConfigMap
        metadata:
          labels:
            grafana_dashboard: "1"
          name: slurm-node-exporter
          namespace: ${local.monitoring_namespace}
    EOF
  ]
}