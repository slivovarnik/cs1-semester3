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

output "k8s_vpc_id" {
  description = "ID of the Kubernetes VPC"
  value       = aws_vpc.k8s.id
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.main.name
}

output "eks_cluster_endpoint" {
  description = "Endpoint of the EKS cluster"
  value       = aws_eks_cluster.main.endpoint
}

output "hr_frontend_ecr_url" {
  description = "ECR repository URL for the HR frontend image — used in Docker push commands and Kubernetes manifests"
  value       = aws_ecr_repository.hr_frontend.repository_url
}

output "hr_backend_ecr_url" {
  description = "ECR repository URL for the HR backend image — used in Docker push commands and Kubernetes manifests"
  value       = aws_ecr_repository.hr_backend.repository_url
}

output "hr_db_secret_arn" {
  description = "ARN of the HR database secret in Secrets Manager — used in the backend deployment environment variable"
  value       = aws_secretsmanager_secret.hr_db.arn
}

output "hr_backend_irsa_role_arn" {
  description = "ARN of the IRSA IAM role for HR backend pods — used in the Kubernetes service account annotation"
  value       = aws_iam_role.hr_backend_irsa.arn
}

output "k8s_subnet_a_id" {
  description = "ID of the Kubernetes private subnet in AZ-A — used in the Ingress annotation for internal ALB placement"
  value       = aws_subnet.k8s_a.id
}

output "k8s_subnet_b_id" {
  description = "ID of the Kubernetes private subnet in AZ-B — used in the Ingress annotation for internal ALB placement"
  value       = aws_subnet.k8s_b.id
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