output "databricks_rest_vpce_id" {
  description = "ID of the Databricks VPC Endpoint Registraion used for REST"
  value       = databricks_mws_vpc_endpoint.databricks_rest.id
}

output "databricks_scc_vpce_id" {
  description = "ID of the Databricks VPC Endpoint Registraion used for SCC Relay"
  value       = databricks_mws_vpc_endpoint.databricks_scc.id
}

output "databricks_workspace_storage_key_id" {
  description = "ID of the Databricks Encryption Key Configuration used for workspace storage"
  value       = databricks_mws_customer_managed_keys.workspace_storage.customer_managed_key_id
}

output "databricks_managed_services_key_id" {
  description = "ID of the Databricks Encryption Key Configuration used for managed services"
  value       = databricks_mws_customer_managed_keys.managed_services.customer_managed_key_id
}
