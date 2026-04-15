data "archive_file" "incident_writer_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/incident_writer.py"
  output_path = "${path.module}/lambda/incident_writer.zip"
}

data "archive_file" "notifier_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/notifier.py"
  output_path = "${path.module}/lambda/notifier.zip"
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "${var.project}-lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name    = "${var.project}-lambda-exec-role"
    Project = var.project
    Role    = "lambda"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "incident_writer" {
  function_name = "${var.project}-incident-writer"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "incident_writer.lambda_handler"
  runtime       = "python3.12"

  filename         = data.archive_file.incident_writer_zip.output_path
  source_code_hash = data.archive_file.incident_writer_zip.output_base64sha256

  timeout = 10

  tags = {
    Name    = "${var.project}-incident-writer"
    Project = var.project
    Role    = "lambda"
  }
}

resource "aws_lambda_function" "notifier" {
  function_name = "${var.project}-notifier"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "notifier.lambda_handler"
  runtime       = "python3.12"

  filename         = data.archive_file.notifier_zip.output_path
  source_code_hash = data.archive_file.notifier_zip.output_base64sha256

  timeout = 10

  tags = {
    Name    = "${var.project}-notifier"
    Project = var.project
    Role    = "lambda"
  }
}