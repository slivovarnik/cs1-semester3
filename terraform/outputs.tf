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

output "alb_sg_id" {
  description = "Security group ID for the ALB"
  value = aws_security_group.alb_sg.id
}

output "web_sg_id" {
  description = "Security group ID for the web servers"
  value = aws_security_group.web_sg.id
}

output "rds_sg_id" {
  description = "Security group ID for RDS"
  value = aws_security_group.rds_sg.id
}