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

output "hr_frontend_ecr_url" {
  description = "ECR repository URL for the HR frontend image"
  value       = aws_ecr_repository.hr_frontend.repository_url
}

output "hr_backend_ecr_url" {
  description = "ECR repository URL for the HR backend image"
  value       = aws_ecr_repository.hr_backend.repository_url
}

output "hr_db_secret_arn" {
  description = "ARN of the HR database secret in Secrets Manager"
  value       = aws_secretsmanager_secret.hr_db.arn
}

output "lifecycle_api_endpoint" {
  description = "API Gateway endpoint for triggering onboarding and offboarding workflows"
  value       = aws_apigatewayv2_api.lifecycle.api_endpoint
}

output "onboarding_function_name" {
  description = "Name of the onboarding Lambda function"
  value       = aws_lambda_function.onboarding.function_name
}

output "offboarding_function_name" {
  description = "Name of the offboarding Lambda function"
  value       = aws_lambda_function.offboarding.function_name
}

output "k3s_instance_id" {
  description = "Instance ID of the k3s node — used for SSM Session Manager access"
  value       = aws_instance.k3s.id
}

output "k3s_private_ip" {
  description = "Private IP of the k3s node"
  value       = aws_instance.k3s.private_ip
}