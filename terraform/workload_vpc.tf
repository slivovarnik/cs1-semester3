# Workload VPC
# Hosts ALB, web servers, ECS SOAR, private service subnets, and VPC endpoints.
resource "aws_vpc" "workload" {
  cidr_block           = var.workload_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "${var.project}-workload-vpc"
    Project = var.project
    Role    = "workload"
  }
}

# Internet Gateway for the workload VPC
resource "aws_internet_gateway" "workload_igw" {
  vpc_id = aws_vpc.workload.id

  tags = {
    Name    = "${var.project}-workload-igw"
    Project = var.project
  }
}

# Public subnet A for internet-facing resources such as the ALB
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.workload.id
  cidr_block              = "10.20.1.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.project}-public-a"
    Tier    = "public"
    Project = var.project
  }
}

# Public subnet B for ALB high availability
resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.workload.id
  cidr_block              = "10.20.2.0/24"
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.project}-public-b"
    Tier    = "public"
    Project = var.project
  }
}

# Private web subnet A for EC2 web servers
resource "aws_subnet" "web_a" {
  vpc_id            = aws_vpc.workload.id
  cidr_block        = "10.20.10.0/24"
  availability_zone = "${var.region}a"

  tags = {
    Name    = "${var.project}-web-a"
    Tier    = "web"
    Project = var.project
  }
}

# Private web subnet B for EC2 web servers
resource "aws_subnet" "web_b" {
  vpc_id            = aws_vpc.workload.id
  cidr_block        = "10.20.11.0/24"
  availability_zone = "${var.region}b"

  tags = {
    Name    = "${var.project}-web-b"
    Tier    = "web"
    Project = var.project
  }
}

# Private services subnet A for ECS SOAR, Client VPN association, and endpoints
resource "aws_subnet" "svc_a" {
  vpc_id            = aws_vpc.workload.id
  cidr_block        = "10.20.30.0/24"
  availability_zone = "${var.region}a"

  tags = {
    Name    = "${var.project}-svc-a"
    Tier    = "services"
    Project = var.project
  }
}

# Private services subnet B for ECS SOAR, Client VPN association, and endpoints
resource "aws_subnet" "svc_b" {
  vpc_id            = aws_vpc.workload.id
  cidr_block        = "10.20.31.0/24"
  availability_zone = "${var.region}b"

  tags = {
    Name    = "${var.project}-svc-b"
    Tier    = "services"
    Project = var.project
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name    = "${var.project}-nat-eip"
    Project = var.project
  }
}

# NAT Gateway for outbound internet access from private subnets
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_a.id

  tags = {
    Name    = "${var.project}-nat"
    Project = var.project
  }
}

# Public route table
# Sends internet-bound traffic through the Internet Gateway.
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.workload.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.workload_igw.id
  }

  tags = {
    Name    = "${var.project}-workload-public-rt"
    Project = var.project
  }
}

# Private route table
# Sends internet-bound traffic from private subnets through the NAT Gateway.
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.workload.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name    = "${var.project}-workload-private-rt"
    Project = var.project
  }
}

# Associate public subnet A with the public route table
resource "aws_route_table_association" "public_a_assoc" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_rt.id
}

# Associate public subnet B with the public route table
resource "aws_route_table_association" "public_b_assoc" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_rt.id
}

# Associate web subnet A with the private route table
resource "aws_route_table_association" "web_a_assoc" {
  subnet_id      = aws_subnet.web_a.id
  route_table_id = aws_route_table.private_rt.id
}

# Associate web subnet B with the private route table
resource "aws_route_table_association" "web_b_assoc" {
  subnet_id      = aws_subnet.web_b.id
  route_table_id = aws_route_table.private_rt.id
}

# Associate services subnet A with the private route table
resource "aws_route_table_association" "svc_a_assoc" {
  subnet_id      = aws_subnet.svc_a.id
  route_table_id = aws_route_table.private_rt.id
}

# Associate services subnet B with the private route table
resource "aws_route_table_association" "svc_b_assoc" {
  subnet_id      = aws_subnet.svc_b.id
  route_table_id = aws_route_table.private_rt.id
}