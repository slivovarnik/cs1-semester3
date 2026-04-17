resource "aws_cloudwatch_metric_alarm" "web1_cpu_high" {
  alarm_name          = "${var.project}-web1-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "High CPU on web1"

  dimensions = {
    InstanceId = aws_instance.web1.id
  }
}

resource "aws_cloudwatch_metric_alarm" "web2_cpu_high" {
  alarm_name          = "${var.project}-web2-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "High CPU on web2"

  dimensions = {
    InstanceId = aws_instance.web2.id
  }
}

resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_hosts" {
  alarm_name          = "${var.project}-alb-unhealthy-hosts"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Average"
  threshold           = 0
  alarm_description   = "ALB has unhealthy web targets"

  dimensions = {
    LoadBalancer = aws_lb.app_alb.arn_suffix
    TargetGroup  = aws_lb_target_group.web_tg.arn_suffix
  }
}

resource "aws_cloudwatch_metric_alarm" "aurora_writer_cpu_high" {
  alarm_name          = "${var.project}-aurora-writer-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "High CPU on Aurora writer"

  dimensions = {
    DBInstanceIdentifier = aws_rds_cluster_instance.writer.id
  }
}

resource "aws_cloudwatch_metric_alarm" "soar_ecs_cpu_high" {
  alarm_name          = "${var.project}-soar-ecs-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "High CPU utilization on SOAR ECS service"

  dimensions = {
    ClusterName = aws_ecs_cluster.soar.name
    ServiceName = aws_ecs_service.soar.name
  }
}

resource "aws_cloudwatch_metric_alarm" "soar_ecs_memory_high" {
  alarm_name          = "${var.project}-soar-ecs-memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "High memory utilization on SOAR ECS service"

  dimensions = {
    ClusterName = aws_ecs_cluster.soar.name
    ServiceName = aws_ecs_service.soar.name
  }
}

resource "aws_cloudwatch_log_metric_filter" "unauthorized_access" {
  name           = "${var.project}-unauthorized-access-filter"
  log_group_name = aws_cloudwatch_log_group.soar.name
  pattern        = "\"UNAUTHORIZED_ACCESS\""

  metric_transformation {
    name      = "UnauthorizedAccessCount"
    namespace = "${var.project}/SOAR"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "unauthorized_access_detected" {
  alarm_name          = "${var.project}-unauthorized-access-detected"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "UnauthorizedAccessCount"
  namespace           = "${var.project}/SOAR"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Unauthorized access attempt detected in SOAR logs"
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "EC2 CPU"
          view   = "timeSeries"
          region = var.region
          metrics = [
            ["AWS/EC2", "CPUUtilization", "InstanceId", aws_instance.web1.id],
            [".", ".", "InstanceId", aws_instance.web2.id]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "ALB Health"
          view   = "timeSeries"
          region = var.region
          metrics = [
            ["AWS/ApplicationELB", "HealthyHostCount", "LoadBalancer", aws_lb.app_alb.arn_suffix, "TargetGroup", aws_lb_target_group.web_tg.arn_suffix],
            [".", "UnHealthyHostCount", ".", ".", ".", "."]
          ]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "ALB Requests"
          view   = "timeSeries"
          region = var.region
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", aws_lb.app_alb.arn_suffix]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "Aurora Writer CPU"
          view   = "timeSeries"
          region = var.region
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", aws_rds_cluster_instance.writer.id]
          ]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6
        properties = {
          title  = "SOAR ECS CPU and Memory"
          view   = "timeSeries"
          region = var.region
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ClusterName", aws_ecs_cluster.soar.name, "ServiceName", aws_ecs_service.soar.name],
            [".", "MemoryUtilization", ".", ".", ".", "."]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 12
        width  = 12
        height = 6
        properties = {
          title  = "Unauthorized Access Events"
          view   = "timeSeries"
          region = var.region
          metrics = [
            ["${var.project}/SOAR", "UnauthorizedAccessCount"]
          ]
        }
      }
    ]
  })
}