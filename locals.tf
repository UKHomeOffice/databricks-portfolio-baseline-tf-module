locals {
  azs            = data.aws_availability_zones.available.names
  aws_account_id = data.aws_caller_identity.current.account_id

  aws_partition         = "aws"
  assume_role_partition = "aws"

  databricks_provider_host = "https://accounts.cloud.databricks.com"

  databricks_aws_account_id       = "414351767826"
  databricks_ec2_image_account_id = "601306020600"

  databricks_artifact_and_sample_data_account_id = "414351767826"

  unity_catalog_iam_arn = "arn:aws:iam::414351767826:role/unity-catalog-prod-UCMasterRole-14S5ZJVKOTYTL"

  cmk_admin_value = var.cmk_admin_arn == null ? "arn:aws:iam::${var.aws_account_id}:root" : var.cmk_admin_arn

  uc_iam_role        = "${var.resource_prefix}-catalog"
  uc_catalog_name_us = replace(var.uc_catalog_name, "-", "_")
}
