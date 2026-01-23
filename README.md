# databricks-portfolio-baseline-tf-module - Databricks Portfolio Baseline Terraform Module

This repo contains a module to deploy the foundational components for a new portfolio being onboarded to Databricks. This includes the AWS KMS keys for workspace storage and managed services, and their associated Databricks Encryption Key configurations, as well as the AWS VPC interface endpoints for Databricks REST and SCC Relay endpoints, and their associated Databricks VPC endpoint registration objects.

## Example Usage
```
locals {
  # Private /28 subnets (Databricks backend VPCE)
  private_backend_subnet_config = {
    az1 = { 
      cidr = "10.111.172.48/28"
      az = "eu-west-2a" 
    }
    az2 = { 
      cidr = "10.111.172.64/28"
      az = "eu-west-2b" 
    }
    az3 = { 
      cidr = "10.111.172.80/28"
      az = "eu-west-2c" 
    }
  }
}

 module "databricks_portfolio" {
    source = "git::https://github.com/UKHomeOffice/databricks-portfolio-baseline-tf-module.git?ref=<commit_hash>"

    vpc_id                        = "vpc-xxxxxxxxxxxxxxxxx"
    private_route_table_id        = var.private_route_table_id
    databricks_account_id         = var.databricks_account_id
    private_backend_subnet_config = local.private_backend_subnet_config
    sg_egress_ports               = [443, 2443, 5432, 6666, 8443, 8444, 8445, 8446, 8447, 8448, 8449, 8450, 8451]

    resource_prefix = "dsa-databricks"
    tags            = local.tags
 }
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.24.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.24.0 |
| <a name="provider_databricks"></a> [databricks](#provider\_databricks) | ~> 1.84 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_kms_key.databricks_managed_services_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_key.databricks_workspace_storage_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_alias.databricks_managed_services_key_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_alias.databricks_workspace_storage_key_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [databricks_mws_customer_managed_keys.managed_services](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_customer_managed_keys) | resource |
| [databricks_mws_customer_managed_keys.workspace_storage](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_customer_managed_keys) | resource |
| [aws_subnet.private_backend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_security_group.databricks_classic_compute](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.databricks_backend_vpce](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_route_table_association.private_backend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_vpc_endpoint.databricks_rest](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.databricks_scc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [databricks_mws_vpc_endpoint.databricks_rest](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_vpc_endpoint) | resource |
| [databricks_mws_vpc_endpoint.databricks_scc](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_vpc_endpoint) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC in which the Databricks backend VPC endpoints will be deployed | `string` | n/a | yes |
| <a name="input_private_route_table_id"></a> [private\_route\_table\_id](#input\_private\_route\_table\_id) | The ID of the private AWS route table to associate subnets to | `string` | n/a | yes |
| <a name="input_databricks_account_id"></a> [databricks\_account\_id](#input\_databricks\_account\_id) | The ID of the Databricks account to deploy Databricks resources to | `string` | n/a | yes |
| <a name="input_private_backend_subnet_config"></a> [private\_backend\_subnet\_config](#input\_private\_backend\_subnet\_config) | A map of subnet CIDRs and AZs for the private subnets | `map(string)` | `{}` | yes |
| <a name="input_sg_egress_ports"></a> [sg\_egress\_ports](#input\_sg\_egress\_ports) | A list of ports to allow outbound network traffic from the classic compute clusters SG | `list(string)` | `[]` | no |
| <a name="input_resource_prefix"></a> [vpc\_id](#input\_resource\_prefix) | The prefix to use when applying names to resources | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_user_group_data_engineering"></a> [user\_group\_data\_engineering](#input\_user\_group\_data\_engineering) | Display name of the user group to create for the Data Engineering team | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_databricks_rest_vpce_id"></a> [databricks\_rest\_vpce\_id](#output\_databricks\_rest\_vpce\_id) | ID of the Databricks VPC Endpoint Registraion used for REST |
| <a name="output_databricks_scc_vpce_id"></a> [databricks\_scc\_vpce\_id](#output\_databricks\_scc\_vpce\_id) | ID of the Databricks VPC Endpoint Registraion used for SCC Relay |
| <a name="output_databricks_workspace_storage_key_id"></a> [databricks\_workspace\_storage\_key\_id](#output\_databricks\_workspace\_storage\_key\_id) | ID of the Databricks Encryption Key Configuration used for workspace storage |
| <a name="output_databricks_managed_services_key_id"></a> [databricks\_managed\_services\_key\_id](#output\_databricks\_managed\_services\_key\_id) | ID of the Databricks Encryption Key Configuration used for managed services |
<!-- END_TF_DOCS -->
