output "workload_vpc_id" {
  description = "ID of the Workload VPC"
  value       = aws_vpc.workload.id
}

output "data_vpc_id" {
  description = "ID of the Data VPC"
  value       = aws_vpc.data.id
}

output "transit_gateway_id" {
  description = "ID of the Transit Gateway"
  value       = aws_ec2_transit_gateway.main.id
}

output "alb_dns_name" {
  description = "DNS name of the public Application Load Balancer"
  value       = aws_lb.app_alb.dns_name
}

output "aurora_writer_endpoint" {
  description = "Writer endpoint for the Aurora PostgreSQL cluster"
  value       = aws_rds_cluster.aurora_pg.endpoint
}

output "aurora_reader_endpoint" {
  description = "Reader endpoint for the Aurora PostgreSQL cluster"
  value       = aws_rds_cluster.aurora_pg.reader_endpoint
}

output "soar_ecs_cluster_name" {
  description = "Name of the ECS cluster hosting the SOAR service"
  value       = aws_ecs_cluster.soar.name
}

output "soar_ecs_service_name" {
  description = "Name of the ECS SOAR service"
  value       = aws_ecs_service.soar.name
}

output "soar_ecr_repository_url" {
  description = "URL of the SOAR ECR repository"
  value       = aws_ecr_repository.soar.repository_url
}

output "client_vpn_endpoint_id" {
  description = "ID of the AWS Client VPN endpoint"
  value       = aws_ec2_client_vpn_endpoint.main.id
}

output "client_vpn_dns_name" {
  description = "DNS name of the AWS Client VPN endpoint"
  value       = aws_ec2_client_vpn_endpoint.main.dns_name
}