# region endpoint

variable "endpoint_nebius" {
  description = "API endpoint for Nebius provider."
  type        = string
  nullable    = false
  default     = "api.eu-north1.nebius.cloud:443"
}

# endregion endpoint

# region iam

variable "iam_token" {
  description = "IAM token used for communicating with Nebius services."
  type        = string
  nullable    = false
  sensitive   = true
}

variable "iam_project_id" {
  description = "ID of the IAM project."
  type        = string
  nullable    = false

  validation {
    condition     = startswith(var.iam_project_id, "project-")
    error_message = "ID of the IAM project must start with `project-`."
  }
}
data "nebius_iam_v1_project" "this" {
  id = var.iam_project_id
}

# endregion iam

# region vpc

variable "vpc_subnet_id" {
  description = "ID of VPC subnet."
  type        = string

  validation {
    condition     = startswith(var.vpc_subnet_id, "vpcsubnet-")
    error_message = "The ID of the VPC subnet must start with `vpcsubnet-`."
  }
}
data "nebius_vpc_v1_subnet" "this" {
  id = var.vpc_subnet_id
}

# endregion vpc
