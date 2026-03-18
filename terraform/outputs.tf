output "vpc_id" {
  description = "ID of the main VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]
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
  value       = aws_nat_gateway.nat.id
}

output "alb_sg_id" {
  description = "Security group ID for the ALB"
  value       = aws_security_group.alb_sg.id
}

output "web_sg_id" {
  description = "Security group ID for the web servers"
  value       = aws_security_group.web_sg.id
}

output "rds_sg_id" {
  description = "Security group ID for RDS"
  value       = aws_security_group.rds_sg.id
}

output "web1_instance_id" {
  description = "Instance ID of web server 1"
  value       = aws_instance.web1.id
}

output "web2_instance_id" {
  description = "Instance ID of web server 2"
  value       = aws_instance.web2.id
}

output "web1_private_ip" {
  description = "Private IP of web server 1"
  value       = aws_instance.web1.private_ip
}

output "web2_private_ip" {
  description = "Private IP of web server 2"
  value       = aws_instance.web2.private_ip
}

output "alb_dns_name" {
  description = "DNS name of the application load balancer"
  value       = aws_lb.app_alb.dns_name
}

output "alb_target_group_arn" {
  description = "ARN of the ALB target group"
  value       = aws_lb_target_group.web_tg.arn
}

output "db_cluster_endpoint" {
  description = "Writer endpoint of the Aurora PostgreSQL cluster"
  value       = aws_rds_cluster.aurora_pg.endpoint
}

output "db_reader_endpoint" {
  description = "Reader endpoint of the Aurora PostgreSQL cluster"
  value       = aws_rds_cluster.aurora_pg.reader_endpoint
}

output "db_name" {
  description = "Database name"
  value       = aws_rds_cluster.aurora_pg.database_name
}

output "db_port" {
  description = "Database port"
  value       = aws_rds_cluster.aurora_pg.port
}

output "cloudwatch_dashboard_name" {
  description = "CloudWatch dashboard name"
  value       = aws_cloudwatch_dashboard.main.dashboard_name
}
