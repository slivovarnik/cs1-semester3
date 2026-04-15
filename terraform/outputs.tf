output "public_vpc_id" {
  description = "ID of the public/DMZ VPC"
  value       = aws_vpc.public.id
}

output "shared_vpc_id" {
  description = "ID of the shared services VPC"
  value       = aws_vpc.shared.id
}

output "public_vpc_cidr" {
  description = "CIDR block of the public/DMZ VPC"
  value       = aws_vpc.public.cidr_block
}

output "shared_vpc_cidr" {
  description = "CIDR block of the shared services VPC"
  value       = aws_vpc.shared.cidr_block
}

output "transit_gateway_id" {
  description = "Transit Gateway ID"
  value       = aws_ec2_transit_gateway.tgw.id
}

output "public_tgw_attachment_id" {
  description = "Transit Gateway attachment ID for the public/DMZ VPC"
  value       = aws_ec2_transit_gateway_vpc_attachment.public_attach.id
}

output "shared_tgw_attachment_id" {
  description = "Transit Gateway attachment ID for the shared services VPC"
  value       = aws_ec2_transit_gateway_vpc_attachment.shared_attach.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs in the public/DMZ VPC"
  value = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]
}

output "app_subnet_ids" {
  description = "Private app/SOAR subnet IDs in the shared services VPC"
  value = [
    aws_subnet.app_a.id,
    aws_subnet.app_b.id
  ]
}

output "db_subnet_ids" {
  description = "Private database subnet IDs in the shared services VPC"
  value = [
    aws_subnet.db_a.id,
    aws_subnet.db_b.id
  ]
}

output "monitoring_subnet_ids" {
  description = "Private monitoring subnet IDs in the shared services VPC"
  value = [
    aws_subnet.mon_a.id,
    aws_subnet.mon_b.id
  ]
}

output "public_route_table_id" {
  description = "Route table ID for the public/DMZ VPC"
  value       = aws_route_table.public_rt.id
}

output "shared_route_table_id" {
  description = "Route table ID for the shared services VPC"
  value       = aws_route_table.shared_rt.id
}

output "s3_vpc_endpoint_id" {
  description = "Gateway endpoint ID for S3"
  value       = aws_vpc_endpoint.s3.id
}

output "secretsmanager_vpc_endpoint_id" {
  description = "Interface endpoint ID for Secrets Manager"
  value       = aws_vpc_endpoint.secretsmanager.id
}

output "logs_vpc_endpoint_id" {
  description = "Interface endpoint ID for CloudWatch Logs"
  value       = aws_vpc_endpoint.logs.id
}

output "ecr_api_vpc_endpoint_id" {
  description = "Interface endpoint ID for ECR API"
  value       = aws_vpc_endpoint.ecr_api.id
}

output "ecr_dkr_vpc_endpoint_id" {
  description = "Interface endpoint ID for ECR Docker"
  value       = aws_vpc_endpoint.ecr_dkr.id
}

output "sns_vpc_endpoint_id" {
  description = "Interface endpoint ID for SNS"
  value       = aws_vpc_endpoint.sns.id
}

output "sqs_vpc_endpoint_id" {
  description = "Interface endpoint ID for SQS"
  value       = aws_vpc_endpoint.sqs.id
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

output "db_secret_name" {
  description = "Secrets Manager secret name for DB credentials"
  value       = aws_secretsmanager_secret.db_credentials.name
}

output "incident_writer_lambda_name" {
  description = "Lambda function name for incident writer"
  value       = aws_lambda_function.incident_writer.function_name
}

output "notifier_lambda_name" {
  description = "Lambda function name for notifier"
  value       = aws_lambda_function.notifier.function_name
}

output "soar_ecr_repository_url" {
  description = "ECR repository URL for the SOAR app"
  value       = aws_ecr_repository.soar.repository_url
}

output "soar_ecs_cluster_name" {
  description = "ECS cluster name for SOAR"
  value       = aws_ecs_cluster.soar.name
}

output "soar_ecs_service_name" {
  description = "ECS service name for SOAR"
  value       = aws_ecs_service.soar.name
}

output "soar_log_group_name" {
  description = "CloudWatch log group for SOAR ECS service"
  value       = aws_cloudwatch_log_group.soar.name
}

output "ecs_task_role_arn" {
  description = "IAM role ARN used by the ECS SOAR task"
  value       = aws_iam_role.ecs_task_role.arn
}

output "soar_alb_dns_name" {
  description = "DNS name of the SOAR ALB"
  value       = aws_lb.soar_alb.dns_name
}

output "cloudwatch_dashboard_name" {
  description = "CloudWatch dashboard name"
  value       = aws_cloudwatch_dashboard.main.dashboard_name
}