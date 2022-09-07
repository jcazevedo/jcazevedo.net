---
layout: post
title: Migrating this Website to AWS
date: 2022-09-08 00:47 +0100
---
# Migrating this Website to AWS

I've decided to migrate this website from [DreamHost][dreamhost] to [Amazon Web
Services][aws]. The main driver for this is costs. This is a static website
(consisting of only HTML, CSS, and a small portion of JavaScript) which is very
suitable to be [hosted in S3][S3 static website]. This is also a very low
traffic website, well within S3's [free tier][free tier]. Keeping up with my
current setup, I wanted to retain the following:

* Secure website hosted at [https://jcazevedo.net/](https://jcazevedo.net/) with
  a valid SSL certificate;
* Requests to [http://jcazevedo.net/](http://jcazevedo.net/) are redirected to
  [https://jcazevedo.net/](https://jcazevedo.net/);
* Requests with the `www` subdomain
  ([https://www.jcazevedo.net/](https://www.jcazevdo.net/)) are redirected to
  [https://jcazevedo.net/](https://www.jcazevedo.net/).

I also wanted to keep everything managed from within AWS, so that I could get
some infrastructure automation ([Terraform][terraform]) to help me with setting
everything up. Keeping everything managed from within AWS meant that I had to
have the `jcazevedo.net` domain transferred and have an SSL certificate
provisioned by AWS (I was previously using [Let's Encrypt][letsencrypt]). I also
didn't mind downtime (again, this is a very low traffic website).

## Setting up Terraform

It wasn't absolutely necessary to use [Terraform][terraform] (or any tool
allowing for infrastructure as code) for this. I don't predict wanting to have
this infrastructure reproducible nor frequently modified. Still, it serves as
documentation on what is set up on AWS, so I figured it would be a good idea.

The first step was to get Terraform set up and the providers defined. I didn't
want to keep Terraform's state locally, so I decided to also use S3 as a state
backend. I don't need locks on the state (it's only going to be me deploying
this), so a single file on a S3 bucket would suffice. So, I created an `_infra`
folder on the root of the directory tree of this website and placed a
`providers.tf` file in it:

{% highlight terraform %}
terraform {
  required_version = "~> 1.0.11"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  backend "s3" {
    bucket = "jcazevedo-terraform-state"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}
{% endhighlight %}

The required version is set to 1.0.11 because that's the one I'm currently using
at `$WORK`. Setting up the state backend required manually creating a bucket for
it. Using Terraform to manage that bucket would lead us to the problem of
remotely managing state that we were trying to avoid with it in the first place.

With this set up, a call to `terraform init` should complete successfully.

## Setting Up the S3 bucket(s)

The next step was to set up the S3 buckets. I actually went with 2 buckets: one
for the root domain (`jcazevedo.net`) and another for the `www` subdomain
(`www.jcazevedo.net`). The reason for it was to set up a redirect on the `www`
subdomain, which S3 [supports][bucket-redirect]. To set the buckets up, I
created an `s3.tf` file under the `_infra_` folder with the following contents:

{% highlight terraform %}
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
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.jcazevedo_net.arn}/*"]
  }
}

data "aws_iam_policy_document" "www_jcazevedo_net_allow_public_access" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.www_jcazevedo_net.arn}/*"]
  }
}
{% endhighlight %}

Most of the configuration is the same for both buckets. We want both buckets to
allow GET requests from the public. The main difference is in the website
configuration. The root bucket specifies an index and error document (to be
served in case of errors), whereas the www bucket just configures the
redirection policy.

Once this was set up, I pushed this website contents to root S3 bucket by
running a `bundle exec jekyll build` followed by an `aws s3 sync _site/
s3://jcazevedo.net/ --delete`. The site was already available via the root
bucket website endpoint
([http://jcazevedo.net.s3-website-us-east-1.amazonaws.com/](http://jcazevedo.net.s3-website-us-east-1.amazonaws.com/))
and the redirection was already working via the www bucket website endpoint
([http://www.jcazevedo.net.s3-website-us-east-1.amazonaws.com/](http://www.jcazevedo.net.s3-website-us-east-1.amazonaws.com/)).
At this point the domain wasn't yet migrated, so this was still redirecting to
the DreamHost instance.

## Setting Up the Domain

I had never transferred a domain before, so I followed [AWS
instructions](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/domain-transfer-to-route-53.html).
This would take a while to complete, so I figured I would create the
[Route53][route53] zone before and have the domain already transferred to the
new zone. For that purpose I created a `route53.tf` file under the `_infra`
folder with the following contents:

{% highlight terraform %}
resource "aws_route53_zone" "jcazevedo_net" {
  name = "jcazevedo.net"
}
{% endhighlight %}

While the domain had its tranfer in progress, I proceeded to set up the SSL
certificates.

## Provisioning the SSL Certificates

I had to search how to define ACM certificates in Terraform and to intregate
them with CloudFront. Fortunately, I found this blog post by [Alex
Hyett][alex-hyett]: [Hosting a Secure Static Website on AWS S3 using Terraform
(Step By Step Guide)][alex-hyett-static-website-hosting]. The blog post covered
pretty much what I had already done thus far, and was extremely helpful on the
next steps: setting up [SSL][alex-hyett-blogpost-ssl] and the [CloudFront
distribution][alex-hyett-blogpost-cloudfront].

To set up SSL, I created the `acm.tf` file under the `_infra` folder with the
following contents:

{% highlight terraform %}
resource "aws_acm_certificate" "ssl_certificate" {
  domain_name               = "jcazevedo.net"
  subject_alternative_names = ["*.jcazevedo.net"]
  validation_method         = "EMAIL"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn = aws_acm_certificate.ssl_certificate.arn
}
{% endhighlight %}

For the validation method I used email instead of DNS since at that time I
didn't have the DNS moved yet. The email validation is performed while we're
applying the Terraform diff, so it's quite fast.

## Setting up the CloudFront distributions

[CloudFront][cloudfront] speeds up the distribution of static (and dynamic) web
content. It can handle caching, compression and can require viewers to use HTTPS
so that connections are encrypted. The previously mentioned [blog
post][alex-hyett-static-website-hosting] by [Alex Hyett][alex-hyett] provided
instructions to set CloudFront distributions pointing to existing S3 buckets and
using HTTPS, so I almost blindly copied the Terraform definitions. Similar to
what had been done before, we needed two distributions: one for the root bucket
and one for the `www` bucket.

{% highlight terraform %}
resource "aws_cloudfront_distribution" "root_s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.jcazevedo_net.website_endpoint
    origin_id   = "S3-.jcazevedo.net"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  aliases             = ["jcazevedo.net"]
  custom_error_response {
    error_caching_min_ttl = 0
    error_code            = 404
    response_code         = 200
    response_page_path    = "/404/index.html"
  }
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-.jcazevedo.net"
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 31536000
    default_ttl            = 31536000
    max_ttl                = 31536000
    compress               = true
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.cert_validation.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016"
  }
}

resource "aws_cloudfront_distribution" "www_s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.www_jcazevedo_net.website_endpoint
    origin_id   = "S3-www.jcazevedo.net"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }
  enabled         = true
  is_ipv6_enabled = true
  aliases         = ["www.jcazevedo.net"]
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-www.jcazevedo.net"
    forwarded_values {
      query_string = true
      cookies {
        forward = "none"
      }
      headers = ["Origin"]
    }
    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.cert_validation.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016"
  }
}
{% endhighlight %}

The configurations are similar, except for the caching settings, since the
second distribution only points to the S3 bucket that redirects to the non-`www`
website.

## Adding Route53 Records Pointing to the CloudFront distributions

The last part of the process involved creating new Route53 A records pointing to
the CloudFront distributions created previously. For this, I've added the
following to the `route53.tf` file mentioned previously:

{% highlight terraform %}
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
{% endhighlight %}

There's one record for each of the distributions (`www` and non-`www`).

## Waiting for the Domain Transfer

The domain transfer from [DreamHost][dreamhost] to [Route53][route53] took
around 8 days. I was notified by email when it was completed. Since everything
was already pre-configured and the website contents had already been pushed to
S3, the website continued to be served as expected from
[https://jcazevedo.net/](https://jcazevedo.net/).

[S3 static website]: https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html
[alex-hyett-blogpost-cloudfront]: https://www.alexhyett.com/terraform-s3-static-website-hosting#cloudfronttf
[alex-hyett-blogpost-ssl]: https://www.alexhyett.com/terraform-s3-static-website-hosting#acmtf
[alex-hyett-static-website-hosting]: https://www.alexhyett.com/terraform-s3-static-website-hosting#acmtf
[alex-hyett]: https://www.alexhyett.com/
[aws]: https://aws.amazon.com/
[bucket-redirect]: https://docs.aws.amazon.com/AmazonS3/latest/userguide/how-to-page-redirect.html
[cloudfront]: https://aws.amazon.com/cloudfront/
[dreamhost]: https://www.dreamhost.com/
[free tier]: https://aws.amazon.com/s3/pricing/#AWS_Free_Tier
[letsencrypt]: https://letsencrypt.org/
[terraform]: https://www.terraform.io/
[transfer-domain]: https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/domain-transfer-to-route-53.html
[route53]: https://aws.amazon.com/route53/
