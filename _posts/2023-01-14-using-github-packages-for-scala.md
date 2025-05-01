---
layout: post
date: 2023-01-14 18:03 +0000
---

# Using GitHub Packages for Scala

We use Scala at `$WORK` for multiple projects. These projects rely on various
internal libraries. Being able to rely on built artifacts between projects in a
way that is convenient for developers in different teams is a huge benefit.

The whole company uses [GitHub][github] to manage source code, so we have
recently started using [GitHub Packages][github-packages] to share Scala
artifacts privately. After circumventing some quirks, it is actually a quite
convenient way to share Scala (and other Maven) artifacts privately.

We use [sbt][sbt] as the build tool for all of our Scala projects, so the
remainder of this post is written for sbt. It should be easy to adapt the
instructions below to other build tools.

## Setting Up Credentials to Authenticate with GitHub Packages

Authentication in GitHub Packages is done through personal access tokens. We can
generate one in our GitHub [personal settings][generate-token]. The token must
have the `read:packages` (when we want to read packages from GitHub Packages)
and the `write:packages` (when we want to write to GitHub Packages) permissions.

We can then set the credentials for sbt to be able to read them via the
following, replacing `<username>` and `<token>` with our username and previously
created token, respectively:

{% highlight scala %}
credentials += Credentials(
  "GitHub Package Registry",
  "maven.pkg.github.com",
  "<username>",
  "<token>")
{% endhighlight %}

The token is a password, so we should treat it as such. We shouldn't commit this
into our repositories, and ideally we have this set up in a global location that
sbt has access to (like `~/.sbt/1.0/github-credentials.sbt`).

## Publishing an Artifact to GitHub Packages

When publishing artifacts in sbt, we always need to specify a repository where
artifacts and descriptors are uploaded. In the case of GitHub Packages, every
GitHub project provides a repository we can use to publish artifacts to. This
means that, in sbt, we can define the location of our repository by setting the
`publishTo` task key to something like the following:

{% highlight scala %}
publishTo := Some(
  "GitHub Package Registry (<project>)" at "https://maven.pkg.github.com/<org>/<project>"
)
{% endhighlight %}

In the snippet above, we should replace the `<org>` and `<project>` placeholders
by the organization and project we want to publish to, respectively.

If our credentials are properly set up, this now allows us to run `sbt publish`
and have our artifacts published to GitHub Packages. Note that packages in
GitHub Packages are immutable, so we can't directly replace a package with the
same version. We can, however, delete an existing version in GitHub.

## Downloading Artifacts from GitHub Packages

In order to download artifacts from GitHub Packages as dependencies of our
projects we must set up the appropriate resolvers in our sbt build. For that
purpose, we can set up the same location we mentioned previously when publishing
artifacts:

{% highlight scala %}
resolvers += ("GitHub Package Registry" at "https://maven.pkg.github.com/<org>/<project>")
{% endhighlight %}

And then add the project as a regular library dependency:

{% highlight scala %}
libraryDependencies += "<org>" %% "<project>" % "<version>"
{% endhighlight %}

If credentials are properly set up, this now allows us to rely on GitHub
Packages as a source of dependencies.

There is one slight inconvenience with the process suggested above, which is the
fact that every project has its own resolver. When depending on multiple
projects from the same organization, this can become cumbersome to manage, since
every dependency would bring its own resolver. Fortunately, there's a way to
work around this and have an organization-wide resolver. The thing is that the
`<project>` section of the resolver doesn't need to exist, so we can reference
some arbitrary repository, like `_`:

{% highlight scala %}
resolvers += ("GitHub Package Registry" at "https://maven.pkg.github.com/<org>/_")
{% endhighlight %}

This will give us access to packages published on any repository within the
organization. The personal access token we use will control our access. If the
token only has access to public repositories, then this resolver won't allow
access to private ones. If it does have access to private repositories, then all
artifacts will be visible.

With this resolver in place, we have convenient access to all artifacts
published within the organization.

## Interacting with GitHub Packages in Automated Workflows

Using GitHub Packages in a pipeline of continuous integration or continuous
delivery is also possible. There are various ways to manage this. One way is to
rely on an environment variable that is populated with the contents of some
secret that includes a personal access token with appropriate access. For that
purpose, we can set up something like the following in our sbt build:

{% highlight scala %}
credentials ++= {
  val githubToken = System.getenv("GITHUB_TOKEN")
  if (githubToken == null) Seq.empty
  else Seq(Credentials("GitHub Package Registry", "maven.pkg.github.com", "_", githubToken))
}
{% endhighlight %}

With the above in place, builds of our project will look at the existence of a
`GITHUB_TOKEN` environment variable and use it to set up the appropriate sbt
crendentials. Note that the above uses `_` as the username for the crendentials.
This is doable because GitHub Packages doesn't care about the actual username
that is used, only if the token has appropriate access.

When using [GitHub Actions][github-actions], there's always a `GITHUB_TOKEN`
secret that has access to the repository where the action is executed, so we can
reference that:

{% highlight yaml %}
{% raw %}
env:
  GITHUB_TOKEN: ${{secrets.GITHUB_TOKEN}}
{% endraw %}
{% endhighlight %}

Note that if we need to fetch artifacts from other projects, we need to set up a
personal access token with more permissions.

## Managing Snapshot Versions

It is customary for Maven artifacts to have snapshot versions which are usually
versioned as `X.Y.Z-SNAPSHOT`. These snapshots are usually mutable and new
versions continuously replace the existing snapshot. This doesn't play very well
with GitHub Packages because versions there are immutable and you can't easily
replace one. It is possible to delete the existing one and publish again, but it
is cumbersome.

To allow for snapshots while using GitHub Packages, we have started using
[sbt-dynver][sbt-dynver]. sbt-dynver is an sbt plugin that dynamically sets the
version of our projects from git. You can look at [some details on how
sbt-dynver sets the version][sbt-dynver-details], but, essentially, when there
is a tag in the current tree, then the version of the project is the version
specified in the tag and, when there is not a tag in the current tree, then the
version of the project is a string built from the closest tag and the distance
to that reference.

With sbt-dynver we can have snapshot-like versions with the version immutability
that GitHub Packages provides.

## Pricing

In terms of [billing][github-packages-billing], we get a total amount of free
storage and some amount of free data transfer per month. Anything above that
incurs in $0.008 USD per GB of storage per day and $0.50 USD per GB of data
transfer. One important note is that traffic using a `GITHUB_TOKEN` from within
GitHub Actions is always free, regardless of where the runner is hosted.

In short, using GitHub Packages is a very convenient way to share Scala
artifacts within a private organization, particularly if said organization
already uses GitHub to manage their source code.

[generate-token]: https://github.com/settings/tokens
[github-actions]: https://github.com/features/actions
[github-packages]: https://github.com/features/packages
[github-packages-billing]: https://docs.github.com/en/billing/managing-billing-for-github-packages/about-billing-for-github-packages
[github]: https://github.com/
[nexus]: https://www.sonatype.com/products/nexus-repository
[sbt-dynver-details]: https://github.com/sbt/sbt-dynver#detail
[sbt-dynver]: https://github.com/sbt/sbt-dynver
[sbt]: https://www.scala-sbt.org/
