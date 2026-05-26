# EC2 instance for k3s Kubernetes cluster
# Runs a lightweight Kubernetes distribution without needing EKS
# Chosen because EKS is blocked by the school account SCP
# k3s provides real Kubernetes — same manifests, same kubectl commands
# at a fraction of the cost of a managed cluster
resource "aws_instance" "k3s" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = "t3.medium"
  subnet_id              = aws_subnet.svc_a.id
  vpc_security_group_ids = [aws_security_group.k3s_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.k3s_profile.name

  associate_public_ip_address = false
  key_name                    = null

  user_data = <<-EOF
    #!/bin/bash
    # Install k3s with Flannel CNI
    # --disable traefik because we use a simple NodePort approach
    # --disable servicelb because we handle routing ourselves
    curl -sfL https://get.k3s.io | sh -s - \
      --disable traefik \
      --disable servicelb \
      --write-kubeconfig-mode 644

    # Wait for k3s to be ready
    until kubectl get nodes | grep -q Ready; do
      sleep 5
    done

    # Install Calico for NetworkPolicy support
    kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/calico.yaml

    echo "k3s setup complete"
  EOF

  tags = {
    Name    = "${var.project}-k3s"
    Project = var.project
    Role    = "kubernetes"
  }
}

# IAM instance profile for k3s node
# Gives the k3s instance permissions to access ECR and Secrets Manager
# This replaces IRSA from the EKS design
resource "aws_iam_instance_profile" "k3s_profile" {
  name = "${var.project}-k3s-profile"
  role = aws_iam_role.k3s_role.name
}

# IAM role for k3s instance
resource "aws_iam_role" "k3s_role" {
  name = "${var.project}-k3s-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })

  tags = {
    Name    = "${var.project}-k3s-role"
    Project = var.project
  }
}

# Allow k3s instance to pull images from ECR
resource "aws_iam_role_policy_attachment" "k3s_ecr" {
  role       = aws_iam_role.k3s_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Allow k3s instance to use SSM for remote access
# This replaces SSH key pairs — you connect through SSM Session Manager
resource "aws_iam_role_policy_attachment" "k3s_ssm" {
  role       = aws_iam_role.k3s_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Allow k3s instance to read Secrets Manager
# Backend pods use this to get database credentials
resource "aws_iam_role_policy" "k3s_secrets" {
  name = "${var.project}-k3s-secrets"
  role = aws_iam_role.k3s_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue"]
      Resource = aws_secretsmanager_secret.hr_db.arn
    }]
  })
}

# ECR repository for HR frontend
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

# ECR repository for HR backend
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