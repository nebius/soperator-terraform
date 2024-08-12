# region endpoint

variable "endpoint_nebius" {
  description = "API endpoint for Nebius provider."
  type        = string
  nullable    = false
  default     = "api.eu-north1.nebius.cloud:443"
}

variable "endpoint_s3" {
  description = "Endpoint for S3 backend."
  type        = string
  nullable    = false
  default     = "https://storage.eu-north1.nebius.cloud:443"
}

# endregion endpoint

# region iam

variable "iam_token" {
  description = "Token for IAM authentication."
  type        = string
  sensitive   = true
  nullable    = false

  validation {
    condition     = length(var.iam_token) > 0
    error_message = "IAM token must be passed."
  }
}

variable "iam_project_id" {
  description = "Project ID."
  type        = string
  nullable    = false

  validation {
    condition     = startswith(var.iam_project_id, "project-")
    error_message = "The ID of the IAM project must start with `project-`."
  }
}
data "nebius_iam_v1_project" "this" {
  id = var.iam_project_id
}

# endregion iam
