resource "aws_alb" "alb" {
  name            = "${var.app_name}-public-alb-${var.tag_environment}"
  security_groups = ["${aws_security_group.lb_sg.id}",
                     "${var.office_access_sg}"]
  subnets         = ["${split(",", var.public_subnets)}"]
  internal        = false

  access_logs {
    bucket = "amp-lb-access-logs"
    prefix = "${var.tag_environment}/${var.app_name}"
  }

  tags {
    Name = "${var.app_name}-public-alb-${var.tag_environment}"
    Project = "${var.vpc_name}"
  }
}

resource "aws_alb_target_group" "alb_targets" {
  name                  = "${var.app_name}-alb-${var.tag_environment}"
  port                  = "${var.instance_http_port}"
  protocol              = "HTTP"
  vpc_id                = "${var.vpc_id}"
  deregistration_delay  = 300

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 5
    timeout             = 59
    port                = "${var.instance_http_port}"
    protocol            = "HTTP"
    path                = "/"
    interval            = 60
  }
  tags {
    Environment = "${var.tag_environment}"
  }
}

resource "aws_alb_listener" "alb_listener" {
  count             = "1"
  load_balancer_arn = "${aws_alb.alb.arn}"
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = "${data.aws_acm_certificate.star-bigcontent-cloud.arn}"
  default_action {
    target_group_arn = "${aws_alb_target_group.alb_targets.arn}"
    type             = "forward"
  }
}

resource "aws_alb_listener" "alb_listener_2" {
  count             = "1"
  load_balancer_arn = "${aws_alb.alb.arn}"
  port              = 80
  protocol          = "HTTP"
  default_action {
    target_group_arn = "${aws_alb_target_group.alb_targets.arn}"
    type             = "forward"
  }
}

############################################################
# Route53
############################################################
resource "aws_route53_record" "alb_a_record" {
  zone_id = "${var.dns_public_zone_id}"
  name = "${var.app_name}.${var.dns_domain_name}"
  type    = "A"

  alias {
    name = "dualstack.${aws_alb.alb.dns_name}"
    zone_id  = "${aws_alb.alb.zone_id}"
    evaluate_target_health = false
  }
}

output "endpoint_alb" {
  value = "${aws_route53_record.alb_a_record.fqdn}"
}
