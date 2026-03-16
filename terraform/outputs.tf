output "vpc_id" {
  description = "ID of the main VPC"
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "Public subnet for ALB"
  value = aws_subnet.public_a.id
}

output "web_subnet_ids" {
  description = "Private web subnet IDs"
  value = [
    aws_subnet.web_a.id,
    aws_subnet.web_b.id
  ]
}

output "db_subnet_ids" {
  description = "Private DB subnet IDs"
  value = [
    aws_subnet.db_a.id,
    aws_subnet.db_b.id
  ]
}

output "monitoring_subnet_ids" {
  description = "Private monitoring subnet IDs"
  value = [
    aws_subnet.mon_a.id,
    aws_subnet.mon_b.id
  ]
}

output "nat_gateway_id" {
  description = "NAT gateway ID for private subnet outbound traffic"
  value = aws_nat_gateway.nat.id
}