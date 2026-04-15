resource "aws_ecr_repository" "soar" {
  name                 = "${var.project}-soar"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name    = "${var.project}-soar"
    Project = var.project
    Role    = "soar"
  }
}