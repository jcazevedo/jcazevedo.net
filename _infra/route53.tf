resource "aws_route53_zone" "jcazevedo_net" {
  name = "jcazevedo.net"
}

resource "aws_route53_record" "jcazevedo_net-a" {
  zone_id = aws_route53_zone.jcazevedo_net.zone_id
  name = "jcazevedo.net"
  type = "A"
  alias {
    name = aws_s3_bucket.jcazevedo_net.website_endpoint
    zone_id = aws_s3_bucket.jcazevedo_net.hosted_zone_id
    evaluate_target_health = true
  }
}
