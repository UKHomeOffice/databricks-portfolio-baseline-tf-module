output "databricks_rest_vpce_id" {
  description = "ID of the Databricks VPC Endpoint Registraion used for REST"
  value       = databricks_mws_vpc_endpoint.databricks_rest.id
}

output "databricks_scc_vpce_id" {
  description = "ID of the Databricks VPC Endpoint Registraion used for SCC Relay"
  value       = databricks_mws_vpc_endpoint.databricks_scc.id
}

output "security_group_classic_compute_id" {
  description = "ID of the security group used for classic compute clusters"
  value       = aws_security_group.databricks_classic_compute.id
}

output "security_group_backend_vpce_id" {
  description = "ID of the security group used for Databricks backend VPCE"
  value       = aws_security_group.databricks_backend_vpce.id
}

output "cross_account_role_arn" {
  description = "ARN of the cross-account IAM role used to create Databricks classic compute clusters in the provided VPC"
  value       = aws_iam_role.cross_account_role.arn
}

output "workspace_storage_key_arn" {
  description = "ARN of the KMS key used for workspace storage encryption and decryption operations"
  value       = aws_kms_key.databricks_workspace_storage.arn
}

output "databricks_workspace_storage_key_id" {
  description = "ID of the Databricks Encryption Key Configuration used for workspace storage"
  value       = databricks_mws_customer_managed_keys.workspace_storage.customer_managed_key_id
}

output "databricks_managed_services_key_id" {
  description = "ID of the Databricks Encryption Key Configuration used for managed services"
  value       = databricks_mws_customer_managed_keys.managed_services.customer_managed_key_id
}

output "catalog_bucket_name" {
  description = "Name of the S3 bucket used for the UC catalog storage"
  value       = aws_s3_bucket.unity_catalog_bucket.bucket
}

output "catalog_name" {
  description = "Name of the UC catalog that was created"
  value       = databricks_catalog.workspace_catalog.name
}
