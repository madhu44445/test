resource "aws_launch_configuration" "lc" {
  name_prefix = "${var.app_name}.${var.tag_environment}-"
  image_id = "${var.ami_id}"
  instance_type = "${var.instance_size}"
  key_name = "${var.tag_environment}"
  security_groups = ["${aws_security_group.sg.id}"]
  user_data = "${data.template_file.instance_userdata.rendered}"
  iam_instance_profile = "${aws_iam_instance_profile.profile_1.id}"
  enable_monitoring = false

  lifecycle {
    create_before_destroy = "true"
  }
  root_block_device {
    volume_type = "gp2"
    delete_on_termination = true
  }
}

data "template_file" "instance_userdata" {
  template = "${file("${path.module}/instance-userdata.tpl")}"
}

resource "aws_security_group" "sg" {
  name = "${var.app_name}.${var.tag_environment}"
  description = "Allows access to ${var.app_name}"
  vpc_id = "${var.vpc_id}"

  tags {
    Name = "${var.app_name}.${var.tag_environment}"
    Project = "${var.vpc_name}"
  }

  # allow SSH access to the server.
  ingress {
    from_port = "22"
    to_port = "22"
    protocol = "tcp"
    cidr_blocks = ["${var.bastion-priv-ip}/32"]
  }

  ingress {
    from_port = "${var.instance_http_port}"
    to_port = "${var.instance_http_port}"
    protocol = "tcp"
    cidr_blocks = ["${var.bastion-priv-ip}/32"],
    security_groups = ["${aws_security_group.lb_sg.id}"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = "true"
  }
}

output "sg_instance" {
  value = "${aws_security_group.sg.id}"
}
