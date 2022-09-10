resource "aws_iam_user" "github-actions" {
  name = "github-actions"
}

resource "aws_iam_access_key" "github-actions" {
  user = aws_iam_user.github-actions.name
}

output "github-actions_aws_iam_access_key_secret" {
  value = aws_iam_access_key.github-actions.secret
  sensitive = true
}

resource "aws_iam_user_policy" "github-actions" {
  name = "github-actions_policy"
  user = aws_iam_user.github-actions.name
  policy = data.aws_iam_policy_document.github-actions_policy.json
}

data "aws_iam_policy_document" "github-actions_policy" {
  statement {
    sid = "S3Access"

    actions = [
      "s3:PutBucketWebsite",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:DeleteObject"
    ]

    resources = [
      "${aws_s3_bucket.jcazevedo_net.arn}",
      "${aws_s3_bucket.www_jcazevedo_net.arn}",
      "${aws_s3_bucket.jcazevedo_net.arn}/*",
      "${aws_s3_bucket.www_jcazevedo_net.arn}/*"
    ]
  }

  statement {
    sid = "CloudFrontAccess"

    actions = [
      "cloudfront:GetInvalidation",
      "cloudfront:CreateInvalidation"
    ]

    resources = [
      "${aws_cloudfront_distribution.root_s3_distribution.arn}",
      "${aws_cloudfront_distribution.www_s3_distribution.arn}"
    ]
  }
}
