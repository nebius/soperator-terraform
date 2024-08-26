# Slurm Development Clusters

This directory includes files with Terraform variables for Slurm clusters we use for development.

The corresponding Terraform states are stored on [S3](
https://console.nebius.ai/folders/bje82q7sm8njm3c4rrlq/storage/buckets/terraform-state-slurm?key=env%3A%2F).

All clusters are named after [Futurama characters](https://futurama.fandom.com/wiki/Characters).

The chosen names may have some sense. For example, the **H**ermes cluster has **H**100 GPUs, while the **A**my cluster 
has **A**100s.

All entities related to a specific cluster should be named the same: K8s cluster, Slurm cluster, Terraform workspace, 
etc.

You can use the [tfoldbius.sh](../tfoldbius.sh) script in order to interact with them via Terraform.
