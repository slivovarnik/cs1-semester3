resource "aws_vpc" "shared" {
  cidr_block           = "10.30.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "${var.project}-shared-vpc"
    Project = var.project
    Role    = "shared"
  }
}

# App / SOAR private subnets
resource "aws_subnet" "app_a" {
  vpc_id            = aws_vpc.shared.id
  cidr_block        = "10.30.10.0/24"
  availability_zone = "${var.region}a"

  tags = {
    Name    = "${var.project}-app-a"
    Tier    = "app"
    Project = var.project
  }
}

resource "aws_subnet" "app_b" {
  vpc_id            = aws_vpc.shared.id
  cidr_block        = "10.30.11.0/24"
  availability_zone = "${var.region}b"

  tags = {
    Name    = "${var.project}-app-b"
    Tier    = "app"
    Project = var.project
  }
}

# Database private subnets
resource "aws_subnet" "db_a" {
  vpc_id            = aws_vpc.shared.id
  cidr_block        = "10.30.20.0/24"
  availability_zone = "${var.region}a"

  tags = {
    Name    = "${var.project}-db-a"
    Tier    = "db"
    Project = var.project
  }
}

resource "aws_subnet" "db_b" {
  vpc_id            = aws_vpc.shared.id
  cidr_block        = "10.30.21.0/24"
  availability_zone = "${var.region}b"

  tags = {
    Name    = "${var.project}-db-b"
    Tier    = "db"
    Project = var.project
  }
}

# Monitoring private subnets
resource "aws_subnet" "mon_a" {
  vpc_id            = aws_vpc.shared.id
  cidr_block        = "10.30.30.0/24"
  availability_zone = "${var.region}a"

  tags = {
    Name    = "${var.project}-mon-a"
    Tier    = "monitoring"
    Project = var.project
  }
}

resource "aws_subnet" "mon_b" {
  vpc_id            = aws_vpc.shared.id
  cidr_block        = "10.30.31.0/24"
  availability_zone = "${var.region}b"

  tags = {
    Name    = "${var.project}-mon-b"
    Tier    = "monitoring"
    Project = var.project
  }
}

resource "aws_route_table" "shared_rt" {
  vpc_id = aws_vpc.shared.id

  tags = {
    Name    = "${var.project}-shared-rt"
    Project = var.project
  }
}

resource "aws_route_table_association" "app_a_assoc" {
  subnet_id      = aws_subnet.app_a.id
  route_table_id = aws_route_table.shared_rt.id
}

resource "aws_route_table_association" "app_b_assoc" {
  subnet_id      = aws_subnet.app_b.id
  route_table_id = aws_route_table.shared_rt.id
}

resource "aws_route_table_association" "db_a_assoc" {
  subnet_id      = aws_subnet.db_a.id
  route_table_id = aws_route_table.shared_rt.id
}

resource "aws_route_table_association" "db_b_assoc" {
  subnet_id      = aws_subnet.db_b.id
  route_table_id = aws_route_table.shared_rt.id
}

resource "aws_route_table_association" "mon_a_assoc" {
  subnet_id      = aws_subnet.mon_a.id
  route_table_id = aws_route_table.shared_rt.id
}

resource "aws_route_table_association" "mon_b_assoc" {
  subnet_id      = aws_subnet.mon_b.id
  route_table_id = aws_route_table.shared_rt.id
}