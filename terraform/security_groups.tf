# Security group for the public ALB
# Allows inbound HTTP/HTTPS from the internet.
resource "aws_security_group" "alb_sg" {
  name        = "${var.project}-alb-sg"
  description = "Security group for public ALB"
  vpc_id      = aws_vpc.workload.id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound from ALB"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project}-alb-sg"
    Project = var.project
  }
}

# Security group for web servers
# Only allows HTTP from the ALB.
resource "aws_security_group" "web_sg" {
  name        = "${var.project}-web-sg"
  description = "Security group for web servers"
  vpc_id      = aws_vpc.workload.id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    description = "Allow all outbound from web servers"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project}-web-sg"
    Project = var.project
  }
}

# Security group for ECS SOAR
# Allows internal SOAR traffic from inside the workload VPC.
resource "aws_security_group" "soar_sg" {
  name        = "${var.project}-soar-sg"
  description = "Security group for ECS SOAR"
  vpc_id      = aws_vpc.workload.id

  ingress {
    description = "SOAR traffic from workload VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.workload.cidr_block]
  }

  egress {
    description = "Allow all outbound from SOAR"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project}-soar-sg"
    Project = var.project
  }
}

# Security group for interface VPC endpoints
# Allows HTTPS from private resources inside the workload VPC.
resource "aws_security_group" "vpce_sg" {
  name        = "${var.project}-vpce-sg"
  description = "Security group for interface VPC endpoints"
  vpc_id      = aws_vpc.workload.id

  ingress {
    description = "HTTPS from workload private resources"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.workload.cidr_block]
  }

  egress {
    description = "Allow all outbound from interface endpoints"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project}-vpce-sg"
    Project = var.project
  }
}

# Security group for Aurora / RDS
# Allows PostgreSQL access from Workload VPC, Client VPN, and Kubernetes VPC.
resource "aws_security_group" "rds_sg" {
  name        = "${var.project}-rds-sg"
  description = "Security group for Aurora in data VPC"
  vpc_id      = aws_vpc.data.id

  ingress {
    description = "PostgreSQL from workload VPC, Client VPN, and Kubernetes VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [
      aws_vpc.workload.cidr_block,
      var.client_vpn_cidr,
      aws_vpc.k8s.cidr_block
    ]
  }

  egress {
    description = "Allow all outbound from Aurora"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project}-rds-sg"
    Project = var.project
  }
}

# Security group for EKS worker nodes
resource "aws_security_group" "eks_nodes_sg" {
  name        = "${var.project}-eks-nodes-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = aws_vpc.k8s.id

  ingress {
    description = "Allow nodes to communicate with each other"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  ingress {
    description = "Allow all traffic within Kubernetes VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.k8s_vpc_cidr]
  }

  egress {
    description = "Allow all outbound from nodes"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project}-eks-nodes-sg"
    Project = var.project
  }
}

# Security group for VPC endpoints in the Kubernetes VPC
resource "aws_security_group" "k8s_vpce_sg" {
  name        = "${var.project}-k8s-vpce-sg"
  description = "Security group for VPC endpoints in Kubernetes VPC"
  vpc_id      = aws_vpc.k8s.id

  ingress {
    description = "HTTPS from Kubernetes VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.k8s_vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project}-k8s-vpce-sg"
    Project = var.project
  }
}
