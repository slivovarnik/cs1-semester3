# Gateway endpoint for Amazon S3
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.workload.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    aws_route_table.private_rt.id
  ]

  tags = {
    Name    = "${var.project}-s3-endpoint"
    Project = var.project
  }
}

# Interface endpoint for ECR API
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.workload.id
  service_name        = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.svc_a.id, aws_subnet.svc_b.id]
  security_group_ids  = [aws_security_group.vpce_sg.id]
  private_dns_enabled = true

  tags = {
    Name    = "${var.project}-ecr-api-endpoint"
    Project = var.project
  }
}

# Interface endpoint for ECR Docker registry
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.workload.id
  service_name        = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.svc_a.id, aws_subnet.svc_b.id]
  security_group_ids  = [aws_security_group.vpce_sg.id]
  private_dns_enabled = true

  tags = {
    Name    = "${var.project}-ecr-dkr-endpoint"
    Project = var.project
  }
}

# Interface endpoint for CloudWatch Logs
resource "aws_vpc_endpoint" "logs" {
  vpc_id              = aws_vpc.workload.id
  service_name        = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.svc_a.id, aws_subnet.svc_b.id]
  security_group_ids  = [aws_security_group.vpce_sg.id]
  private_dns_enabled = true

  tags = {
    Name    = "${var.project}-logs-endpoint"
    Project = var.project
  }
}

# Interface endpoint for Secrets Manager
resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id              = aws_vpc.workload.id
  service_name        = "com.amazonaws.${var.region}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.svc_a.id, aws_subnet.svc_b.id]
  security_group_ids  = [aws_security_group.vpce_sg.id]
  private_dns_enabled = true

  tags = {
    Name    = "${var.project}-secretsmanager-endpoint"
    Project = var.project
  }
}