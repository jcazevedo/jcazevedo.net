terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket = "jcazevedo-terraform-state"
  }
}

resource "aws_s3_bucket" "jcazevedo_net" {
  bucket = "jcazevedo.net"
}

resource "aws_s3_bucket_website_configuration" "jcazevedo_net" {
  bucket = aws_s3_bucket.jcazevedo_net.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "404/index.html"
  }
}

resource "aws_s3_bucket_policy" "jcazevedo_net_allow_public_access" {
  bucket = aws_s3_bucket.jcazevedo_net.bucket
  policy = data.aws_iam_policy_document.jcazevedo_net_allow_public_access.json
}

data "aws_iam_policy_document" "jcazevedo_net_allow_public_access" {
  statement {
    principals {
      type = "AWS"
      identifiers = ["*"]
    }
    actions = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.jcazevedo_net.arn}/*"]
  }
}

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
