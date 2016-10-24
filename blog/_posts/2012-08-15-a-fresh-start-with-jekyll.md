---
layout: post
title: "A Fresh Start with Jekyll"
date: "Wed Aug  15 22:15:10 WET 2012"
---

I've been meaning to do a revamp of my old site, and took that as a chance to
try [Jekyll][1]. The decisions to use Jekyll over [Wordpress][2], which I've
been relying upon over the past 3 years, revolve around the following:

* **Flexibility**. It can easily be deployed in any machine. The fact that the
  whole site is only composed of static pages avoids the maintenance of extra
  software on the server side and allows me to focus simply on the content.
* **Control**. I have full control over the content: how the pages are
  displayed, how the content is linked, how the titles, urls and everything is
  formatted. I'm not saying I wouldn't be able to do this with a plaform like
  Wordpress, but with Jekyll everything is explicit.
* **Enhances a familiar workflow**. Writing with Jekyll is closer to a workflow
  that I'm used to as a software developer. I can keep all content versioned in
  a local git repository and push to a remote repository when I'm ready to
  publish. Moreover, I can write the posts using [Markdown][3] directly on
  [Emacs][4], using a familiar syntax and avoiding HTML.
* **Simplicity**. Having only static files makes scaling easier and improves
  security.

It's surprisingly easy to get started with Jekyll. Having already ruby and rvm
in my system, I just needed to install the gem, setup the initial project
structure as described in its [wiki][5] and start working on the site design and
initial structure. Since Jekyll supports direct regeneration, I don't need to
restart the local server to see my changes in the browser. To support syntax
highlighting, I installed [Pygments][6] (which is the same software GitHub uses
for syntax highlighting) and had it generate its css.

I wanted to keep the site design as simple as possible. Lacking proper design
skills, I grabbed a few ideas from [Tom Preston-Werner][7], a few fonts from
[Google Web Fonts][8] and came up with the current state, which I have only
tested in Chrome and Safari, but whose simplicity of the CSS makes me believe
that it should be consistent across different browsers.

Since obviously Jekyll doesn't support comments out of the box, I signed up for
[Disqus][9] and had it set up on my posts' page. This was also surprisingly
easy.

## What about the old posts?

Even though there are [various ways][10] to import posts from my old blog to the
new platform, I figured I would have a tough time with formatting issues. So,
for now, I'm keeping everything under the [/old/][11] subdirectory. This also
means that the RSS feed URL has also changed, so grab the new one [here][12].

[1]: http://github.com/mojombo/jekyll/
[2]: http://wordpress.org/
[3]: http://daringfireball.net/projects/markdown/
[4]: http://jblevins.org/projects/markdown-mode/
[5]: http://github.com/mojombo/jekyll/wiki/usage
[6]: http://pygments.org/
[7]: http://tom.preston-werner.com/
[8]: http://www.google.com/webfonts
[9]: http://disqus.com/
[10]: http://github.com/mojombo/jekyll/wiki/Blog-Migrations
[11]: /old/
[12]: /atom.xml
