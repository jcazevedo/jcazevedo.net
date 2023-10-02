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

{% for post in site.categories.infrastructure reversed %}
{% include archive_item.html post=post %}
{% endfor %}

[S3 static website]: https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html
[emacs]: https://www.gnu.org/software/emacs/
[github]: https://github.com/jcazevedo/jcazevedo.net
[hyde]: https://hyde.getpoole.com/
[jekyll]: https://jekyllrb.com/
[markdown]: https://daringfireball.net/projects/markdown/
