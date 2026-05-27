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
# Allows PostgreSQL access from the Workload VPC and Client VPN
resource "aws_security_group" "rds_sg" {
  name        = "${var.project}-rds-sg"
  description = "Security group for Aurora in data VPC"
  vpc_id      = aws_vpc.data.id

  ingress {
    description = "PostgreSQL from workload VPC and Client VPN"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [
      aws_vpc.workload.cidr_block,
      var.client_vpn_cidr
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

# Security group for Client VPN endpoint
resource "aws_security_group" "client_vpn_sg" {
  name        = "${var.project}-client-vpn-sg"
  description = "Security group for AWS Client VPN endpoint"
  vpc_id      = aws_vpc.workload.id

  ingress {
    description = "Client VPN over UDP 443"
    from_port   = 443
    to_port     = 443
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Client VPN over TCP 443"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound from Client VPN endpoint"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project}-client-vpn-sg"
    Project = var.project
  }
}

# Security group for k3s Kubernetes node
# Tightened to only allow specific ports instead of all traffic
# Port 30080 — HR application NodePort for VPN clients
# Port 6443 — Kubernetes API for VPN clients
# All internal VPC traffic for pod networking and SSM
# Satisfies REQ-NCA-P3-08 least privilege firewall rules
resource "aws_security_group" "k3s_sg" {
  name        = "${var.project}-k3s-sg"
  description = "Security group for k3s Kubernetes node"
  vpc_id      = aws_vpc.workload.id

  ingress {
    description = "HR application access from VPN clients"
    from_port   = 30080
    to_port     = 30080
    protocol    = "tcp"
    cidr_blocks = [var.client_vpn_cidr]
  }

  ingress {
    description = "Kubernetes API from VPN clients"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = [var.client_vpn_cidr]
  }

  ingress {
    description = "Internal VPC communication for pod networking and SSM"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.workload.cidr_block]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project}-k3s-sg"
    Project = var.project
  }
}