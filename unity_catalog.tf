resource "null_resource" "previous" {}

# Wait to prevent race condition between IAM role and external location validation
resource "time_sleep" "wait_60_seconds" {
  depends_on      = [null_resource.previous]
  create_duration = "60s"
}

# Storage Credential (created before role): https://registry.terraform.io/providers/databricks/databricks/latest/docs/guides/unity-catalog#configure-external-locations-and-credentials
resource "databricks_storage_credential" "catalog_storage_credential" {
  provider     = databricks.created_workspace
  metastore_id = var.databricks_metastore_id

  name = "${var.uc_catalog_name}-storage-credential"

  aws_iam_role {
    role_arn = "arn:aws:iam::${local.aws_account_id}:role/${local.uc_iam_role}"
  }

  isolation_mode = "ISOLATION_MODE_ISOLATED"
}

# Unity Catalog Trust Policy - Data Source
data "databricks_aws_unity_catalog_assume_role_policy" "unity_catalog" {
  aws_account_id        = local.aws_account_id
  role_name             = local.uc_iam_role
  unity_catalog_iam_arn = var.unity_catalog_iam_arn
  external_id           = databricks_storage_credential.catalog_storage_credential.aws_iam_role[0].external_id
}

# Unity Catalog Policy - Data Source
data "databricks_aws_unity_catalog_policy" "unity_catalog" {
  aws_account_id = local.aws_account_id
  bucket_name    = aws_s3_bucket.unity_catalog_bucket.id
  role_name      = local.uc_iam_role
  kms_name       = aws_kms_alias.catalog_storage_key_alias.arn
}

# Unity Catalog Policy
resource "aws_iam_policy" "unity_catalog" {
  name   = "${var.resource_prefix}-catalog-policy"
  policy = data.databricks_aws_unity_catalog_policy.unity_catalog.json
}

# Unity Catalog Role
resource "aws_iam_role" "unity_catalog" {
  name               = local.uc_iam_role
  assume_role_policy = data.databricks_aws_unity_catalog_assume_role_policy.unity_catalog.json
  tags = merge(
    var.tags,
    {
      Name = local.uc_iam_role
    }
  )
}

# Unity Catalog Policy Attachment
resource "aws_iam_policy_attachment" "unity_catalog_attach" {
  name       = "unity_catalog_policy_attach"
  roles      = [aws_iam_role.unity_catalog.name]
  policy_arn = aws_iam_policy.unity_catalog.arn
}

# External Location
resource "databricks_external_location" "workspace_catalog_external_location" {
  provider        = databricks.created_workspace
  name            = "${local.uc_catalog_bucket_name}-external-location"
  url             = "s3://${local.uc_catalog_bucket_name}/"
  credential_name = databricks_storage_credential.catalog_storage_credential.id
  comment         = "External location for catalog ${var.uc_catalog_name}"
  isolation_mode  = "ISOLATION_MODE_ISOLATED"
  depends_on      = [aws_iam_policy_attachment.unity_catalog_attach, time_sleep.wait_60_seconds, databricks_mws_workspaces.admin]
}

# Workspace Catalog
resource "databricks_catalog" "workspace_catalog" {
  provider       = databricks.created_workspace
  name           = local.uc_catalog_name_us
  comment        = "This catalog is for - ${var.resource_prefix}"
  isolation_mode = "ISOLATED"
  storage_root   = "s3://${local.uc_catalog_bucket_name}/"
  properties = {
    purpose = "Catalog for - ${var.resource_prefix}"
  }
  depends_on = [databricks_external_location.workspace_catalog_external_location]
}
