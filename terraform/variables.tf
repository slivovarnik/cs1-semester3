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

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "alert_email" {
  description = "Email address for SOAR alerts"
  type        = string
}

variable "db_password" {
  description = "Database password for Aurora"
  type        = string
  sensitive   = true
}