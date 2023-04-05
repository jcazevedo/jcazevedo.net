---
layout: post
title: 'Solutions to "Scala with Cats": Chapter 7'
---

These are my solutions to the exercises of chapter 7 of [Scala with
Cats][scala-with-cats]. The book is available for free at
[https://www.scalawithcats.com/][scala-with-cats].

[scala-with-cats]: https://www.scalawithcats.com/

## Exercise 7.1.2: Reflecting on Folds

If we use `foldLeft` with an empty list as the accumulator and `::` as the
binary operator we get back the reversed list:

{% highlight scala %}
val list = List(1, 2, 3, 4)
list.foldLeft(List.empty[Int])((acc, e) => e :: acc)
// Returns List(4, 3, 2, 1).
{% endhighlight %}

On the other hand, if we use `foldRight` with an empty list as the accumulator
and `::` as the binary operator we get back the same list:

{% highlight scala %}
val list = List(1, 2, 3, 4)
list.foldRight(List.empty[Int])(_ :: _)
// Returns List(1, 2, 3, 4).
{% endhighlight %}

## Exercise 7.1.3: Scaf-fold-ing Other Methods

The following are implementations of the `map`, `flatMap`, `filter` and `sum`
methods for `List`s in terms of `foldRight`:

{% highlight scala %}
def map[A, B](list: List[A])(f: A => B): List[B] =
  list.foldRight(List.empty[B])((a, bs) => f(a) :: bs)

def flatMap[A, B](list: List[A])(f: A => List[B]): List[B] =
  list.foldRight(List.empty[B])((a, bs) => f(a) ++ bs)

def filter[A](list: List[A])(f: A => Boolean): List[A] =
  list.foldRight(List.empty[A])((a, as) => if (f(a)) a :: as else as)

def sum[A](list: List[A])(implicit numeric: Numeric[A]): A =
  list.foldRight(numeric.zero)(numeric.plus)
{% endhighlight %}

The `sum` method makes use of the `Numeric` type class from the Scala standard
library. In the spirit of this book, we could also have created an
implementation that uses the `Monoid` type class instead.
