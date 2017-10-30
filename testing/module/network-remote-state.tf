# Get the ARN of a certificate from AWS Certificate Manager (ACM).
# ARN is used for ELB and ALB
data "aws_acm_certificate" "star-bigcontent-cloud" {
  domain   = "*.bigcontent.cloud"
  statuses = ["ISSUED"]
}

## Certificate Settings
/*resource "aws_iam_server_certificate" "import_star_adis_ws_2019" {
  name             = "some_test_cert"
  certificate_body = "${file("self-ca-cert.pem")}"
  private_key      = "${file("test-key.pem")}"
}

data "aws_iam_server_certificate" "star_adis_ws_2019" {
  name_prefix   = "star_adis_ws_2019"
  latest        = true
}*/
