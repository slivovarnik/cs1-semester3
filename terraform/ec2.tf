data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["137112412989"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "web1" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.web_a.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  associate_public_ip_address = false

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd php

              systemctl enable httpd
              systemctl start httpd

              cat > /var/www/html/index.php <<'PHP'
              <?php
              $hostname = gethostname();
              echo "<h1>Case Study MVP</h1>";
              echo "<p>Served by: <strong>$hostname</strong></p>";
              echo "<p>Web server is running successfully.</p>";
              echo "<p>Database connection will be added later.</p>";
              ?>
              PHP
              EOF

  tags = {
    Name    = "${var.project}-web1"
    Project = var.project
    Role    = "web"
  }
}

resource "aws_instance" "web2" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.web_b.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  associate_public_ip_address = false

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd php

              systemctl enable httpd
              systemctl start httpd

              cat > /var/www/html/index.php <<'PHP'
              <?php
              $hostname = gethostname();
              echo "<h1>Case Study MVP</h1>";
              echo "<p>Served by: <strong>$hostname</strong></p>";
              echo "<p>Web server is running successfully.</p>";
              echo "<p>Database connection will be added later.</p>";
              ?>
              PHP
              EOF

  tags = {
    Name    = "${var.project}-web2"
    Project = var.project
    Role    = "web"
  }
}