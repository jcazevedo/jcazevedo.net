---
layout: post
title: 'Book Review: Scala with Cats'
date: 2023-10-02 23:37 +0000
categories:
- book-reviews
- scala-with-cats
---

<img src="/img/scala-with-cats.jpg" class="right-image scaled" />

[Scala with Cats][scala-with-cats] is a book about the [Cats][cats] library,
which provides abstractions for functional programming in the [Scala][scala]
programming language. The book provides an introduction not only to the
[Cats][cats] library but also to some [category theory][category-theory]
structures. It's divided in two major sections: "Theory" and "Case Studies". The
"Theory" section starts with a chapter dedicated to the way [Cats][cats] is
designed around type classes and how type classes are encoded in the Scala
programming language. The section follows with dedicated chapters for different
algebraic data structures, some functional programming constructs and how they
are implemented in [Cats][cats]: Monoids, Semigroups, Functors, Monads, Monad
Transformers, Semigroupal, Applicative, Foldable and Traverse. The "Case
Studies" section ties it all up with 4 practical applications of the previously
introduced structures and constructs: testing asynchronous code, map reduce,
data validation and CRDTs.

I worked through the book in March and April this year and found it engaging and
with a fast pace. Laws are presented and explained in terms of Scala code. The
exercises complement the content of the book well, particularly the ones in the
"Case Studies" section, which showcase the applications of everything that was
introduced in the "Theory" section.

I would recommend the book to anyone with moderate knowledge of the Scala
programming language who wants to learn more about typed functional programming
in general and about the [Cats][cats] library in particular.

If you're interested in my solutions to the book's exercises, they are available
in the following posts:

{% for post in site.categories.scala-with-cats reversed %}
{% if post != page %}
{% include post_link.html post=post %}
{% endif %}
{% endfor %}

[category-theory]: https://en.wikipedia.org/wiki/Category_theory
[cats]: https://typelevel.org/cats/
[scala-with-cats]: https://www.scalawithcats.com/
[scala]: https://scala-lang.org/
