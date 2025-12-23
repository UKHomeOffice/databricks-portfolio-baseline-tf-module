# ==============================================================================
# KMS
# ==============================================================================

resource "aws_kms_key" "databricks_unity_catalog" {
  enable_key_rotation = true
  tags                = local.common_tags
}

resource "aws_kms_alias" "databricks_unity_catalog" {
  name          = "alias/databricks/unity-catalog"
  target_key_id = aws_kms_key.databricks_unity_catalog.key_id
}

data "aws_iam_policy_document" "databricks_managed_services_cmk" {
  version = "2012-10-17"
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.account_id]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }
  statement {
    sid    = "Allow Databricks to use KMS key for control plane managed services"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::414351767826:root"]
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt"
    ]
    resources = ["*"]
  }
}

resource "aws_kms_key" "databricks_managed_services_key" {
  policy = data.aws_iam_policy_document.databricks_managed_services_cmk.json
  tags   = local.common_tags
}

resource "aws_kms_alias" "databricks_managed_services_key_alias" {
  name          = "alias/databricks-managed-services-key-alias"
  target_key_id = aws_kms_key.databricks_managed_services_key.key_id
}

resource "databricks_mws_customer_managed_keys" "managed_services" {
  account_id = var.databricks_account_id
  aws_key_info {
    key_arn   = aws_kms_key.databricks_managed_services_key.arn
    key_alias = aws_kms_alias.databricks_managed_services_key_alias.name
  }
  use_cases = ["MANAGED_SERVICES"]
}

data "aws_iam_policy_document" "databricks_workspace_storage_cmk" {
  version = "2012-10-17"
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.account_id]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }
  statement {
    sid    = "Allow Databricks to use KMS key for DBFS"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::414351767826:root"]
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "Allow Databricks to use KMS key for DBFS (Grants)"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::414351767826:root"]
    }
    actions = [
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant"
    ]
    resources = ["*"]
    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }
  }
  statement {
    sid    = "Allow Databricks to use KMS key for EBS"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [var.databricks_cross_account_role_arn]
    }
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey*",
      "kms:CreateGrant",
      "kms:DescribeKey"
    ]
    resources = ["*"]
    condition {
      test     = "ForAnyValue:StringLike"
      variable = "kms:ViaService"
      values   = ["ec2.*.amazonaws.com"]
    }
  }
}

resource "aws_kms_key" "databricks_workspace_storage_key" {
  policy = data.aws_iam_policy_document.databricks_workspace_storage_cmk.json
}

resource "aws_kms_alias" "databricks_workspace_storage_key_alias" {
  name          = "alias/databricks-workspace-storage-key-alias"
  target_key_id = aws_kms_key.databricks_workspace_storage_key.key_id
}

resource "databricks_mws_customer_managed_keys" "workspace_storage" {
  account_id = var.databricks_account_id
  aws_key_info {
    key_arn   = aws_kms_key.databricks_workspace_storage_key.arn
    key_alias = aws_kms_alias.databricks_workspace_storage_key_alias.name
  }
  use_cases = ["STORAGE"]
}
