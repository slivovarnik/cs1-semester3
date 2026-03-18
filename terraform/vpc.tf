resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "${var.project}-vpc"
    Project = var.project
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "${var.project}-igw"
    Project = var.project
  }
}

# Public subnet for ALB
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.project}-public-a"
    Tier    = "public"
    Project = var.project
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.project}-public-b"
    Tier    = "public"
    Project = var.project
  }
}

# Private web subnets
resource "aws_subnet" "web_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "${var.region}a"

  tags = {
    Name    = "${var.project}-web-a"
    Tier    = "web"
    Project = var.project
  }
}

resource "aws_subnet" "web_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "${var.region}b"

  tags = {
    Name    = "${var.project}-web-b"
    Tier    = "web"
    Project = var.project
  }
}

# Private DB subnets
resource "aws_subnet" "db_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.20.0/24"
  availability_zone = "${var.region}a"

  tags = {
    Name    = "${var.project}-db-a"
    Tier    = "db"
    Project = var.project
  }
}

resource "aws_subnet" "db_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.21.0/24"
  availability_zone = "${var.region}b"

  tags = {
    Name    = "${var.project}-db-b"
    Tier    = "db"
    Project = var.project
  }
}

# Private monitoring subnets
resource "aws_subnet" "mon_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.30.0/24"
  availability_zone = "${var.region}a"

  tags = {
    Name    = "${var.project}-mon-a"
    Tier    = "monitoring"
    Project = var.project
  }
}

resource "aws_subnet" "mon_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.31.0/24"
  availability_zone = "${var.region}b"

  tags = {
    Name    = "${var.project}-mon-b"
    Tier    = "monitoring"
    Project = var.project
  }
}

# NAT Gateway for private subnets
resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name    = "${var.project}-nat-eip"
    Project = var.project
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_a.id

  tags = {
    Name    = "${var.project}-nat"
    Project = var.project
  }
}

# Public route table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name    = "${var.project}-public-rt"
    Project = var.project
  }
}

resource "aws_route_table_association" "public_a_assoc" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_b_assoc" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_rt.id
}

# Private route table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name    = "${var.project}-private-rt"
    Project = var.project
  }
}

resource "aws_route_table_association" "web_a_assoc" {
  subnet_id      = aws_subnet.web_a.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "web_b_assoc" {
  subnet_id      = aws_subnet.web_b.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "db_a_assoc" {
  subnet_id      = aws_subnet.db_a.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "db_b_assoc" {
  subnet_id      = aws_subnet.db_b.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "mon_a_assoc" {
  subnet_id      = aws_subnet.mon_a.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "mon_b_assoc" {
  subnet_id      = aws_subnet.mon_b.id
  route_table_id = aws_route_table.private_rt.id
}