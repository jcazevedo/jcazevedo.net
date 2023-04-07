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

## Exercise 9.3.3: Implementing _parallelFoldMap_

We can implement `parallelFoldMap` as follows:

{% highlight scala %}
def parallelFoldMap[A, B: Monoid](values: Vector[A])(func: A => B): Future[B] = {
  val batches = Runtime.getRuntime().availableProcessors()
  val groups = (values.length + batches - 1) / batches
  val futures = values.grouped(groups).map(as => Future(foldMap(as)(func)))
  Future.sequence(futures).map(_.foldLeft(Monoid[B].empty)(Monoid[B].combine))
}
{% endhighlight %}

We determine the amount of batches in which to split our work based on the
number of CPUs we have available. We then determine the size of our groups by
dividing the length of our input by the number of batches we're going to run,
rounding up. We spawn a `Future` with `foldMap` for each group and join them via
`Future.sequence`, reducing the results of each batch with the `Monoid` instance
we have in scope for `B`.