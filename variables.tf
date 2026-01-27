# High Level AWS Variables
variable "region" {
  description = "The primary AWS region to deploy resources to"
  type        = string
  default     = "eu-west-2"
}

variable "aws_partition" {
  description = "AWS partition to use for ARNs and policies"
  type        = string
  default     = "aws"
}

# High Level Databricks Variables
variable "databricks_account_id" {
  description = "ID of the Databricks account to deploy to."
  type        = string
  sensitive   = true
}

variable "databricks_metastore_id" {
  description = "ID of the Databricks metastore for the current cloud region and Databricks account"
  type        = string
  default     = null
}

variable "databricks_admin_workspace_host" {
  description = "URL of the admin Databricks workspace for the portfolio"
  type        = string
  default     = null
}

variable "workspace_config" {
  description = "REST API PrivateLink Endpoint configuration"
  type = map(object({
    primary_endpoint = string
  }))
  default = {
    "eu-west-1" = {
      primary_endpoint = "com.amazonaws.vpce.eu-west-1.vpce-svc-0da6ebf1461278016"
    }
    "eu-west-2" = {
      primary_endpoint = "com.amazonaws.vpce.eu-west-2.vpce-svc-01148c7cdc1d1326c"
    }
  }
}

variable "scc_relay_config" {
  description = "Secure Cluster Connectivity Relay configuration"
  type = map(object({
    primary_endpoint = string
  }))
  default = {
    "eu-west-1" = {
      primary_endpoint = "com.amazonaws.vpce.eu-west-1.vpce-svc-09b4eb2bc775f4e8c"
    }
    "eu-west-2" = {
      primary_endpoint = "com.amazonaws.vpce.eu-west-2.vpce-svc-05279412bf5353a45"
    }
  }
}

# Customer-managed VPC Networking Configuration
variable "vpc_id" {
  description = "Custom VPC ID"
  type        = string
  default     = null
}

variable "private_backend_subnet_config" {
  description = "List of custom private subnet IDs"
  type = map(object({
    cidr = string
    az   = string
  }))
  default = null
}

variable "private_route_table_id" {
  description = "ID of the private route table to associate the backend PrivateLink endpoint subnets with"
  type        = string
  default     = null
}

variable "sg_egress_ports" {
  description = "List of egress ports for security groups."
  type        = list(string)
  nullable    = true
  default     = [null]
}

variable "cmk_admin_arn" {
  description = "Amazon Resource Name (ARN) of the CMK admin."
  type        = string
  default     = null
}

# Common variables to be applied to a large number of resources
variable "resource_prefix" {
  description = "Prefix for the resource names."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-.]{1,26}$", var.resource_prefix))
    error_message = "Invalid resource prefix. Allowed 40 characters containing only a-z, 0-9, -, ."
  }
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

# Unity Catalog and Permissions
variable "uc_catalog_name" {
  description = "UC catalog name."
  type        = string
}

variable "unity_catalog_iam_arn" {
  type        = string
  description = "Unity Catalog IAM ARN for the master role"
  default     = "arn:aws:iam::414351767826:role/unity-catalog-prod-UCMasterRole-14S5ZJVKOTYTL"
}
