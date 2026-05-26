# OIDC provider so GitHub Actions can authenticate 
# with AWS without storing long-lived credentials
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  # These are GitHub's official thumbprints
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd"
  ]

  tags = {
    Name    = "${var.project}-github-oidc"
    Project = var.project
  }
}

# IAM role that GitHub Actions assumes during pipeline runs
resource "aws_iam_role" "github_actions_terraform" {
  name = "github-actions-terraform"

  # Trust policy — only your specific GitHub repo 
  # can assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:slivovarnik/cs1-semester3:*"
          }
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = {
    Name    = "github-actions-terraform"
    Project = var.project
  }
}

# Admin access for the GitHub Actions role
# so it can create and manage all infrastructure
resource "aws_iam_role_policy_attachment" "github_actions_admin" {
  role       = aws_iam_role.github_actions_terraform.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}