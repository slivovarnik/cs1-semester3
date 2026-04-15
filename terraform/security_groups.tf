# public/dmz vpc security groups

resource "aws_security_group" "edge_alb_sg" {
  name        = "${var.project}-edge-alb-sg"
  description = "Security group for the public/edge ALB in the public VPC"
  vpc_id      = aws_vpc.public.id

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
    description = "Outbound traffic from edge ALB"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project}-edge-alb-sg"
    Project = var.project
    Role    = "edge"
  }
}

# private/shared services vpc security groups

resource "aws_security_group" "soar_sg" {
  name        = "${var.project}-soar-sg"
  description = "Security group for the SOAR core service (ECS/Fargate later)"
  vpc_id      = aws_vpc.shared.id

  ingress {
    description = "SOAR API / listener port from monitoring tier"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    security_groups = [
      aws_security_group.monitoring_sg.id
    ]
  }

  ingress {
    description = "SOAR API / listener port from Lambda responders if needed"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    security_groups = [
      aws_security_group.lambda_sg.id
    ]
  }

  egress {
    description = "Outbound traffic from SOAR service"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project}-soar-sg"
    Project = var.project
    Role    = "soar"
  }
}

resource "aws_security_group" "monitoring_sg" {
  name        = "${var.project}-monitoring-sg"
  description = "Security group for Grafana/Prometheus/Loki and monitoring services"
  vpc_id      = aws_vpc.shared.id

  ingress {
    description = "Grafana UI"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.shared.cidr_block]
  }

  ingress {
    description = "Prometheus"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.shared.cidr_block]
  }

  ingress {
    description = "Loki"
    from_port   = 3100
    to_port     = 3100
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.shared.cidr_block]
  }

  egress {
    description = "Outbound traffic from monitoring stack"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project}-monitoring-sg"
    Project = var.project
    Role    = "monitoring"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "${var.project}-rds-sg"
  description = "Security group for private Aurora PostgreSQL in shared VPC"
  vpc_id      = aws_vpc.shared.id

  ingress {
    description = "PostgreSQL from SOAR/app services"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [
      aws_security_group.soar_sg.id,
      aws_security_group.lambda_sg.id
    ]
  }

  egress {
    description = "Outbound traffic from Aurora SG"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project}-rds-sg"
    Project = var.project
    Role    = "database"
  }
}

resource "aws_security_group" "lambda_sg" {
  name        = "${var.project}-lambda-sg"
  description = "Security group for Lambda functions running inside the shared VPC"
  vpc_id      = aws_vpc.shared.id

  egress {
    description = "Outbound traffic from Lambda"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project}-lambda-sg"
    Project = var.project
    Role    = "lambda"
  }
}

resource "aws_security_group" "vpce_sg" {
  name        = "${var.project}-vpce-sg"
  description = "Security group for interface VPC endpoints in the shared VPC"
  vpc_id      = aws_vpc.shared.id

  ingress {
    description = "HTTPS from SOAR services to interface endpoints"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = [
      aws_security_group.soar_sg.id,
      aws_security_group.monitoring_sg.id,
      aws_security_group.lambda_sg.id
    ]
  }

  egress {
    description = "Outbound traffic from interface endpoints"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project}-vpce-sg"
    Project = var.project
    Role    = "endpoints"
  }
}