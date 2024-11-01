---
layout: post
title: 'Solutions to Scala with Cats: Chapter 7'
date: 2023-04-05 17:07 +0000
num: 30
categories:
  - book-solutions
  - scala-with-cats
---

These are my solutions to the exercises of chapter 7 of [Scala with
Cats][scala-with-cats].

[scala-with-cats]: https://www.scalawithcats.com/

## Table of Contents

- [Exercise 7.1.2: Reflecting on Folds](#exercise-712-reflecting-on-folds)
- [Exercise 7.1.3: Scaf-fold-ing Other Methods](#exercise-713-scaf-fold-ing-other-methods)
- [Exercise 7.2.2.1: Traversing with Vectors](#exercise-7221-traversing-with-vectors)
- [Exercise 7.2.2.2: Traversing with Options](#exercise-7222-traversing-with-options)
- [Exercise 7.2.2.3: Traversing with Validated](#exercise-7223-traversing-with-validated)

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

## Exercise 7.2.2.1: Traversing with Vectors

The result of the provided expression is going to be a `Vector` of `List`s, with
each being the pairwise combination of the elements from both `Vector`s:

{% highlight scala %}
Vector(
  List(1, 3),
  List(1, 4),
  List(2, 3),
  List(2, 4)
)
{% endhighlight %}

If we use a list of three parameters, we will get back a `Vector` of `List`s
again, but this time each list is going to be of three elements and we will have
one list per each possible triple combination of elements from each of the
`Vector`s:

{% highlight scala %}
Vector(
  List(1, 3, 5),
  List(1, 3, 6),
  List(1, 4, 5),
  List(1, 4, 6),
  List(2, 3, 5),
  List(2, 3, 6),
  List(2, 4, 5),
  List(2, 4, 6)
)
{% endhighlight %}

## Exercise 7.2.2.2: Traversing with Options

The return type of the `process` method is `Option[List[Int]]` and it will
return a `Some` of the provided input if all integers in the list argument are
even and `None` otherwise. Therefore, it will produce the following for the
first call:

{% highlight scala %}
Some(List(2, 4, 6))
{% endhighlight %}

And the following for the second call:

{% highlight scala %}
None
{% endhighlight %}

## Exercise 7.2.2.3: Traversing with Validated

The provided method will return a `Valid` with the list argument when all
integers of it are even or an `Invalid` with a `List` of `String` for each
element that is not even otherwise. Therefore, we get the following for the
first call:

{% highlight scala %}
Valid(List(2, 4, 6))
{% endhighlight %}

And the following for the second call:

{% highlight scala %}
Invalid(List("1 is not even", "3 is not even"))
{% endhighlight %}
