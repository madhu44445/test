# security group to allow internal elb to talk to servers
resource "aws_security_group" "lb_sg" {
  name = "${var.app_name}-lb.${var.tag_environment}"
  description = "Controls traffic to visit the ${var.tag_environment} load balancer for ${var.app_name}"
  vpc_id = "${var.vpc_id}"

  tags {
    Name = "${var.app_name}-lb.${var.tag_environment}"
    Project = "${var.vpc_name}"
  }

  lifecycle {
    create_before_destroy = "true"
  }
}

# ingress rule
resource "aws_security_group_rule" "lb_ingress" {
  type = "ingress"
  from_port = "${var.elb_http_port}"
  to_port = "${var.elb_http_port}"
  protocol = "tcp"
  security_group_id = "${aws_security_group.lb_sg.id}"
  cidr_blocks = ["${var.vpc_cidr}"]  # add this line when internal communication is needed
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "instance_egress" {
  type = "egress"
  from_port = "${var.instance_http_port}"
  to_port = "${var.instance_http_port}"
  protocol = "tcp"
  security_group_id = "${aws_security_group.lb_sg.id}"
  cidr_blocks = ["0.0.0.0/0"]
}
