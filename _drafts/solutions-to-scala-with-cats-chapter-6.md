---
layout: post
title: 'Solutions to "Scala with Cats": Chapter 6'
---

These are my solutions to the exercises of chapter 6 of [Scala with
Cats][scala-with-cats]. The book is available for free at
[https://www.scalawithcats.com/][scala-with-cats].

[scala-with-cats]: https://www.scalawithcats.com/

## Exercise 6.3.1.1: The Product of Lists

The reason `product` for `List` produces the Cartesian product is because `List`
forms a `Monad`, and `product` is implemented in terms of `flatMap`. So
`Semigroupal[List].product(List(1, 2), List(3, 4))` is the same as:

{% highlight scala %}
for {
  a <- List(1, 2)
  b <- List(3, 4)
} yield (a, b)
{% endhighlight %}

Which results in the Cartesian product.

## Exercise 6.4.0.1: Parallel List

`List` does have a `Parallel` instance. It zips the lists instead of doing the
Cartesian product. This can be exhibited by the following snippet:

{% highlight scala %}
import cats.instances.list._
import cats.syntax.parallel._

(List(1, 2), List(3, 4)).parTupled
// Returns List((1, 3), (2, 4)).

(List(1, 2), List(3, 4, 5)).parTupled
// Returns List((1, 3), (2, 4)).
{% endhighlight %}
