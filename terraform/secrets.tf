# Secret for Aurora PostgreSQL credentials
# Used by the CS2 web application and SOAR components
resource "aws_secretsmanager_secret" "db_credentials" {
  name        = "${var.project}-db-credentials"
  description = "Database credentials for Aurora PostgreSQL"

  tags = {
    Name    = "${var.project}-db-credentials"
    Project = var.project
  }
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id

  secret_string = jsonencode({
    username = "postgres"
    password = var.db_password
  })
}

data "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id

  depends_on = [aws_secretsmanager_secret_version.db_credentials]
}

locals {
  db_credentials = jsondecode(data.aws_secretsmanager_secret_version.db_credentials.secret_string)
}

# Secret for the HR application database connection
# Used by the Node.js backend running on k3s
# Retrieved at runtime through the EC2 instance profile
# No credentials stored in code or manifests
resource "aws_secretsmanager_secret" "hr_db" {
  name        = "${var.project}-hr-db"
  description = "Aurora PostgreSQL connection details for the HR application"

  tags = {
    Name    = "${var.project}-hr-db"
    Project = var.project
    Role    = "hr-app"
  }
}

resource "aws_secretsmanager_secret_version" "hr_db" {
  secret_id = aws_secretsmanager_secret.hr_db.id

  secret_string = jsonencode({
    username = "postgres"
    password = var.db_password
    host     = aws_rds_cluster.aurora_pg.endpoint
    port     = 5432
    dbname   = "hrapp"
  })
}