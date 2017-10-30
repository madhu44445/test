resource "aws_cloudwatch_metric_alarm" "latency_03" {
  alarm_name          = "${var.tag_environment}-${var.app_name}-latency-0.3"
  alarm_description   = "Latency >= 0.3 for 3 minutes"
  alarm_actions     = ["${aws_autoscaling_policy.scaleup03secs.arn}"]
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "Latency"
  namespace           = "AWS/ELB"
  period              = "60"
  statistic           = "Average"
  threshold           = "0.3"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.asg.name}"
  }
}

resource "aws_cloudwatch_metric_alarm" "latency_07" {
  alarm_name          = "${var.tag_environment}-${var.app_name}-latency-0.7"
  alarm_description   = "Latency >= 0.7 for 2 minutes"
  alarm_actions     = ["${aws_autoscaling_policy.scaleup07secs.arn}"]
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "Latency"
  namespace           = "AWS/ELB"
  period              = "60"
  statistic           = "Average"
  threshold           = "0.7"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.asg.name}"
  }
}
