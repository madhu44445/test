# aws region
variable "aws_region" {
  default = "eu-west-1"
}

# account id AMP-Internal
variable "aws_account_id" {
  default = "173365125512"
}

# vpc_name
variable "vpc_name" {
  default = "amp"
}

# vpc id to build CIDR (see README)
variable "vpc_cidr" {
  default = "120"
}

# tags
variable "tag_environment" {
  default = "dev"
}

variable "tag_country" {
  default = "GB"
}

variable "dns_domain_name" {
  default = "dev.bigcontent.cloud"
}

variable "bastion-priv-ip" {
  default = "10.25.25.25"
}
