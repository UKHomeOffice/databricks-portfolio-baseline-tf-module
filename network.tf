# ==============================================================================
# Subnets
# ==============================================================================

resource "aws_subnet" "private_backend" {
  for_each = var.private_backend_subnet_config

  vpc_id            = var.vpc_id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(var.tags, {
    Name = "${var.resource_prefix}-private-backend-${each.key}"
  })
}

# ==============================================================================
# Route Table Associations
# ==============================================================================

resource "aws_route_table_association" "private_backend" {
  for_each = var.private_backend_subnet_config

  subnet_id      = each.value.id
  route_table_id = var.private_route_table_id
}

# ==============================================================================
# # NACL for Databricks VPC endpoint private subnets
# ==============================================================================

resource "aws_network_acl" "private_backend" {
  vpc_id     = var.vpc_id
  subnet_ids = [for s in aws_subnet.private_backend : s.id]

  ingress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.resource_prefix}-nacl-private-backend"
    }
  )
}

# ==============================================================================
# Security Groups
# ==============================================================================

# databricks-classic-compute-sg
resource "aws_security_group" "databricks_classic_compute" {
  name        = "${var.resource_prefix}-classic-compute-sg"
  description = "For Databricks Classic Compute Cluster network communication"
  vpc_id      = var.vpc_id

  ingress {
    description = "All TCP from self"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description = "All UDP from self"
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    self        = true
  }

  egress {
    description = "All TCP from self"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }

  egress {
    description = "All UDP from self"
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    self        = true
  }

  egress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Secure Cluster Connectivity Compliance Security Profile"
    from_port   = 2443
    to_port     = 2443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Lakebase PostgreSQL"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Unity Catalog Metastore"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Secure Cluster Connectivity"
    from_port   = 6666
    to_port     = 6666
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Compute Plane to Control Plane"
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Unity Catalog Logging and Lineage Data Streaming"
    from_port   = 8444
    to_port     = 8444
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Future Extendability"
    from_port   = 8445
    to_port     = 8451
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.resource_prefix}-classic-compute-sg"
  })
}

# databricks-backend-vpce-sg
resource "aws_security_group" "databricks_backend_vpce" {
  name        = "${var.resource_prefix}-backend-vpce-sg"
  description = "Backend VPCE SG spanning private subnets"
  vpc_id      = var.vpc_id

  ingress {
    description     = "TCP 443 from Classic Compute SG"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.databricks_classic_compute.id]
  }

  ingress {
    description     = "Unity Catalog Metastore"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.databricks_classic_compute.id]
  }

  ingress {
    description     = "Lakebase PostgreSQL"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.databricks_classic_compute.id]
  }

  ingress {
    description     = "Secure Cluster Connectivity Compliance Security Profile"
    from_port       = 2443
    to_port         = 2443
    protocol        = "tcp"
    security_groups = [aws_security_group.databricks_classic_compute.id]
  }

  ingress {
    description     = "Secure Cluster Connectivity"
    from_port       = 6666
    to_port         = 6666
    protocol        = "tcp"
    security_groups = [aws_security_group.databricks_classic_compute.id]
  }

  ingress {
    description     = "Compute Plane to Control Plane"
    from_port       = 8443
    to_port         = 8443
    protocol        = "tcp"
    security_groups = [aws_security_group.databricks_classic_compute.id]
  }

  ingress {
    description     = "Unity Catalog Logging and Lineage Data Streaming"
    from_port       = 8444
    to_port         = 8444
    protocol        = "tcp"
    security_groups = [aws_security_group.databricks_classic_compute.id]
  }

  ingress {
    description     = "Future Extendability"
    from_port       = 8445
    to_port         = 8451
    protocol        = "tcp"
    security_groups = [aws_security_group.databricks_classic_compute.id]
  }

  egress {
    description = "All traffic outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.resource_prefix}-backend-vpce-sg"
  })
}

# ==============================================================================
# AWS VPC Endpoints
# ==============================================================================

# Databricks REST endpoint
resource "aws_vpc_endpoint" "databricks_rest" {
  vpc_id              = var.vpc_id
  service_name        = var.workspace_config[var.region].primary_endpoint
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.databricks_backend_vpce.id]
  subnet_ids          = [for s in aws_subnet.private_backend : s.id]
  private_dns_enabled = true

  tags = merge(var.tags, {
    Name = "${var.resource_prefix}-backend-rest"
  })
}

# Databricks SCC endpoint
resource "aws_vpc_endpoint" "databricks_scc" {
  vpc_id              = var.vpc_id
  service_name        = var.scc_relay_config[var.region].primary_endpoint
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.databricks_backend_vpce.id]
  subnet_ids          = [for s in aws_subnet.private_backend : s.id]
  private_dns_enabled = true

  tags = merge(var.tags, {
    Name = "${var.resource_prefix}-backend-relay"
  })
}

# ==============================================================================
# Databricks VPC Endpoint Registrations
# ==============================================================================

# Databricks REST VPC Endpoint Configuration
resource "databricks_mws_vpc_endpoint" "databricks_rest" {
  provider            = databricks.mws
  account_id          = var.databricks_account_id
  aws_vpc_endpoint_id = aws_vpc_endpoint.databricks_rest.id
  vpc_endpoint_name   = "${var.resource_prefix}-vpce-backend-${var.vpc_id}"
  region              = var.region
}

# Databricks SCC VPC Endpoint Configuration
resource "databricks_mws_vpc_endpoint" "databricks_scc" {
  provider            = databricks.mws
  account_id          = var.databricks_account_id
  aws_vpc_endpoint_id = aws_vpc_endpoint.databricks_scc.id
  vpc_endpoint_name   = "${var.resource_prefix}-vpce-relay-${var.vpc_id}"
  region              = var.region
}
