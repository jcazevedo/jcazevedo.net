---
layout: post
title: Using GitHub Actions to Publish This Website
date: 2022-09-11 23:16 +0000
---
# Using GitHub Actions to Publish This Website

I [have recently moved]({% post_url
posts/2022-09-07-migrating-this-website-to-aws %}) this website from
[DreamHost][dreamhost] to [AWS][aws]. While I was able to automate the setup of
the infrastructure, I was still deploying changes manually. It is not a very
cumbersome process and it involves the following steps after a change is
created:

1. Build the website;
1. Sync the new website contents with the main S3 bucket;
1. Invalidate the cache of the non-`www` CloudFront distribution;
1. Invalidate the cache of the `www` CloudFront distribution.

In its essence, this involves running the following 4 commands, in sequence:

{% highlight bash %}
$ bundle exec jekyll build
$ aws s3 sync _site/ s3://jcazevedo.net/ --delete
$ aws cloudfront create-invalidation --distribution-id E1M51KVTH60PJ5 --paths '/*'
$ aws cloudfront create-invalidation --distribution-id E2YP0O47Y4BTWK --paths '/*'
{% endhighlight %}

This is not terrible to run each time I introduce a new change, but it would be
easier if I could make it so that every push to the `master` branch of the
[repository][github-repo] which holds the contents of the website would trigger
a deploy. Fortunately we can use [GitHub Actions][github-actions] for this.

## Setting Up the GitHub Action

In order to set that up, we first need to create a workflow. Workflows live in
the `.github/workflows` folder, and that is where I have created the
`deploy.yml` file.

We start by giving the workflow a name:

{% highlight yaml %}
name: Deploy
{% endhighlight %}

Then, we setup which actions trigger a workflow run. In this case, I want every
push to the `master` branch to trigger it:

{% highlight yaml %}
on:
  push:
    branches:
      - master
{% endhighlight %}

Following that, we can start defining our job. In this case, we need to specify
in which environment the job should run and the list of steps that comprise it.
We're OK with running on the latest Ubuntu version:

{% highlight yaml %}
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      (...)
{% endhighlight %}

To build the website, we need to have 3 steps: (1) checkout the repository, (2)
setup ruby and install dependencies and (3) run `bundle exec jekyll build`:

{% highlight yaml %}
- uses: actions/checkout@v3

- uses: ruby/setup-ruby@v1
  with:
    ruby-version: 3.0
    bundler-cache: true

- run: bundle exec jekyll build
{% endhighlight %}

Once the site is built, we need to publish it to S3 and invalidate the caches of
the CloudFront distributions. The [AWS Command Line Interface][aws-cli] is
already available in GitHub-hosted virtual environments, so we just need to set
up the credentials we want to use. In this case, we want to reference some
repository secrets which we will set up later:

{% highlight yaml %}
- uses: aws-actions/configure-aws-credentials@v1
  with:
    aws-access-key-id: ${{secrets.AWS_ACCESS_KEY_ID}}
    aws-secret-access-key: ${{secrets.AWS_SECRET_ACCESS_KEY}}
    aws-region: us-east-1
{% endhighlight %}

With the credentials set up, we can run the commands we previously listed: 

{% highlight yaml %}
- run: aws s3 sync _site/ s3://jcazevedo.net/ --delete
- run: aws cloudfront create-invalidation --distribution-id E1M51KVTH60PJ5 --paths '/*'
- run: aws cloudfront create-invalidation --distribution-id E2YP0O47Y4BTWK --paths '/*'
{% endhighlight %}

The full YAML for the workflow definition is as follows:

{% highlight yaml %}
name: Deploy

on:
  push:
    branches:
      - master

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: 3.0
          bundler-cache: true

      - run: bundle exec jekyll build

      - uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{secrets.AWS_ACCESS_KEY_ID}}
          aws-secret-access-key: ${{secrets.AWS_SECRET_ACCESS_KEY}}
          aws-region: us-east-1

      - run: aws s3 sync _site/ s3://jcazevedo.net/ --delete
      - run: aws cloudfront create-invalidation --distribution-id E1M51KVTH60PJ5 --paths '/*'
      - run: aws cloudfront create-invalidation --distribution-id E2YP0O47Y4BTWK --paths '/*'
{% endhighlight %}

## Creating a User for GitHub Actions

To set up the credentials this workflow is going to use to interact with AWS, I
wanted to create a user with permissions to interact with the relevant S3 bucket
and CloudFront distributions only. To do that, I have added the following to the
[Terraform][terraform] definition (refer to the [previous post]({% post_url
posts/2022-09-07-migrating-this-website-to-aws %}#setting-up-terraform) for more
details on the existing Terraform definition):

{% highlight terraform %}
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
{% endhighlight %}

This creates a new [IAM][aws-iam] user, attaches a policy to it that gives it
access to the relevant S3 and CloudFront resources, and creates a new access key
which we will set up as a secret in our GitHub repository. The secret access key
gets stored in the Terraform state, but we define an output that allows us to
read it with `terraform output -raw github-actions_aws_iam_access_key_secret`.

With the [GitHub secrets][github-secrets] appropriately set up, we now have a
workflow that publishes this website whenever a new commit is pushed to the
`master` branch.

[aws-cli]: https://aws.amazon.com/cli/
[aws-iam]: https://aws.amazon.com/iam/
[aws]: https://aws.amazon.com/
[dreamhost]: https://www.dreamhost.com/ 
[github-actions]: https://github.com/features/actions
[github-repo]: https://github.com/jcazevedo/jcazevedo.net
[github-secrets]: https://docs.github.com/en/actions/security-guides/encrypted-secrets
[terraform]: https://www.terraform.io/
