resource "aws_autoscaling_group" "asg" {
  name = "${var.app_name}.${var.tag_environment}"
  min_size = "${var.asg_min}"
  max_size = "${var.asg_max}"
  health_check_grace_period = "300"
  wait_for_elb_capacity = "${var.asg_min}"
  health_check_type = "${var.asg_hc_mode}"
  force_delete = "false"
  vpc_zone_identifier = ["${split(",", var.private_subnets)}"]
  load_balancers = ["${aws_elb.elb.id}"]
  target_group_arns = ["${aws_alb_target_group.alb_targets.id}"]
  launch_configuration = "${aws_launch_configuration.lc.id}"

  tag {
    key                 = "Name"
    value               = "${var.app_name}.${var.tag_environment}"
    propagate_at_launch = true
  }

  tag {
    key                 = "environment"
    value               = "${var.tag_environment}"
    propagate_at_launch = true
  }

  tag {
    key                 = "INSTANCE_SCOPE"
    value               = "${var.app_name}"
    propagate_at_launch = true
  }

  tag {
    key                 = "datadog"
    value               = "monitored"
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = "${var.vpc_name}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Country"
    value               = "${var.tag_country}"
    propagate_at_launch = true
  }

  tag {
    key                 = "SourceLC"
    value               = "${aws_launch_configuration.lc.name}"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = "false"
  }

}

######## scheduled action ###
resource "aws_autoscaling_schedule" "scaleUp" {
    count = "${var.tag_environment == "prod-euw1" ? 0 : 1}"
    scheduled_action_name = "scaleUp"
    min_size = 1
    max_size = 1
    desired_capacity = 1
    autoscaling_group_name = "${aws_autoscaling_group.asg.name}"
    recurrence = "45 07 * * MON-FRI"
}

resource "aws_autoscaling_schedule" "scaleDown" {
    count = "${var.tag_environment == "prod-euw1" ? 0 : 1}"
    scheduled_action_name = "scaleDown"
    min_size = 0
    max_size = 0
    desired_capacity = 0
    autoscaling_group_name = "${aws_autoscaling_group.asg.name}"
    recurrence = "0 18 * * MON-FRI"
}

resource "aws_autoscaling_policy" "scaleup03secs" {
  name                   = "${var.tag_environment}-${var.app_name}-scaleup-03secs"
  policy_type            = "SimpleScaling"
  scaling_adjustment     = 2
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = "${aws_autoscaling_group.asg.name}"
}

resource "aws_autoscaling_policy" "scaleup07secs" {
  name                   = "${var.tag_environment}-${var.app_name}-scaleup-07secs"
  policy_type            = "SimpleScaling"
  scaling_adjustment     = 5
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = "${aws_autoscaling_group.asg.name}"
}

resource "aws_autoscaling_policy" "scaledown" {
  name                   = "${var.tag_environment}-${var.app_name}-scaledown"
  policy_type            = "SimpleScaling"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 120
  autoscaling_group_name = "${aws_autoscaling_group.asg.name}"
}
