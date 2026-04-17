# ECS cluster for SOAR services
resource "aws_ecs_cluster" "soar" {
  name = "${var.project}-soar-cluster"

  tags = {
    Name    = "${var.project}-soar-cluster"
    Project = var.project
    Role    = "soar"
  }
}

# CloudWatch log group for SOAR container logs
resource "aws_cloudwatch_log_group" "soar" {
  name              = "/ecs/${var.project}-soar"
  retention_in_days = 14
}

# ECS task execution role
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.project}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name    = "${var.project}-ecs-task-execution-role"
    Project = var.project
    Role    = "ecs"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS task role used by the SOAR app
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.project}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name    = "${var.project}-ecs-task-role"
    Project = var.project
    Role    = "ecs"
  }
}

# Custom policy for Lambda invocation and CloudWatch custom metrics
resource "aws_iam_role_policy" "ecs_invoke_lambda_policy" {
  name = "${var.project}-ecs-invoke-lambda-policy"
  role = aws_iam_role.ecs_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction"
        ]
        Resource = [
          aws_lambda_function.incident_writer.arn,
          aws_lambda_function.notifier.arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData"
        ]
        Resource = "*"
      }
    ]
  })
}

# Task definition for the SOAR container
resource "aws_ecs_task_definition" "soar" {
  family                   = "${var.project}-soar"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "soar-core"
      image     = "${aws_ecr_repository.soar.repository_url}:latest"
      essential = true

      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "INCIDENT_WRITER_FUNCTION"
          value = aws_lambda_function.incident_writer.function_name
        },
        {
          name  = "NOTIFIER_FUNCTION"
          value = aws_lambda_function.notifier.function_name
        },
        {
          name  = "AWS_REGION"
          value = var.region
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.soar.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = {
    Name    = "${var.project}-soar-taskdef"
    Project = var.project
    Role    = "soar"
  }
}

# ECS service for the SOAR container
resource "aws_ecs_service" "soar" {
  name            = "${var.project}-soar-service"
  cluster         = aws_ecs_cluster.soar.id
  task_definition = aws_ecs_task_definition.soar.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets = [
      aws_subnet.svc_a.id,
      aws_subnet.svc_b.id
    ]
    security_groups  = [aws_security_group.soar_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.soar_tg.arn
    container_name   = "soar-core"
    container_port   = 80
  }

  depends_on = [
    aws_lb_listener.http,
    aws_lb_listener_rule.soar_paths
  ]

  tags = {
    Name    = "${var.project}-soar-service"
    Project = var.project
    Role    = "soar"
  }
}