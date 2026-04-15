resource "aws_ec2_transit_gateway" "tgw" {
  description                     = "${var.project} transit gateway"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"

  tags = {
    Name    = "${var.project}-tgw"
    Project = var.project
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "public_attach" {
  subnet_ids         = [aws_subnet.public_a.id, aws_subnet.public_b.id]
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = aws_vpc.public.id

  tags = {
    Name    = "${var.project}-public-attach"
    Project = var.project
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "shared_attach" {
  subnet_ids         = [aws_subnet.app_a.id, aws_subnet.app_b.id]
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = aws_vpc.shared.id

  tags = {
    Name    = "${var.project}-shared-attach"
    Project = var.project
  }
}

resource "aws_route" "public_to_shared" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = aws_vpc.shared.cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "shared_to_public" {
  route_table_id         = aws_route_table.shared_rt.id
  destination_cidr_block = aws_vpc.public.cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}