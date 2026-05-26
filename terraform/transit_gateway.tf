# Transit Gateway
# Acts as the hub between the Workload VPC and the Data VPC.
resource "aws_ec2_transit_gateway" "main" {
  description                     = "${var.project} transit gateway"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"

  tags = {
    Name    = "${var.project}-tgw"
    Project = var.project
  }
}

# TGW attachment for the Workload VPC
resource "aws_ec2_transit_gateway_vpc_attachment" "workload" {
  subnet_ids         = [aws_subnet.svc_a.id, aws_subnet.svc_b.id]
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = aws_vpc.workload.id

  tags = {
    Name    = "${var.project}-workload-tgw-attachment"
    Project = var.project
  }
}

# TGW attachment for the Data VPC
resource "aws_ec2_transit_gateway_vpc_attachment" "data" {
  subnet_ids         = [aws_subnet.db_a.id, aws_subnet.db_b.id]
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = aws_vpc.data.id

  tags = {
    Name    = "${var.project}-data-tgw-attachment"
    Project = var.project
  }
}

# Route from the Workload VPC private route table to the Data VPC via the TGW
resource "aws_route" "workload_to_data" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = aws_vpc.data.cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
}

# Route from the Data VPC route table back to the Workload VPC via the TGW
resource "aws_route" "data_to_workload" {
  route_table_id         = aws_route_table.data_rt.id
  destination_cidr_block = aws_vpc.workload.cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
}

# Route from the Data VPC route table back to connected Client VPN users
resource "aws_route" "data_to_client_vpn" {
  route_table_id         = aws_route_table.data_rt.id
  destination_cidr_block = var.client_vpn_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
}