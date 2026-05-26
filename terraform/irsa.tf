# OIDC provider for EKS cluster
# Required for IRSA to work - tells AWS to trust the EKS cluster
# as an identity provider so pods can assume IAM roles
resource "aws_iam_openid_connect_provider" "eks_oidc" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer

  client_id_list = ["sts.amazonaws.com"]

  thumbprint_list = [
    "9e99a48a9960b14926bb7f3b02e22da2b0ab7280"
  ]

  tags = {
    Name    = "${var.project}-eks-oidc"
    Project = var.project
  }
}

# IRSA role for the HR backend pods
# Only backend pods using the hr-backend-sa service account
# can assume this role - no other pods get these permissions
# This is least privilege IAM at the pod level
# Satisfies REQ-NCA-P3-06 Zero Trust
resource "aws_iam_role" "hr_backend_irsa" {
  name = "${var.project}-hr-backend-irsa"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.eks_oidc.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:hr-app:hr-backend-sa"
          "${replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })

  tags = {
    Name    = "${var.project}-hr-backend-irsa"
    Project = var.project
  }
}

# Policy giving the backend role permission to read
# only the HR database secret - nothing else
resource "aws_iam_role_policy" "hr_backend_secrets" {
  name = "${var.project}-hr-backend-secrets-policy"
  role = aws_iam_role.hr_backend_irsa.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "secretsmanager:GetSecretValue"
      ]
      Resource = aws_secretsmanager_secret.hr_db.arn
    }]
  })
}