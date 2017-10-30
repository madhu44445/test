# Configure the AWS Provider
provider "aws" {
  region = "${var.aws_region}"
  profile = "internal"
}

/*provider "aws" {
  alias = "prod"
  region = "${var.aws_region}"
  profile = "prod"
}*/

# Store terraform state to S3
terraform {
  required_version = "0.9.11"
  backend "s3" {
    bucket = "amp-state"
    key    = "apps/dev/1st_app_name.tfstate"
    region = "eu-west-1"
  }
}
# Import VPC state
data "terraform_remote_state" "network" {
  backend = "s3"
  config {
    bucket = "amp-state"
    key    = "network/network.dev.tfstate"
    region = "eu-west-1"
  }
}

# Import Route53 state
data "terraform_remote_state" "route53" {
  backend = "s3"
  config {
    bucket = "amp-state"
    key    = "route53/dev-qa/route53.bigcontent-cloud.tfstate"
    region = "eu-west-1"
  }
}

module "app_name" {
  source = "../module"

  # network settings
  vpc_name = "${var.vpc_name}"
  vpc_id = "${data.terraform_remote_state.network.vpc-id}"
  vpc_cidr = "${data.terraform_remote_state.network.vpc-cidr}"
  private_subnets = "${data.terraform_remote_state.network.private-subnets}"
  public_subnets = "${data.terraform_remote_state.network.public-subnets}"
  office_access_sg = "${data.terraform_remote_state.network.office_access_sg}"

  # intance size
  instance_size = "t2.micro"

  # app specific settings
  app_name = "app-name"
  ami_id = "ami-c77dbabe"  # Hello Universe image
  instance_http_port = "80"
  elb_http_port = "443"
  bastion-priv-ip = "${var.bastion-priv-ip}"

  # tag settings
  tag_environment = "${var.tag_environment}"
  tag_country = "${var.tag_country}"

  # ASG scaling restrictions
  asg_min = 1
  asg_max = 1

  # DNS configuration
  dns_public_zone_id = "${data.terraform_remote_state.route53.route53-dev-bigcontent-cloud}"
  dns_domain_name = "${var.dns_domain_name}"
}

output "endpoint-elb" {
  value = "${module.app_name.endpoint_elb}"
}

output "endpoint-alb" {
  value = "${module.app_name.endpoint_alb}"
}
