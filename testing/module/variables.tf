variable "app_name" {}
variable "ami_id" {}
variable "instance_size" {}

variable "instance_http_port" {}

variable "elb_http_port" {}

variable "private_subnets" {}
variable "public_subnets" {}
variable "vpc_id" {}
variable "vpc_name" {}
variable "vpc_cidr" {}
variable "office_access_sg" {}

variable "asg_min" {}
variable "asg_max" {}

variable "asg_hc_mode" {
  default = "EC2"
}

variable "tag_environment" {}
variable "tag_country" {}
variable "dns_domain_name" {}
variable "dns_public_zone_id" {}

variable "bastion-priv-ip" {}
