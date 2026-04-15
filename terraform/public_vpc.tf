resource "aws_vpc" "public" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "${var.project}-public-vpc"
    Project = var.project
    Role    = "public"
  }
}

resource "aws_internet_gateway" "public_igw" {
  vpc_id = aws_vpc.public.id

  tags = {
    Name    = "${var.project}-public-igw"
    Project = var.project
  }
}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.public.id
  cidr_block              = "10.20.1.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.project}-public-a"
    Tier    = "public"
    Project = var.project
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.public.id
  cidr_block              = "10.20.2.0/24"
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.project}-public-b"
    Tier    = "public"
    Project = var.project
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.public.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public_igw.id
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