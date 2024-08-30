resource "helm_release" "slurm_exporter" {
  count = var.k8s_monitoring_enabled ? 1 : 0
  depends_on = [
    module.k8s_cluster,
    helm_release.cert_manager,
    helm_release.prometheus,
    helm_release.victoria_metrics_operator,
  ]
  name       = "slurm-exporter"
  namespace  = local.monitoring_namespace
  repository = "https://bedag.github.io/helm-charts/"
  chart      = "raw"
  version    = "2.0.0"
  values = [
    <<-EOF
    resources:
      - apiVersion: v1
        data:
          slurm-exporter.json: |-
            {
              "annotations": {
                "list": [
                  {
                    "$$hashKey": "object:1345",
                    "builtIn": 1,
                    "datasource": {
                      "type": "datasource",
                      "uid": "grafana"
                    },
                    "enable": true,
                    "hide": true,
                    "iconColor": "rgba(0, 211, 255, 1)",
                    "name": "Annotations & Alerts",
                    "type": "dashboard"
                  }
                ]
              },
              "description": "slurm-exporter",
              "editable": true,
              "fiscalYearStartMonth": 0,
              "gnetId": 4323,
              "graphTooltip": 0,
              "id": 6,
              "links": [],
              "panels": [
                {
                  "datasource": {
                    "type": "prometheus",
                    "uid": "prometheus"
                  },
                  "description": "NCCL tests introduce the \"Bus Bandwidth\" metric to better reflect how optimally hardware is used for inter-GPU communication, allowing for comparison with hardware peak bandwidth regardless of the number of ranks, unlike traditional time or algorithm bandwidth measurements.",
                  "fieldConfig": {
                    "defaults": {
                      "color": {
                        "mode": "thresholds"
                      },
                      "mappings": [],
                      "noValue": "All Benchmark passed",
                      "thresholds": {
                        "mode": "absolute",
                        "steps": [
                          {
                            "color": "green",
                            "value": null
                          },
                          {
                            "color": "red",
                            "value": ""
                          }
                        ]
                      }
                    },
                    "overrides": []
                  },
                  "gridPos": {
                    "h": 8,
                    "w": 8,
                    "x": 0,
                    "y": 0
                  },
                  "id": 51,
                  "options": {
                    "minVizHeight": 75,
                    "minVizWidth": 75,
                    "orientation": "auto",
                    "reduceOptions": {
                      "calcs": [
                        "lastNotNull"
                      ],
                      "fields": "",
                      "values": false
                    },
                    "showThresholdLabels": false,
                    "showThresholdMarkers": true,
                    "sizing": "auto"
                  },
                  "pluginVersion": "11.1.0",
                  "targets": [
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "editorMode": "code",
                      "expr": "topk(5, slurm_job_nccl_benchmark_avg_bandwidth[3h] > 420) by (slurm_node)",
                      "instant": false,
                      "legendFormat": "{{slurm_node}}",
                      "range": true,
                      "refId": "A"
                    }
                  ],
                  "title": "TOP 5 nccl failed benchmark",
                  "type": "gauge"
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
                      "mappings": [
                        {
                          "options": {
                            "no dara": {
                              "index": 0,
                              "text": "No Failed jobs"
                            }
                          },
                          "type": "value"
                        }
                      ],
                      "noValue": "No failed jobs",
                      "thresholds": {
                        "mode": "absolute",
                        "steps": [
                          {
                            "color": "green",
                            "value": null
                          },
                          {
                            "color": "red",
                            "value": 1
                          }
                        ]
                      }
                    },
                    "overrides": []
                  },
                  "gridPos": {
                    "h": 8,
                    "w": 8,
                    "x": 8,
                    "y": 0
                  },
                  "id": 52,
                  "options": {
                    "minVizHeight": 75,
                    "minVizWidth": 75,
                    "orientation": "auto",
                    "reduceOptions": {
                      "calcs": [
                        "lastNotNull"
                      ],
                      "fields": "",
                      "values": false
                    },
                    "showThresholdLabels": false,
                    "showThresholdMarkers": true,
                    "sizing": "auto"
                  },
                  "pluginVersion": "11.1.0",
                  "targets": [
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "editorMode": "code",
                      "expr": "topk(5, slurm_job_nccl_benchmark_succeed[3h]==0)",
                      "instant": false,
                      "legendFormat": "{{slurm_node}}",
                      "range": true,
                      "refId": "A"
                    }
                  ],
                  "title": "TOP 5 nccl benchmark failed jobs",
                  "type": "gauge"
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
                      "mappings": [
                        {
                          "options": {
                            "no dara": {
                              "index": 0,
                              "text": "No Failed jobs"
                            }
                          },
                          "type": "value"
                        }
                      ],
                      "noValue": "No failed jobs",
                      "thresholds": {
                        "mode": "absolute",
                        "steps": [
                          {
                            "color": "green",
                            "value": null
                          },
                          {
                            "color": "red",
                            "value": 1
                          }
                        ]
                      }
                    },
                    "overrides": []
                  },
                  "gridPos": {
                    "h": 8,
                    "w": 8,
                    "x": 16,
                    "y": 0
                  },
                  "id": 53,
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
                  "pluginVersion": "11.1.0",
                  "targets": [
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "editorMode": "code",
                      "expr": "(slurm_queue_running / (\n  slurm_nodes_alloc + \n  slurm_nodes_down + \n  slurm_nodes_drain + \n  slurm_nodes_idle + \n  slurm_nodes_mix + \n  slurm_nodes_comp + \n  slurm_nodes_maint + \n  slurm_nodes_resv\n)) * 100",
                      "hide": false,
                      "instant": false,
                      "legendFormat": "% Running jobs form total worker node",
                      "range": true,
                      "refId": "A"
                    },
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "editorMode": "code",
                      "expr": "(count(DCGM_FI_PROF_PIPE_TENSOR_ACTIVE == 0) / count(DCGM_FI_PROF_PIPE_TENSOR_ACTIVE)) * 100",
                      "hide": true,
                      "instant": false,
                      "legendFormat": "% inactive GPU",
                      "range": true,
                      "refId": "B"
                    }
                  ],
                  "title": "Running jobs and unsed gpu",
                  "type": "timeseries"
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
                    "y": 8
                  },
                  "id": 12,
                  "panels": [],
                  "targets": [
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "refId": "A"
                    }
                  ],
                  "title": "Cluster Nodes",
                  "type": "row"
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
                        "fillOpacity": 10,
                        "gradientMode": "none",
                        "hideFrom": {
                          "legend": false,
                          "tooltip": false,
                          "viz": false
                        },
                        "insertNulls": false,
                        "lineInterpolation": "linear",
                        "lineWidth": 2,
                        "pointSize": 5,
                        "scaleDistribution": {
                          "type": "linear"
                        },
                        "showPoints": "never",
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
                      "unit": "short"
                    },
                    "overrides": [
                      {
                        "matcher": {
                          "id": "byName",
                          "options": "Total Nodes"
                        },
                        "properties": [
                          {
                            "id": "color",
                            "value": {
                              "fixedColor": "purple",
                              "mode": "fixed"
                            }
                          }
                        ]
                      }
                    ]
                  },
                  "gridPos": {
                    "h": 11,
                    "w": 12,
                    "x": 0,
                    "y": 9
                  },
                  "id": 1,
                  "options": {
                    "legend": {
                      "calcs": [
                        "mean",
                        "lastNotNull",
                        "max",
                        "min"
                      ],
                      "displayMode": "table",
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
                      "expr": "slurm_nodes_alloc + slurm_nodes_comp",
                      "format": "time_series",
                      "intervalFactor": 2,
                      "legendFormat": "Allocated Nodes (including compl)",
                      "refId": "A"
                    },
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "expr": "slurm_nodes_mix",
                      "intervalFactor": 2,
                      "legendFormat": "Mixed Nodes",
                      "refId": "B"
                    },
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "expr": "slurm_nodes_idle",
                      "format": "time_series",
                      "intervalFactor": 2,
                      "legendFormat": "Idle Nodes",
                      "refId": "C"
                    },
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "expr": "slurm_nodes_alloc + slurm_nodes_down + slurm_nodes_drain + slurm_nodes_idle + slurm_nodes_mix + slurm_nodes_comp + slurm_nodes_maint + slurm_nodes_resv",
                      "format": "time_series",
                      "instant": false,
                      "intervalFactor": 2,
                      "legendFormat": "Total Nodes",
                      "refId": "D"
                    }
                  ],
                  "title": "Nodes",
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
                        "fillOpacity": 10,
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
                        "showPoints": "never",
                        "spanNulls": false,
                        "stacking": {
                          "group": "A",
                          "mode": "normal"
                        },
                        "thresholdsStyle": {
                          "mode": "off"
                        }
                      },
                      "mappings": [],
                      "min": 0,
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
                    "overrides": [
                      {
                        "matcher": {
                          "id": "byName",
                          "options": "Down Nodes"
                        },
                        "properties": [
                          {
                            "id": "color",
                            "value": {
                              "fixedColor": "#e24d42",
                              "mode": "fixed"
                            }
                          }
                        ]
                      },
                      {
                        "matcher": {
                          "id": "byName",
                          "options": "Nodes in *fail* state"
                        },
                        "properties": [
                          {
                            "id": "color",
                            "value": {
                              "fixedColor": "#6d1f62",
                              "mode": "fixed"
                            }
                          }
                        ]
                      }
                    ]
                  },
                  "gridPos": {
                    "h": 11,
                    "w": 12,
                    "x": 12,
                    "y": 9
                  },
                  "id": 5,
                  "options": {
                    "legend": {
                      "calcs": [
                        "mean",
                        "lastNotNull",
                        "max",
                        "min"
                      ],
                      "displayMode": "table",
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
                      "expr": "slurm_nodes_down",
                      "format": "time_series",
                      "interval": "",
                      "intervalFactor": 2,
                      "legendFormat": "Down Nodes",
                      "refId": "A"
                    },
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "expr": "slurm_nodes_drain",
                      "format": "time_series",
                      "intervalFactor": 2,
                      "legendFormat": "Draining Nodes",
                      "refId": "B"
                    },
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "expr": "slurm_nodes_err != 0",
                      "format": "time_series",
                      "interval": "",
                      "intervalFactor": 2,
                      "legendFormat": "Nodes in *error* state",
                      "refId": "C"
                    },
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "expr": "slurm_nodes_fail != 0",
                      "format": "time_series",
                      "interval": "",
                      "intervalFactor": 2,
                      "legendFormat": "Nodes in *fail* state",
                      "refId": "D"
                    }
                  ],
                  "title": "Fail/Down/Drain/Err Nodes",
                  "type": "timeseries"
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
                    "y": 20
                  },
                  "id": 13,
                  "panels": [],
                  "targets": [
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "refId": "A"
                    }
                  ],
                  "title": "SLURM Jobs",
                  "type": "row"
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
                        "fillOpacity": 10,
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
                        "showPoints": "never",
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
                      "min": 0,
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
                    "h": 11,
                    "w": 12,
                    "x": 0,
                    "y": 21
                  },
                  "id": 2,
                  "options": {
                    "legend": {
                      "calcs": [
                        "mean",
                        "lastNotNull",
                        "max",
                        "min"
                      ],
                      "displayMode": "table",
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
                      "expr": "slurm_queue_completing != 0",
                      "format": "time_series",
                      "interval": "",
                      "intervalFactor": 2,
                      "legendFormat": "Completing Jobs",
                      "refId": "A"
                    },
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "expr": "slurm_queue_running",
                      "format": "time_series",
                      "intervalFactor": 2,
                      "legendFormat": "Running Jobs",
                      "refId": "B"
                    },
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "expr": "slurm_queue_pending",
                      "format": "time_series",
                      "intervalFactor": 2,
                      "legendFormat": "Pending Jobs",
                      "refId": "C"
                    },
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "expr": "slurm_queue_completed != 0",
                      "format": "time_series",
                      "interval": "",
                      "intervalFactor": 2,
                      "legendFormat": "Completed Jobs",
                      "refId": "D"
                    }
                  ],
                  "title": "RUNNING/COMPL/PEND Jobs",
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
                        "fillOpacity": 10,
                        "gradientMode": "none",
                        "hideFrom": {
                          "legend": false,
                          "tooltip": false,
                          "viz": false
                        },
                        "insertNulls": false,
                        "lineInterpolation": "linear",
                        "lineWidth": 2,
                        "pointSize": 5,
                        "scaleDistribution": {
                          "type": "linear"
                        },
                        "showPoints": "never",
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
                      "min": 0,
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
                    "overrides": [
                      {
                        "matcher": {
                          "id": "byName",
                          "options": "Timed out Jobs"
                        },
                        "properties": [
                          {
                            "id": "color",
                            "value": {
                              "fixedColor": "#890f02",
                              "mode": "fixed"
                            }
                          }
                        ]
                      }
                    ]
                  },
                  "gridPos": {
                    "h": 11,
                    "w": 12,
                    "x": 12,
                    "y": 21
                  },
                  "id": 6,
                  "options": {
                    "legend": {
                      "calcs": [
                        "mean",
                        "lastNotNull",
                        "max",
                        "min"
                      ],
                      "displayMode": "table",
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
                      "expr": "slurm_queue_timeout",
                      "format": "time_series",
                      "intervalFactor": 2,
                      "legendFormat": "Timed out Jobs",
                      "refId": "A"
                    },
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "expr": "slurm_queue_failed",
                      "format": "time_series",
                      "instant": false,
                      "intervalFactor": 2,
                      "legendFormat": "Failed Jobs",
                      "refId": "B"
                    },
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "expr": "slurm_queue_node_fail",
                      "format": "time_series",
                      "intervalFactor": 2,
                      "legendFormat": "Failed jobs (due to NodeFail)",
                      "refId": "C"
                    },
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "expr": "slurm_queue_suspended",
                      "format": "time_series",
                      "intervalFactor": 2,
                      "legendFormat": "Suspended Jobs",
                      "refId": "D"
                    },
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "expr": "slurm_queue_cancelled",
                      "format": "time_series",
                      "intervalFactor": 2,
                      "legendFormat": "Cancelled Jobs",
                      "refId": "E"
                    },
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "expr": "slurm_queue_preempted",
                      "format": "time_series",
                      "intervalFactor": 2,
                      "legendFormat": "Preempted Jobs",
                      "refId": "F"
                    }
                  ],
                  "title": "FAIL/SUSP/CANC/PREEMPT/TIMEDOUT Jobs",
                  "type": "timeseries"
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
                    "y": 32
                  },
                  "id": 14,
                  "panels": [],
                  "targets": [
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "refId": "A"
                    }
                  ],
                  "title": "CPU cores allocation",
                  "type": "row"
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
                        "fillOpacity": 10,
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
                        "showPoints": "never",
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
                      "min": 0,
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
                    "overrides": [
                      {
                        "matcher": {
                          "id": "byName",
                          "options": "slurm_alloc_cpu_cores{cluster=\"kronos\",job=\"kronos_cores\"}"
                        },
                        "properties": [
                          {
                            "id": "color",
                            "value": {
                              "fixedColor": "#ea6460",
                              "mode": "fixed"
                            }
                          }
                        ]
                      },
                      {
                        "matcher": {
                          "id": "byName",
                          "options": "slurm_cpu_cores_total{cluster=\"kronos\",job=\"kronos_cores\"}"
                        },
                        "properties": [
                          {
                            "id": "color",
                            "value": {
                              "fixedColor": "#052b51",
                              "mode": "fixed"
                            }
                          }
                        ]
                      },
                      {
                        "matcher": {
                          "id": "byName",
                          "options": "slurm_idle_cpu_cores{cluster=\"kronos\",job=\"kronos_cores\"}"
                        },
                        "properties": [
                          {
                            "id": "color",
                            "value": {
                              "fixedColor": "#f2c96d",
                              "mode": "fixed"
                            }
                          }
                        ]
                      }
                    ]
                  },
                  "gridPos": {
                    "h": 9,
                    "w": 24,
                    "x": 0,
                    "y": 33
                  },
                  "id": 10,
                  "options": {
                    "legend": {
                      "calcs": [
                        "mean",
                        "lastNotNull",
                        "max",
                        "min"
                      ],
                      "displayMode": "table",
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
                      "expr": "slurm_cpus_total",
                      "format": "time_series",
                      "intervalFactor": 2,
                      "legendFormat": "Total number of CPU cores",
                      "refId": "B"
                    },
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "expr": "slurm_cpus_alloc",
                      "format": "time_series",
                      "intervalFactor": 2,
                      "legendFormat": "Allocated CPU cores",
                      "refId": "A"
                    },
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "expr": "slurm_cpus_idle",
                      "format": "time_series",
                      "hide": true,
                      "interval": "",
                      "intervalFactor": 2,
                      "legendFormat": "Idle CPU cores",
                      "refId": "C"
                    }
                  ],
                  "title": "CPU Allocation",
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
                        "fillOpacity": 10,
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
                        "showPoints": "never",
                        "spanNulls": false,
                        "stacking": {
                          "group": "A",
                          "mode": "normal"
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
                    "overrides": [
                      {
                        "matcher": {
                          "id": "byName",
                          "options": "debug"
                        },
                        "properties": [
                          {
                            "id": "color",
                            "value": {
                              "fixedColor": "super-light-purple",
                              "mode": "fixed"
                            }
                          }
                        ]
                      },
                      {
                        "matcher": {
                          "id": "byValue",
                          "options": {
                            "op": "gte",
                            "reducer": "allIsZero",
                            "value": 0
                          }
                        },
                        "properties": [
                          {
                            "id": "custom.hideFrom",
                            "value": {
                              "legend": true,
                              "tooltip": true,
                              "viz": false
                            }
                          }
                        ]
                      },
                      {
                        "matcher": {
                          "id": "byValue",
                          "options": {
                            "op": "gte",
                            "reducer": "allIsNull",
                            "value": 0
                          }
                        },
                        "properties": [
                          {
                            "id": "custom.hideFrom",
                            "value": {
                              "legend": true,
                              "tooltip": true,
                              "viz": false
                            }
                          }
                        ]
                      }
                    ]
                  },
                  "gridPos": {
                    "h": 8,
                    "w": 12,
                    "x": 0,
                    "y": 42
                  },
                  "id": 48,
                  "options": {
                    "legend": {
                      "calcs": [
                        "mean",
                        "lastNotNull"
                      ],
                      "displayMode": "table",
                      "placement": "right",
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
                      "expr": "slurm_partition_cpus_allocated != 0",
                      "interval": "",
                      "legendFormat": "{{partition}}",
                      "refId": "A"
                    }
                  ],
                  "title": "CPUs Allocated per Partition",
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
                        "fillOpacity": 10,
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
                        "showPoints": "never",
                        "spanNulls": false,
                        "stacking": {
                          "group": "A",
                          "mode": "normal"
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
                    "y": 42
                  },
                  "id": 50,
                  "options": {
                    "legend": {
                      "calcs": [
                        "mean",
                        "lastNotNull"
                      ],
                      "displayMode": "table",
                      "placement": "right",
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
                      "expr": "slurm_partition_cpus_idle",
                      "interval": "",
                      "legendFormat": "{{partition}}",
                      "refId": "A"
                    }
                  ],
                  "title": "CPUs Idle per Partition",
                  "type": "timeseries"
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
                    "y": 50
                  },
                  "id": 15,
                  "panels": [],
                  "targets": [
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "refId": "A"
                    }
                  ],
                  "title": "SLURM Scheduler Details",
                  "type": "row"
                },
                {
                  "datasource": {
                    "type": "prometheus",
                    "uid": "prometheus"
                  },
                  "description": "The number of current active slurmctld threads.",
                  "fieldConfig": {
                    "defaults": {
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
                      "unit": "none"
                    },
                    "overrides": []
                  },
                  "gridPos": {
                    "h": 5,
                    "w": 8,
                    "x": 0,
                    "y": 51
                  },
                  "id": 7,
                  "maxDataPoints": 100,
                  "options": {
                    "colorMode": "none",
                    "graphMode": "none",
                    "justifyMode": "auto",
                    "orientation": "horizontal",
                    "percentChangeColorMode": "standard",
                    "reduceOptions": {
                      "calcs": [
                        "lastNotNull"
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
                      "expr": "slurm_scheduler_threads",
                      "format": "time_series",
                      "intervalFactor": 2,
                      "legendFormat": "Slurm Scheduler Threads",
                      "refId": "A"
                    }
                  ],
                  "title": "Slurm Scheduler Threads",
                  "type": "stat"
                },
                {
                  "datasource": {
                    "type": "prometheus",
                    "uid": "prometheus"
                  },
                  "description": "The agent mechanism helps to control communication between the Slrum daemons and the controller for a best effort.",
                  "fieldConfig": {
                    "defaults": {
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
                      "unit": "none"
                    },
                    "overrides": []
                  },
                  "gridPos": {
                    "h": 5,
                    "w": 8,
                    "x": 8,
                    "y": 51
                  },
                  "id": 8,
                  "maxDataPoints": 100,
                  "options": {
                    "colorMode": "none",
                    "graphMode": "none",
                    "justifyMode": "auto",
                    "orientation": "horizontal",
                    "percentChangeColorMode": "standard",
                    "reduceOptions": {
                      "calcs": [
                        "lastNotNull"
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
                      "expr": "slurm_scheduler_queue_size",
                      "format": "time_series",
                      "intervalFactor": 2,
                      "legendFormat": "Agent Queue Size",
                      "refId": "A"
                    }
                  ],
                  "title": "Agent Queue Size",
                  "type": "stat"
                },
                {
                  "datasource": {
                    "type": "prometheus",
                    "uid": "prometheus"
                  },
                  "fieldConfig": {
                    "defaults": {
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
                            "value": 100
                          }
                        ]
                      },
                      "unit": "none"
                    },
                    "overrides": []
                  },
                  "gridPos": {
                    "h": 5,
                    "w": 8,
                    "x": 16,
                    "y": 51
                  },
                  "id": 26,
                  "options": {
                    "minVizHeight": 75,
                    "minVizWidth": 75,
                    "orientation": "auto",
                    "reduceOptions": {
                      "calcs": [
                        "last"
                      ],
                      "fields": "",
                      "values": false
                    },
                    "showThresholdLabels": false,
                    "showThresholdMarkers": true,
                    "sizing": "auto"
                  },
                  "pluginVersion": "11.1.0",
                  "targets": [
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "expr": "slurm_scheduler_dbd_queue_size",
                      "legendFormat": "DBD Agent Queue length",
                      "refId": "A"
                    }
                  ],
                  "title": "DBD Agent Queue Length",
                  "type": "gauge"
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
                    "y": 56
                  },
                  "id": 16,
                  "panels": [],
                  "targets": [
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "refId": "A"
                    }
                  ],
                  "title": "SLURM Scheduler Cycles",
                  "type": "row"
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
                        "fillOpacity": 10,
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
                        "showPoints": "never",
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
                      "unit": "µs"
                    },
                    "overrides": []
                  },
                  "gridPos": {
                    "h": 7,
                    "w": 12,
                    "x": 0,
                    "y": 57
                  },
                  "id": 4,
                  "options": {
                    "legend": {
                      "calcs": [
                        "mean",
                        "min"
                      ],
                      "displayMode": "table",
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
                      "expr": "slurm_scheduler_last_cycle",
                      "format": "time_series",
                      "intervalFactor": 2,
                      "legendFormat": "Scheduler Last Cycle Time",
                      "refId": "A"
                    },
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "expr": "slurm_scheduler_mean_cycle",
                      "format": "time_series",
                      "intervalFactor": 2,
                      "legendFormat": "Scheduler Mean Cycle Time",
                      "refId": "B"
                    }
                  ],
                  "title": "Scheduler Cycles",
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
                        "fillOpacity": 10,
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
                        "showPoints": "never",
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
                      "unit": "µs"
                    },
                    "overrides": []
                  },
                  "gridPos": {
                    "h": 7,
                    "w": 12,
                    "x": 12,
                    "y": 57
                  },
                  "id": 3,
                  "options": {
                    "legend": {
                      "calcs": [
                        "mean",
                        "lastNotNull",
                        "max",
                        "min"
                      ],
                      "displayMode": "table",
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
                      "expr": "slurm_scheduler_backfill_last_cycle",
                      "format": "time_series",
                      "intervalFactor": 2,
                      "legendFormat": "Scheduler Backfill Last Cycle",
                      "refId": "A"
                    },
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "expr": "slurm_scheduler_backfill_mean_cycle",
                      "format": "time_series",
                      "intervalFactor": 2,
                      "legendFormat": "Scheduler Backfill Mean Cycle",
                      "refId": "B"
                    }
                  ],
                  "title": "Backfill Scheduler Cycles",
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
                        "fillOpacity": 10,
                        "gradientMode": "none",
                        "hideFrom": {
                          "legend": false,
                          "tooltip": false,
                          "viz": false
                        },
                        "insertNulls": false,
                        "lineInterpolation": "linear",
                        "lineWidth": 2,
                        "pointSize": 5,
                        "scaleDistribution": {
                          "type": "linear"
                        },
                        "showPoints": "never",
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
                      "unit": "short"
                    },
                    "overrides": []
                  },
                  "gridPos": {
                    "h": 6,
                    "w": 12,
                    "x": 0,
                    "y": 64
                  },
                  "id": 9,
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
                      "expr": "slurm_scheduler_backfill_depth_mean",
                      "format": "time_series",
                      "intervalFactor": 2,
                      "legendFormat": "Mean of processed jobs during backfilling scheduling cycles",
                      "refId": "A"
                    }
                  ],
                  "title": "Scheduler Backfill Depth Mean",
                  "type": "timeseries"
                },
                {
                  "datasource": {
                    "type": "prometheus",
                    "uid": "prometheus"
                  },
                  "description": "Number of heterogeneous job components started thanks to backfilling since last Slurm start",
                  "fieldConfig": {
                    "defaults": {
                      "displayName": "",
                      "mappings": [
                        {
                          "id": 0,
                          "op": "=",
                          "text": "N/A",
                          "type": 1,
                          "value": "null"
                        }
                      ],
                      "thresholds": {
                        "mode": "absolute",
                        "steps": [
                          {
                            "color": "green",
                            "value": null
                          }
                        ]
                      },
                      "unit": "short"
                    },
                    "overrides": []
                  },
                  "gridPos": {
                    "h": 6,
                    "w": 6,
                    "x": 12,
                    "y": 64
                  },
                  "id": 34,
                  "options": {
                    "minVizHeight": 75,
                    "minVizWidth": 75,
                    "orientation": "horizontal",
                    "reduceOptions": {
                      "calcs": [
                        "last"
                      ],
                      "fields": "",
                      "values": false
                    },
                    "showThresholdLabels": false,
                    "showThresholdMarkers": true,
                    "sizing": "auto"
                  },
                  "pluginVersion": "11.1.0",
                  "targets": [
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "expr": "slurm_scheduler_backfilled_heterogeneous_total",
                      "legendFormat": "Heterogeneous job components",
                      "refId": "A"
                    }
                  ],
                  "title": " Total backfilled heterogeneous Job components",
                  "type": "gauge"
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
                    "y": 70
                  },
                  "id": 32,
                  "panels": [],
                  "targets": [
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "refId": "A"
                    }
                  ],
                  "title": "Total Backfilled Jobs",
                  "type": "row"
                },
                {
                  "datasource": {
                    "type": "prometheus",
                    "uid": "prometheus"
                  },
                  "description": "Number of jobs started thanks to backfilling since last Slurm start.",
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
                        "fillOpacity": 10,
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
                        "showPoints": "never",
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
                      "unit": "short"
                    },
                    "overrides": [
                      {
                        "matcher": {
                          "id": "byName",
                          "options": "DELTA: Total number Backfilled Jobs (since last Slurm start)"
                        },
                        "properties": [
                          {
                            "id": "custom.axisPlacement",
                            "value": "right"
                          }
                        ]
                      }
                    ]
                  },
                  "gridPos": {
                    "h": 7,
                    "w": 12,
                    "x": 0,
                    "y": 71
                  },
                  "id": 28,
                  "options": {
                    "legend": {
                      "calcs": [
                        "lastNotNull"
                      ],
                      "displayMode": "table",
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
                      "expr": "delta(slurm_scheduler_backfilled_jobs_since_start_total[10m])",
                      "legendFormat": "DELTA: Total number Backfilled Jobs (since last Slurm start)",
                      "refId": "A"
                    },
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "expr": "slurm_scheduler_backfilled_jobs_since_start_total",
                      "legendFormat": "Total number Backfilled Jobs (since last Slurm start)",
                      "refId": "B"
                    }
                  ],
                  "title": "Total Backfilled Jobs (since last slurm start)",
                  "type": "timeseries"
                },
                {
                  "datasource": {
                    "type": "prometheus",
                    "uid": "prometheus"
                  },
                  "description": "Number of jobs started thanks to backfilling since last time stats where reset",
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
                        "fillOpacity": 10,
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
                        "showPoints": "never",
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
                      "unit": "short"
                    },
                    "overrides": [
                      {
                        "matcher": {
                          "id": "byName",
                          "options": "DELTA:  Total Backfilled Jobs (since last stats cycle start)"
                        },
                        "properties": [
                          {
                            "id": "custom.axisPlacement",
                            "value": "right"
                          }
                        ]
                      }
                    ]
                  },
                  "gridPos": {
                    "h": 7,
                    "w": 12,
                    "x": 12,
                    "y": 71
                  },
                  "id": 30,
                  "options": {
                    "legend": {
                      "calcs": [
                        "lastNotNull"
                      ],
                      "displayMode": "table",
                      "placement": "bottom",
                      "showLegend": true
                    },
                    "tooltip": {
                      "mode": "multi",
                      "sort": "none"
                    }
                  },
                  "pluginVersion": "6.6.2",
                  "targets": [
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "expr": "slurm_scheduler_backfilled_jobs_since_cycle_total",
                      "legendFormat": " Total Backfilled Jobs (since last stats cycle start)",
                      "refId": "A"
                    },
                    {
                      "datasource": {
                        "type": "prometheus",
                        "uid": "prometheus"
                      },
                      "expr": "delta(slurm_scheduler_backfilled_jobs_since_cycle_total[10m])",
                      "legendFormat": "DELTA:  Total Backfilled Jobs (since last stats cycle start)",
                      "refId": "B"
                    }
                  ],
                  "title": "Total Backfilled Jobs (since last stats cycle start)",
                  "type": "timeseries"
                }
              ],
              "refresh": "30s",
              "schemaVersion": 39,
              "tags": [
                "Slurm"
              ],
              "templating": {
                "list": []
              },
              "time": {
                "from": "now-24h",
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
              "timezone": "",
              "title": "SLURM Dashboard",
              "uid": "bX7jn6dZkuytdD",
              "version": 1,
              "weekStart": ""
            }
        kind: ConfigMap
        metadata:
          labels:
            grafana_dashboard: "1"
          name: slurm-slurm-exporter
          namespace: ${local.monitoring_namespace}
    EOF
  ]
}
