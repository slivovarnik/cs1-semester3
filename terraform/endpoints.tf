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

# ECR API endpoint for Kubernetes VPC
resource "aws_vpc_endpoint" "k8s_ecr_api" {
  vpc_id              = aws_vpc.k8s.id
  service_name        = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.k8s_a.id, aws_subnet.k8s_b.id]
  security_group_ids  = [aws_security_group.k8s_vpce_sg.id]
  private_dns_enabled = true

  tags = {
    Name    = "${var.project}-k8s-ecr-api-endpoint"
    Project = var.project
  }
}

# ECR Docker endpoint for Kubernetes VPC
resource "aws_vpc_endpoint" "k8s_ecr_dkr" {
  vpc_id              = aws_vpc.k8s.id
  service_name        = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.k8s_a.id, aws_subnet.k8s_b.id]
  security_group_ids  = [aws_security_group.k8s_vpce_sg.id]
  private_dns_enabled = true

  tags = {
    Name    = "${var.project}-k8s-ecr-dkr-endpoint"
    Project = var.project
  }
}

# Secrets Manager endpoint for Kubernetes VPC
resource "aws_vpc_endpoint" "k8s_secretsmanager" {
  vpc_id              = aws_vpc.k8s.id
  service_name        = "com.amazonaws.${var.region}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.k8s_a.id, aws_subnet.k8s_b.id]
  security_group_ids  = [aws_security_group.k8s_vpce_sg.id]
  private_dns_enabled = true

  tags = {
    Name    = "${var.project}-k8s-secretsmanager-endpoint"
    Project = var.project
  }
}

# CloudWatch Logs endpoint for Kubernetes VPC
resource "aws_vpc_endpoint" "k8s_logs" {
  vpc_id              = aws_vpc.k8s.id
  service_name        = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.k8s_a.id, aws_subnet.k8s_b.id]
  security_group_ids  = [aws_security_group.k8s_vpce_sg.id]
  private_dns_enabled = true

  tags = {
    Name    = "${var.project}-k8s-logs-endpoint"
    Project = var.project
  }
}

# S3 gateway endpoint for Kubernetes VPC
resource "aws_vpc_endpoint" "k8s_s3" {
  vpc_id            = aws_vpc.k8s.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [aws_route_table.k8s_rt.id]

  tags = {
    Name    = "${var.project}-k8s-s3-endpoint"
    Project = var.project
  }
}

# EKS endpoint for Kubernetes VPC
resource "aws_vpc_endpoint" "k8s_eks" {
  vpc_id              = aws_vpc.k8s.id
  service_name        = "com.amazonaws.${var.region}.eks"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.k8s_a.id, aws_subnet.k8s_b.id]
  security_group_ids  = [aws_security_group.k8s_vpce_sg.id]
  private_dns_enabled = true

  tags = {
    Name    = "${var.project}-k8s-eks-endpoint"
    Project = var.project
  }
}

# STS endpoint for Kubernetes VPC
resource "aws_vpc_endpoint" "k8s_sts" {
  vpc_id              = aws_vpc.k8s.id
  service_name        = "com.amazonaws.${var.region}.sts"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.k8s_a.id, aws_subnet.k8s_b.id]
  security_group_ids  = [aws_security_group.k8s_vpce_sg.id]
  private_dns_enabled = true

  tags = {
    Name    = "${var.project}-k8s-sts-endpoint"
    Project = var.project
  }
}

# EC2 endpoint for Kubernetes VPC
resource "aws_vpc_endpoint" "k8s_ec2" {
  vpc_id              = aws_vpc.k8s.id
  service_name        = "com.amazonaws.${var.region}.ec2"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.k8s_a.id, aws_subnet.k8s_b.id]
  security_group_ids  = [aws_security_group.k8s_vpce_sg.id]
  private_dns_enabled = true

  tags = {
    Name    = "${var.project}-k8s-ec2-endpoint"
    Project = var.project
  }
}