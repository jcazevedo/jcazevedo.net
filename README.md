# jcazevedo.net

This is the data that powers http://jcazevedo.net/. It is automatically
transformed into a static website using [Jekyll][jekyll]. See
[Developing][#developing] for more details.

Content is available under [Creative Commons (BY-NC-SA)][cc-by-nc-sa] unless
otherwise noted. The CSS is heavily reused from [Hyde][hyde], which is open
source under the MIT license.

## Developing

This project uses [Bundler][bundler] to manage its [gems][rubygems].

Install Ruby 3.4 and Bundler, then run the following to install the project
dependencies:

```sh
bundle install
```

While writing content, preview the website locally, including draft posts, with:

```sh
bundle exec jekyll serve --drafts
```

The website will be available at http://localhost:4000/.

Posts belong in `_posts/` and must use the `YYYY-MM-DD-title.md` filename
format. Draft posts belong in `_drafts/`.

To build the website into the `_site/` directory:

```sh
bundle exec jekyll build
```

To run the build and HTML checks:

```sh
bundle exec rake test
```

### Authoring posts

The [Jekyll::Compose][jekyll-compose] gem can be used to streamline some
writing, avoiding the need for moving files between `_drafts/` and `_posts/`
manually.

To create a draft:

```sh
bundle exec jekyll draft "My New Post"
```

The command creates a file in `_drafts/` with the appropriate front matter. Keep
`layout: post` and add or update the title before writing the post.

To rename a draft:

```sh
bundle exec jekyll rename _drafts/my-new-post.md "My Renamed Post"
```

Preview drafts locally with `bundle exec jekyll serve --drafts`. When a draft is
ready, publish it with:

```sh
bundle exec jekyll publish _drafts/my-renamed-post.md
```

Jekyll::Compose moves the file into `_posts/` and assigns its publication date.

[bundler]: https://bundler.io/
[cc-by-nc-sa]: https://creativecommons.org/licenses/by-nc-sa/4.0/
[hyde]: http://github.com/poole/hyde
[jekyll]: https://jekyllrb.com/
[jekyll-compose]: https://github.com/jekyll/jekyll-compose
[rubygems]: https://rubygems.org/
