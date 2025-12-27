# Unity Catalog S3
resource "aws_s3_bucket" "unity_catalog_bucket" {
  bucket        = "${var.resource_prefix}-unity-catalog-${local.uc_catalog_bucket_name}"
  force_destroy = true
  tags = merge(
    var.tags,
    {
      Name = "${var.resource_prefix}-unity-catalog-${local.uc_catalog_bucket_name}"
    }
  )
}

resource "aws_s3_bucket_versioning" "unity_catalog_versioning" {
  bucket = aws_s3_bucket.unity_catalog_bucket.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "unity_catalog" {
  bucket = aws_s3_bucket.unity_catalog_bucket.bucket
  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.catalog_storage.arn
    }
  }
  depends_on = [aws_kms_alias.catalog_storage_key_alias]
}

resource "aws_s3_bucket_public_access_block" "unity_catalog" {
  bucket                  = aws_s3_bucket.unity_catalog_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  depends_on              = [aws_s3_bucket.unity_catalog_bucket]
}
