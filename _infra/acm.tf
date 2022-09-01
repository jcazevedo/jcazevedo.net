resource "aws_acm_certificate" "ssl_certificate" {
  domain_name = "jcazevedo.net"
  subject_alternative_names = ["*.jcazevedo.net"]
  validation_method = "EMAIL"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn = aws_acm_certificate.ssl_certificate.arn
}
