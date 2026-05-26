# ECR repository for the HR application frontend
# Stores versioned Docker images for the React/Nginx frontend
# Using ECR keeps images private and integrates with EKS 
# through the existing VPC endpoints
resource "aws_ecr_repository" "hr_frontend" {
  name                 = "${var.project}-hr-frontend"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name    = "${var.project}-hr-frontend"
    Project = var.project
    Role    = "hr-app"
  }
}

# ECR repository for the HR application backend
# Stores versioned Docker images for the Node.js API
resource "aws_ecr_repository" "hr_backend" {
  name                 = "${var.project}-hr-backend"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name    = "${var.project}-hr-backend"
    Project = var.project
    Role    = "hr-app"
  }
}