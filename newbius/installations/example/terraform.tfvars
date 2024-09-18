#----------------------------------------------------------------------------------------------------------------------#
#                                                                                                                      #
#                                                                                                                      #
#                                              Terraform - example values                                              #
#                                                                                                                      #
#                                                                                                                      #
#----------------------------------------------------------------------------------------------------------------------#

#----------------------------------------------------------------------------------------------------------------------#
#                                                                                                                      #
#                                                                                                                      #
#                                                         Cloud                                                        #
#                                                                                                                      #
#                                                                                                                      #
#----------------------------------------------------------------------------------------------------------------------#
# region Cloud

# IAM token used for communicating with Nebius services.
# Token is being passed via .envrc file.
# Uncomment to override.
# ---
# iam_token = "<YOUR-IAM-TOKEN>"

# ID of the IAM project.
# Project ID is being passed via .envrc file.
# Uncomment to override.
# ---
# iam_project_id = "project-<YOUR-PROJECT-ID>"

# ID of VPC subnet.
# Subnet ID is being passed via .envrc file.
# Uncomment to override.
# ---
#vpc_subnet_id = "vpcsubnet-<YOUR-SUBNET-ID>"

# endregion Cloud

#----------------------------------------------------------------------------------------------------------------------#
#                                                                                                                      #
#                                                                                                                      #
#                                                    Infrastructure                                                    #
#                                                                                                                      #
#                                                                                                                      #
#----------------------------------------------------------------------------------------------------------------------#
# region Infrastructure

#----------------------------------------------------------------------------------------------------------------------#
#                                                                                                                      #
#                                                        Storage                                                       #
#                                                                                                                      #
#----------------------------------------------------------------------------------------------------------------------#
# region Storage

# Shared filesystem to be used on controller nodes.
# ---
filestore_controller_spool = {
  size_gibibytes       = 128
  block_size_kibibytes = 4
}

# Shared filesystem to be used on controller, worker, and login nodes.
# ---
filestore_jail = {
  size_gibibytes       = 2048
  block_size_kibibytes = 4
}

# Shared filesystems to be mounted inside jail.
# ---
filestore_jail_submounts = [{
  name                 = "mlperf-sd"
  size_gibibytes       = 2048
  block_size_kibibytes = 4
  mount_path           = "/mlperf-sd"
}]

# endregion Storage

#----------------------------------------------------------------------------------------------------------------------#
#                                                                                                                      #
#                                                      Kubernetes                                                      #
#                                                                                                                      #
#----------------------------------------------------------------------------------------------------------------------#
# region k8s

# Version of the k8s to be used.
# ---
# k8s_version = "1.30"

# Name of the k8s cluster.
# ---
k8s_cluster_name = "slurm-k8s"

# CPU-only node group specification.
# Look at https://docs.nebius.ai/compute/virtual-machines/types/#cpu-configurations to choose the preset.
# ---
k8s_cluster_node_group_cpu = {
  resource = {
    platform = "cpu-e2"
    preset   = "16vcpu-64gb"
  }
  boot_disk = {
    type           = "NETWORK_SSD"
    size_gibibytes = 128
  }
}

# GPU node group specification.
# Look at https://docs.nebius.ai/compute/virtual-machines/types/#gpu-configurations to choose the preset.
# ---
k8s_cluster_node_group_gpu = {
  resource = {
    platform = "gpu-h100-sxm"
    preset   = "8gpu-128vcpu-1600gb"
  }
  boot_disk = {
    type           = "NETWORK_SSD"
    size_gibibytes = 1024
  }
  gpu_cluster = {
    infiniband_fabric = "fabric-2"
  }
}

# endregion k8s

# endregion Infrastructure

#----------------------------------------------------------------------------------------------------------------------#
#                                                                                                                      #
#                                                                                                                      #
#                                                         Slurm                                                        #
#                                                                                                                      #
#                                                                                                                      #
#----------------------------------------------------------------------------------------------------------------------#
# region Slurm

# Name of the Slurm cluster in k8s cluster.
# ---
slurm_cluster_name = "my-amazing-slurm"

# Version of soperator.
# ---
slurm_operator_version = "1.13.5"

#----------------------------------------------------------------------------------------------------------------------#
#                                                                                                                      #
#                                                         Nodes                                                        #
#                                                                                                                      #
#----------------------------------------------------------------------------------------------------------------------#
# region Nodes

# Count of Slurm nodes.
# ---
slurm_node_count = {
  controller = 2
  worker     = 2
}

#----------------------------------------------------------------------------------------------------------------------#
#                                                         Login                                                        #
#----------------------------------------------------------------------------------------------------------------------#
# region Login

# Type of the k8s service to connect to login nodes.
# Could be either "LoadBalancer" or "NodePort".
# ---
slurm_login_service_type = "NodePort"

# Port of the host to be opened in case of use of `NodePort` service type.
# By default, 30022.
# ---
# slurm_login_node_port = 30022

# Authorized keys accepted for connecting to Slurm login nodes via SSH as 'root' user.
# ---
slurm_login_ssh_root_public_keys = [
  "ENCRYPTION-METHOD HASH USER",
]

# endregion Login

#----------------------------------------------------------------------------------------------------------------------#
#                                                       Exporter                                                       #
#----------------------------------------------------------------------------------------------------------------------#
# region Exporter

# Whether to enable Slurm metrics exporter.
# By default, true.
# ---
# slurm_exporter_enabled = false

# endregion Exporter

# endregion Nodes

#----------------------------------------------------------------------------------------------------------------------#
#                                                                                                                      #
#                                                        Config                                                        #
#                                                                                                                      #
#----------------------------------------------------------------------------------------------------------------------#
# region Config

# Shared memory size for Slurm controller and worker nodes in GiB.
# By default, 64.
# ---
# slurm_shared_memory_size_gibibytes = 64

# endregion Config

#----------------------------------------------------------------------------------------------------------------------#
#                                                                                                                      #
#                                                    NCCL benchmark                                                    #
#                                                                                                                      #
#----------------------------------------------------------------------------------------------------------------------#
# region NCCL benchmark

# Whether to enable NCCL benchmark CronJob to benchmark GPU performance.
# It won't take effect in case of 1-GPU hosts.
# By default, true.
# ---
# nccl_benchmark_enable = false

# NCCL benchmark's CronJob schedule.
# By default, `0 */3 * * *` - every 3 hour.
# ---
# nccl_benchmark_enable = "0 */3 * * *"

# Minimal threshold of NCCL benchmark for GPU performance to be considered as acceptable.
# By default, 420.
# ---
# nccl_benchmark_min_threshold = 420

# endregion NCCL benchmark

#----------------------------------------------------------------------------------------------------------------------#
#                                                                                                                      #
#                                                       Telemetry                                                      #
#                                                                                                                      #
#----------------------------------------------------------------------------------------------------------------------#
# region Telemetry

# Whether to enable Open Telemetry collector.
# By default, true.
# ---
# telemetry_enable_otel_collector = false

# Whether to enable Prometheus.
# By default, true.
# ---
# telemetry_enable_prometheus = false

# Whether to send job events.
# By default, true.
# ---
# telemetry_send_job_events = false

# Whether to send Open Telemetry metrics.
# By default, true.
# ---
# telemetry_send_otel_metrics = false

# endregion Telemetry

# endregion Slurm
