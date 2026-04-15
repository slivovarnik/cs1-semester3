resource "aws_lb" "soar_alb" {
  name               = "${var.project}-soar-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.edge_alb_sg.id]

  subnets = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]

  tags = {
    Name    = "${var.project}-soar-alb"
    Project = var.project
    Role    = "alb"
  }
}

resource "aws_lb_target_group" "soar_tg" {
  name        = "${var.project}-soar-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.shared.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    timeout             = 5
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
  }

  tags = {
    Name    = "${var.project}-soar-tg"
    Project = var.project
    Role    = "alb"
  }
}

resource "aws_lb_listener" "soar_http" {
  load_balancer_arn = aws_lb.soar_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.soar_tg.arn
  }
}