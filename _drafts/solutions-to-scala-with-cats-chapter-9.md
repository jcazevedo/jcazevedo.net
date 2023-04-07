---
layout: post
title: 'Solutions to "Scala with Cats": Chapter 9'
---

These are my solutions to the exercises of chapter 9 of [Scala with
Cats][scala-with-cats]. The book is available for free at
[https://www.scalawithcats.com/][scala-with-cats].

[scala-with-cats]: https://www.scalawithcats.com/

## Exercise 9.2: Implementing _foldMap_

The signature of `foldMap` can be as follows. We add `Monoid` as a context bound
for `B`:

{% highlight scala %}
def foldMap[A, B: Monoid](as: Vector[A])(f: A => B): B = ???
{% endhighlight %}

To implement the body of `foldMap`, we have moved the `Monoid` from a context
bound to an implicit parameter list for easier access:

{% highlight scala %}
def foldMap[A, B](as: Vector[A])(f: A => B)(implicit monoid: Monoid[B]): B =
  as.map(f).foldLeft(monoid.empty)(monoid.combine)
{% endhighlight %}

On the code above, we have done both steps separetely for clarity (the `map` and
the `foldLeft`), but we could have made the calls to `func` directly in the
combine step of `foldLeft`.
