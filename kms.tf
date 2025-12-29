# ==============================================================================
# KMS for UC catalog
# ==============================================================================

resource "aws_kms_key" "catalog_storage" {
  description = "KMS key for Databricks catalog storage ${var.resource_prefix}"
  policy = jsonencode({
    Version : "2012-10-17",
    "Id" : "key-policy-catalog-storage-${var.resource_prefix}",
    Statement : [
      {
        "Sid" : "Enable IAM User Permissions",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : [local.cmk_admin_value]
        },
        "Action" : "kms:*",
        "Resource" : "*"
      },
      {
        "Sid" : "Allow IAM Role to use the key",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${local.aws_account_id}:role/${local.uc_iam_role}"
        },
        "Action" : [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey*"
        ],
        "Resource" : "*"
      }
    ]
  })
  tags = merge(
    var.tags,
    {
      Name = "${var.resource_prefix}-catalog-storage-key"
    }
  )
}

resource "aws_kms_alias" "catalog_storage_key_alias" {
  name          = "alias/${var.resource_prefix}-catalog-storage-key"
  target_key_id = aws_kms_key.catalog_storage.id
}

# ==============================================================================
# KMS for Databricks Managed Services
# ==============================================================================

resource "aws_kms_key" "databricks_managed_services" {
  description = "KMS key for managed services"
  policy = jsonencode({ Version : "2012-10-17",
    "Id" : "key-policy-managed-services",
    Statement : [
      {
        "Sid" : "Enable IAM User Permissions",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : [local.cmk_admin_value]
        },
        "Action" : "kms:*",
        "Resource" : "*"
      },
      {
        "Sid" : "Allow Databricks to use KMS key for managed services in the control plane",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${local.databricks_aws_account_id}:root"
        },
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt"
        ],
        "Resource" : "*",
        "Condition" : {
          "StringEquals" : {
            "aws:PrincipalTag/DatabricksAccountId" : [var.databricks_account_id]
          }
        }
      }
    ]
    }
  )

  tags = merge(
    var.tags,
    {
      Name = "${var.resource_prefix}-managed-services-key"
    }
  )
}

resource "aws_kms_alias" "databricks_managed_services_key_alias" {
  name          = "alias/${var.resource_prefix}-managed-services-key"
  target_key_id = aws_kms_key.databricks_managed_services.key_id
}

resource "databricks_mws_customer_managed_keys" "managed_services" {
  provider   = databricks.mws
  account_id = var.databricks_account_id
  aws_key_info {
    key_arn   = aws_kms_key.databricks_managed_services.arn
    key_alias = aws_kms_alias.databricks_managed_services_key_alias.name
  }
  use_cases = ["MANAGED_SERVICES"]
}

# ==============================================================================
# KMS for Databricks Workspace Storage
# ==============================================================================

resource "aws_kms_key" "databricks_workspace_storage" {
  description = "KMS key for databricks workspace storage"
  policy = jsonencode({
    Version : "2012-10-17",
    "Id" : "key-policy-workspace-storage",
    Statement : [
      {
        "Sid" : "Enable IAM User Permissions",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : [local.cmk_admin_value]
        },
        "Action" : "kms:*",
        "Resource" : "*"
      },
      {
        "Sid" : "Allow Databricks to use KMS key for DBFS",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${local.databricks_aws_account_id}:root"
        },
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        "Resource" : "*",
        "Condition" : {
          "StringEquals" : {
            "aws:PrincipalTag/DatabricksAccountId" : [var.databricks_account_id]
          }
        }
      },
      {
        "Sid" : "Allow Databricks to use KMS key for EBS",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : aws_iam_role.cross_account_role.arn
        },
        "Action" : [
          "kms:Decrypt",
          "kms:GenerateDataKey*",
          "kms:CreateGrant",
          "kms:DescribeKey"
        ],
        "Resource" : "*",
        "Condition" : {
          "ForAnyValue:StringLike" : {
            "kms:ViaService" : "ec2.*.amazonaws.com"
          }
        }
      }
    ]
  })
  depends_on = [aws_iam_role.cross_account_role]

  tags = merge(
    var.tags,
    {
      Name = "${var.resource_prefix}-workspace-storage-key"
    }
  )
}

resource "aws_kms_alias" "databricks_workspace_storage_key_alias" {
  name          = "alias/${var.resource_prefix}-workspace-storage-key"
  target_key_id = aws_kms_key.databricks_workspace_storage.id
}

resource "databricks_mws_customer_managed_keys" "workspace_storage" {
  provider   = databricks.mws
  account_id = var.databricks_account_id
  aws_key_info {
    key_arn   = aws_kms_key.databricks_workspace_storage.arn
    key_alias = aws_kms_alias.databricks_workspace_storage_key_alias.name
  }
  use_cases = ["STORAGE"]
}
