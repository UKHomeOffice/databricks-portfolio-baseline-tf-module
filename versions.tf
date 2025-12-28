terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.84"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.24.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">=3.2.3"
    }
    time = {
      source  = "hashicorp/time"
      version = ">=0.12.1"
    }
  }
  required_version = ">= 1.5.0"
}

# Authenticate using environment variables: https://docs.aws.amazon.com/cli/v1/userguide/cli-configure-envvars.html
# export AWS_ACCESS_KEY_ID=KEY_ID
# export AWS_SECRET_ACCESS_KEY=SECRET_KEY
# export AWS_SESSION_TOKEN=SESSION_TOKEN

provider "aws" {
  region = var.region
}

# Authenticate using environment variables: https://registry.terraform.io/providers/databricks/databricks/latest/docs#argument-reference
# export DATABRICKS_CLIENT_ID=CLIENT_ID
# export DATABRICKS_CLIENT_SECRET=CLIENT_SECRET

provider "databricks" {
  alias      = "mws"
  host       = local.databricks_provider_host
  account_id = var.databricks_account_id
}

provider "databricks" {
  alias      = "created_workspace"
  host       = databricks_mws_workspaces.admin.workspace_url
  account_id = var.databricks_account_id
}
