resource "aws_route53_zone" "jcazevedo_net" {
  name = "jcazevedo.net"
}

resource "aws_route53_record" "jcazevedo_net-a" {
  zone_id = aws_route53_zone.jcazevedo_net.zone_id
  name    = "jcazevedo.net"
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.root_s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.root_s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www_jcazevedo_net-a" {
  zone_id = aws_route53_zone.jcazevedo_net.zone_id
  name    = "www.jcazevedo.net"
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.www_s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.www_s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "jcazevedo-net-ssl-validation" {
  allow_overwrite = true
  name            = tolist(aws_acm_certificate.ssl_certificate.domain_validation_options)[0].resource_record_name
  records         = [tolist(aws_acm_certificate.ssl_certificate.domain_validation_options)[0].resource_record_value]
  type            = tolist(aws_acm_certificate.ssl_certificate.domain_validation_options)[0].resource_record_type
  zone_id         = aws_route53_zone.jcazevedo_net.zone_id
  ttl             = 60
}

resource "aws_route53_record" "jcazevedo_net-google-confirmation" {
  zone_id = aws_route53_zone.jcazevedo_net.zone_id
  type    = "TXT"
  name    = ""
  records = ["google-site-verification=n47CU2GGpbQm1rSAlSAfx8sAueJE2KeTikyBgKMK964"]
  ttl     = 60
}
