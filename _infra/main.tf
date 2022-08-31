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
