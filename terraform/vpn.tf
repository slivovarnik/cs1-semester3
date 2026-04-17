# Security group for the Client VPN endpoint
# Allows VPN clients to connect to the endpoint over TLS/443.
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

# AWS Client VPN endpoint
# Provides secure client-to-VPC access using mutual certificate authentication.
resource "aws_ec2_client_vpn_endpoint" "main" {
  description            = "${var.project} client vpn"
  server_certificate_arn = var.client_vpn_server_certificate_arn
  client_cidr_block      = var.client_vpn_cidr
  split_tunnel           = true
  transport_protocol     = "udp"
  vpn_port               = 443

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = var.client_vpn_client_root_certificate_chain_arn
  }

  connection_log_options {
    enabled = false
  }

  tags = {
    Name    = "${var.project}-client-vpn"
    Project = var.project
  }
}

# Associate the Client VPN endpoint with services subnet A
resource "aws_ec2_client_vpn_network_association" "workload_a" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.main.id
  subnet_id              = aws_subnet.svc_a.id
}

# Associate the Client VPN endpoint with services subnet B
resource "aws_ec2_client_vpn_network_association" "workload_b" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.main.id
  subnet_id              = aws_subnet.svc_b.id
}

# Authorization rule for the Workload VPC
resource "aws_ec2_client_vpn_authorization_rule" "workload" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.main.id
  target_network_cidr    = aws_vpc.workload.cidr_block
  authorize_all_groups   = true
  description            = "Allow VPN clients to access workload VPC"
}

# Authorization rule for the Data VPC
resource "aws_ec2_client_vpn_authorization_rule" "data" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.main.id
  target_network_cidr    = aws_vpc.data.cidr_block
  authorize_all_groups   = true
  description            = "Allow VPN clients to access data VPC"
}

# Route from the Client VPN endpoint to the Data VPC
# Traffic enters the Workload VPC first, then reaches the Data VPC through the TGW.
resource "aws_ec2_client_vpn_route" "data" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.main.id
  destination_cidr_block = aws_vpc.data.cidr_block
  target_vpc_subnet_id   = aws_subnet.svc_a.id

  depends_on = [
    aws_ec2_client_vpn_network_association.workload_a
  ]
}