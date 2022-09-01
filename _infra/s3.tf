resource "aws_s3_bucket" "jcazevedo_net" {
  bucket = "jcazevedo.net"
}

resource "aws_s3_bucket" "www_jcazevedo_net" {
  bucket = "www.jcazevedo.net"
}

resource "aws_s3_bucket_cors_configuration" "jcazevedo_net" {
  bucket = aws_s3_bucket.jcazevedo_net.id
  cors_rule {
    allowed_headers = ["Authorization", "Content-Length"]
    allowed_methods = ["GET", "POST"]
    allowed_origins = ["https://jcazevedo.net"]
    max_age_seconds = 3000
  }
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

resource "aws_s3_bucket_website_configuration" "www_jcazevedo_net" {
  bucket = aws_s3_bucket.www_jcazevedo_net.bucket
  redirect_all_requests_to {
    host_name = "jcazevedo.net"
  }
}

resource "aws_s3_bucket_policy" "jcazevedo_net_allow_public_access" {
  bucket = aws_s3_bucket.jcazevedo_net.bucket
  policy = data.aws_iam_policy_document.jcazevedo_net_allow_public_access.json
}

resource "aws_s3_bucket_policy" "www_jcazevedo_net_allow_public_access" {
  bucket = aws_s3_bucket.www_jcazevedo_net.bucket
  policy = data.aws_iam_policy_document.www_jcazevedo_net_allow_public_access.json
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

data "aws_iam_policy_document" "www_jcazevedo_net_allow_public_access" {
  statement {
    principals {
      type = "AWS"
      identifiers = ["*"]
    }
    actions = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.www_jcazevedo_net.arn}/*"]
  }
}
