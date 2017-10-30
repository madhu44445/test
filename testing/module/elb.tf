resource "aws_elb" "elb" {
  name = "${var.app_name}-public-${var.tag_environment}"
  subnets = ["${split(",", var.public_subnets)}"]
#  subnets = ["${split(",", var.private_subnets)}"]
  security_groups = ["${aws_security_group.lb_sg.id}",
                     "${var.office_access_sg}"]
  cross_zone_load_balancing = true
#  internal = true

  connection_draining = true
  connection_draining_timeout = 300

  listener {
    lb_port = "${var.elb_http_port}"
    lb_protocol = "https"
    instance_port = "${var.instance_http_port}"
    instance_protocol = "http"
    ssl_certificate_id = "${data.aws_acm_certificate.star-bigcontent-cloud.arn}"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "TCP:${var.instance_http_port}"
    interval = 30
  }

  tags {
    Name = "${var.app_name}-public-elb-${var.tag_environment}"
    Project = "${var.vpc_name}"
  }

  lifecycle {
    create_before_destroy = "true"
  }
}

############################################################
# Route53
############################################################
resource "aws_route53_record" "elb_a_record" {
  zone_id = "${var.dns_public_zone_id}"
  name = "${var.app_name}-elb.${var.dns_domain_name}"
  type    = "A"

  alias {
    name = "dualstack.${aws_elb.elb.dns_name}"
    zone_id  = "${aws_elb.elb.zone_id}"
    evaluate_target_health = false
  }
}

output "endpoint_elb" {
  value = "${aws_route53_record.elb_a_record.fqdn}"
}
