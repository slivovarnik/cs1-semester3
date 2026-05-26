# Kubernetes VPC
resource "aws_vpc" "k8s" {
  cidr_block           = var.k8s_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "${var.project}-k8s-vpc"
    Project = var.project
    Role    = "kubernetes"
  }
}

# Private subnet AZ-A for EKS nodes
resource "aws_subnet" "k8s_a" {
  vpc_id            = aws_vpc.k8s.id
  cidr_block        = "10.40.1.0/24"
  availability_zone = "${var.region}a"

  tags = {
    Name                                       = "${var.project}-k8s-a"
    Project                                    = var.project
    "kubernetes.io/role/internal-elb"          = "1"
    "kubernetes.io/cluster/${var.project}-eks" = "shared"
  }
}

# Private subnet AZ-B for EKS nodes
resource "aws_subnet" "k8s_b" {
  vpc_id            = aws_vpc.k8s.id
  cidr_block        = "10.40.2.0/24"
  availability_zone = "${var.region}b"

  tags = {
    Name                                       = "${var.project}-k8s-b"
    Project                                    = var.project
    "kubernetes.io/role/internal-elb"          = "1"
    "kubernetes.io/cluster/${var.project}-eks" = "shared"
  }
}

# Private route table for Kubernetes VPC
resource "aws_route_table" "k8s_rt" {
  vpc_id = aws_vpc.k8s.id

  tags = {
    Name    = "${var.project}-k8s-rt"
    Project = var.project
  }
}

resource "aws_route_table_association" "k8s_a" {
  subnet_id      = aws_subnet.k8s_a.id
  route_table_id = aws_route_table.k8s_rt.id
}

resource "aws_route_table_association" "k8s_b" {
  subnet_id      = aws_subnet.k8s_b.id
  route_table_id = aws_route_table.k8s_rt.id
}