variable "region" {
  description = "AWS region where resources will be deployed"
  type        = string
  default     = "eu-central-1"
}

variable "project" {
  description = "Project name used for tagging resources"
  type        = string
  default     = "case-study"
}

variable "workload_vpc_cidr" {
  description = "CIDR block for the workload VPC"
  type        = string
  default     = "10.20.0.0/16"
}

variable "data_vpc_cidr" {
  description = "CIDR block for the data VPC"
  type        = string
  default     = "10.30.0.0/16"
}

variable "alert_email" {
  description = "Email address for SOAR alerts"
  type        = string
}

variable "db_password" {
  description = "Database password stored in Secrets Manager"
  type        = string
  sensitive   = true
}

variable "client_vpn_server_certificate_arn" {
  description = "ACM ARN of the server certificate for AWS Client VPN"
  type        = string
}

variable "client_vpn_client_root_certificate_chain_arn" {
  description = "ACM ARN used for Client VPN mutual authentication"
  type        = string
}

variable "client_vpn_cidr" {
  description = "CIDR block assigned to AWS Client VPN clients"
  type        = string
  default     = "172.16.0.0/22"
}

variable "identity_store_id" {
  description = "IAM Identity Center Identity Store ID — found in the IAM Identity Center console"
  type        = string
  default     = ""
}

variable "sso_instance_arn" {
  description = "ARN of the IAM Identity Center instance — found in the IAM Identity Center console"
  type        = string
  default     = ""
}