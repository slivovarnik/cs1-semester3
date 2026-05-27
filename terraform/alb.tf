# Public Application Load Balancer in the Workload VPC
resource "aws_lb" "app_alb" {
  name               = "${var.project}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]

  subnets = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]

  tags = {
    Name    = "${var.project}-alb"
    Project = var.project
  }
}

# Target group for the SOAR ECS service
resource "aws_lb_target_group" "soar_tg" {
  name        = "${var.project}-soar-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.workload.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    timeout             = 5
    path                = "/soar/health"
    protocol            = "HTTP"
    matcher             = "200"
  }

  tags = {
    Name    = "${var.project}-soar-tg"
    Project = var.project
  }
}

# Default HTTP listener for the ALB
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.soar_tg.arn
  }
}

# Listener rule for SOAR paths
resource "aws_lb_listener_rule" "soar_paths" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.soar_tg.arn
  }

  condition {
    path_pattern {
      values = ["/soar/*"]
    }
  }
}