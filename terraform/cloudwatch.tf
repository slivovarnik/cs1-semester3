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
  alarm_description   = "ALB has unhealthy targets"

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
      }
    ]
  })
}