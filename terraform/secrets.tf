resource "aws_secretsmanager_secret" "db_credentials" {
  name        = "${var.project}-db-credentials-cs2"
  description = "Database credentials for Aurora PostgreSQL"

  tags = {
    Name    = "${var.project}-db-credentials-cs2"
    Project = var.project
    Role    = "secrets"
  }
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id

  secret_string = jsonencode({
    username = "postgres"
    password = "RosiCS2_DB!"
  })
}

data "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id

  depends_on = [aws_secretsmanager_secret_version.db_credentials]
}

locals {
  db_credentials = jsondecode(data.aws_secretsmanager_secret_version.db_credentials.secret_string)
}