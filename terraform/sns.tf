resource "aws_sns_topic" "soar_alerts" {
  name = "${var.project}-soar-alerts"

  tags = {
    Name    = "${var.project}-soar-alerts"
    Project = var.project
    Role    = "alerts"
  }
}

resource "aws_sns_topic_subscription" "email_alerts" {
  topic_arn = aws_sns_topic.soar_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}