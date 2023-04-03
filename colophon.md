---
layout: main
title: Colophon
---

# Colophon

The contents of this site are written in [Emacs][emacs], in a mix of
[Markdown][markdown] and HTML. A static site is generated from the
[Markdown][markdown] and HTML files using [Jekyll][jekyll]. The current style
being used is a modified version of the one in [Hyde][hyde]. The most up-to-date
source is available on [GitHub][github]. The generated static site is pushed to
[S3][S3 static website]. Some details on the infrastructure behind this can be
found in the following posts:

<div class="archive-posts">
  <div class="archive-item">
    <div class="archive-post-date">{{ "2022-09-07" | date: "%B %-d, %Y" }}</div>
    <div class="archive-post-title"><a href="{% post_url 2022-09-07-migrating-this-website-to-aws %}">Migrating This Website to AWS</a></div>
  </div>
  <div class="archive-item">
    <div class="archive-post-date">{{ "2022-09-11" | date: "%B %-d, %Y" }}</div>
    <div class="archive-post-title"><a href="{% post_url 2022-09-11-using-github-actions-to-publish-this-website %}">Using GitHub Actions to Publish This Website</a></div>
  </div>
</div>

[S3 static website]: https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html
[emacs]: https://www.gnu.org/software/emacs/
[github]: https://github.com/jcazevedo/jcazevedo.net
[hyde]: https://hyde.getpoole.com/
[jekyll]: https://jekyllrb.com/
[markdown]: https://daringfireball.net/projects/markdown/
