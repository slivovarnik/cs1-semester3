# Data VPC
# Isolates the database layer from the workload VPC.
resource "aws_vpc" "data" {
  cidr_block           = var.data_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "${var.project}-data-vpc"
    Project = var.project
    Role    = "data"
  }
}

# Database subnet A for Aurora / RDS
resource "aws_subnet" "db_a" {
  vpc_id            = aws_vpc.data.id
  cidr_block        = "10.30.20.0/24"
  availability_zone = "${var.region}a"

  tags = {
    Name    = "${var.project}-db-a"
    Tier    = "db"
    Project = var.project
  }
}

# Database subnet B for Aurora / RDS
resource "aws_subnet" "db_b" {
  vpc_id            = aws_vpc.data.id
  cidr_block        = "10.30.21.0/24"
  availability_zone = "${var.region}b"

  tags = {
    Name    = "${var.project}-db-b"
    Tier    = "db"
    Project = var.project
  }
}

# Private route table for the data VPC
resource "aws_route_table" "data_rt" {
  vpc_id = aws_vpc.data.id

  tags = {
    Name    = "${var.project}-data-rt"
    Project = var.project
  }
}

# Associate database subnet A with the data route table
resource "aws_route_table_association" "db_a_assoc" {
  subnet_id      = aws_subnet.db_a.id
  route_table_id = aws_route_table.data_rt.id
}

# Associate database subnet B with the data route table
resource "aws_route_table_association" "db_b_assoc" {
  subnet_id      = aws_subnet.db_b.id
  route_table_id = aws_route_table.data_rt.id
}