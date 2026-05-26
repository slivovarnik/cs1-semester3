# Package the onboarding Lambda function into a ZIP file
# Terraform uses the archive provider to create deployable packages
# This is the same pattern used for the CS2 Lambda functions
data "archive_file" "onboarding_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/onboarding.py"
  output_path = "${path.module}/lambda/onboarding.zip"
}

# Package the offboarding Lambda function
data "archive_file" "offboarding_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/offboarding.py"
  output_path = "${path.module}/lambda/offboarding.zip"
}

# IAM role for the lifecycle Lambda functions
# Separate from the CS2 Lambda role to follow least privilege
# These functions need IAM Identity Center permissions
# which the CS2 functions do not need
resource "aws_iam_role" "lifecycle_lambda_role" {
  name = "${var.project}-lifecycle-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })

  tags = {
    Name    = "${var.project}-lifecycle-lambda-role"
    Project = var.project
    Role    = "lambda"
  }
}

# Basic execution policy for CloudWatch Logs
resource "aws_iam_role_policy_attachment" "lifecycle_lambda_basic" {
  role       = aws_iam_role.lifecycle_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Policy for IAM Identity Center operations
# Onboarding needs to create users and add group memberships
# Offboarding needs to list users, remove memberships, and disable accounts
resource "aws_iam_role_policy" "lifecycle_lambda_sso" {
  name = "${var.project}-lifecycle-lambda-sso"
  role = aws_iam_role.lifecycle_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "identitystore:CreateUser",
          "identitystore:ListUsers",
          "identitystore:UpdateUser",
          "identitystore:CreateGroupMembership",
          "identitystore:DeleteGroupMembership",
          "identitystore:ListGroupMemberships",
          "identitystore:ListGroupMembershipsForMember",
          "identitystore:ListGroups",
          "sso-admin:ListInstances"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${var.region}:*:log-group:/innovatech/hr/audit:*"
      }
    ]
  })
}

# Onboarding Lambda function
# Triggered by API Gateway when a new employee is added
# Creates IAM Identity Center account and assigns group membership
resource "aws_lambda_function" "onboarding" {
  function_name = "${var.project}-onboarding"
  role          = aws_iam_role.lifecycle_lambda_role.arn
  handler       = "onboarding.lambda_handler"
  runtime       = "python3.12"

  filename         = data.archive_file.onboarding_zip.output_path
  source_code_hash = data.archive_file.onboarding_zip.output_base64sha256

  timeout = 30

 environment {
  variables = {
    IDENTITY_STORE_ID = var.identity_store_id
    SSO_INSTANCE_ARN  = var.sso_instance_arn
    AUDIT_LOG_GROUP   = "/innovatech/hr/audit"
  }
}

  tags = {
    Name    = "${var.project}-onboarding"
    Project = var.project
    Role    = "lambda"
  }
}

# Offboarding Lambda function
# Triggered by API Gateway when an employee is offboarded
# Disables IAM Identity Center account and removes group memberships
resource "aws_lambda_function" "offboarding" {
  function_name = "${var.project}-offboarding"
  role          = aws_iam_role.lifecycle_lambda_role.arn
  handler       = "offboarding.lambda_handler"
  runtime       = "python3.12"

  filename         = data.archive_file.offboarding_zip.output_path
  source_code_hash = data.archive_file.offboarding_zip.output_base64sha256

  timeout = 30

  environment {
  variables = {
    IDENTITY_STORE_ID = var.identity_store_id
    AUDIT_LOG_GROUP   = "/innovatech/hr/audit"
  }
}

  tags = {
    Name    = "${var.project}-offboarding"
    Project = var.project
    Role    = "lambda"
  }
}

# API Gateway for triggering lifecycle functions
# Provides HTTP endpoints that the HR application and
# administrators can call to trigger onboarding and offboarding
resource "aws_apigatewayv2_api" "lifecycle" {
  name          = "${var.project}-lifecycle-api"
  protocol_type = "HTTP"
  description   = "API Gateway for HR employee lifecycle automation"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["POST", "OPTIONS"]
    allow_headers = ["Content-Type"]
  }

  tags = {
    Name    = "${var.project}-lifecycle-api"
    Project = var.project
  }
}

# Auto-deploy stage for the API Gateway
resource "aws_apigatewayv2_stage" "lifecycle" {
  api_id      = aws_apigatewayv2_api.lifecycle.id
  name        = "$default"
  auto_deploy = true

  tags = {
    Name    = "${var.project}-lifecycle-stage"
    Project = var.project
  }
}

# Integration for onboarding Lambda
resource "aws_apigatewayv2_integration" "onboarding" {
  api_id             = aws_apigatewayv2_api.lifecycle.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.onboarding.invoke_arn
  integration_method = "POST"
}

# Integration for offboarding Lambda
resource "aws_apigatewayv2_integration" "offboarding" {
  api_id             = aws_apigatewayv2_api.lifecycle.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.offboarding.invoke_arn
  integration_method = "POST"
}

# Route for onboarding — POST /onboard
resource "aws_apigatewayv2_route" "onboarding" {
  api_id    = aws_apigatewayv2_api.lifecycle.id
  route_key = "POST /onboard"
  target    = "integrations/${aws_apigatewayv2_integration.onboarding.id}"
}

# Route for offboarding — POST /offboard
resource "aws_apigatewayv2_route" "offboarding" {
  api_id    = aws_apigatewayv2_api.lifecycle.id
  route_key = "POST /offboard"
  target    = "integrations/${aws_apigatewayv2_integration.offboarding.id}"
}

# Permission for API Gateway to invoke onboarding Lambda
resource "aws_lambda_permission" "onboarding" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.onboarding.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.lifecycle.execution_arn}/*/*"
}

# Permission for API Gateway to invoke offboarding Lambda
resource "aws_lambda_permission" "offboarding" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.offboarding.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.lifecycle.execution_arn}/*/*"
}