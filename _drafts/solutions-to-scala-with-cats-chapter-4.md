---
layout: post
title: 'Solutions to "Scala with Cats": Chapter 4'
---

These are my solutions to the exercises of chapter 4 of [Scala with
Cats][scala-with-cats]. The book is available for free at
[https://www.scalawithcats.com/][scala-with-cats].

[scala-with-cats]: https://www.scalawithcats.com/

## Exercise 4.1.2: Getting Func-y

We have `pure` and `flatMap` to define `map`. We want to start from an `F[A]`
and get to an `F[B]` from a function `A => B`. As such, we want to call
`flatMap` over the value. We can't use `func` directly, though. However, we can
produce a function that would lift our value to an `F` using `pure` (`a =>
pure(func(a))`):

{% highlight scala %}
trait Monad[F[_]] {
  def pure[A](a: A): F[A]

  def flatMap[A, B](value: F[A])(func: A => F[B]): F[B]

  def map[A, B](value: F[A])(func: A => B): F[B] =
    flatMap(value)(func.andThen(pure))
}
{% endhighlight %}

## Exercise 4.3.1: Monadic Secret Identities

`pure`, `map` and `flatMap` for `Id` can be implemented as follows:

{% highlight scala %}
def pure[A](a: A): Id[A] = 
  a
  
def flatMap[A, B](value: Id[A])(func: A => Id[B]): Id[B] = 
  func(value)
  
def map[A, B](value: Id[A])(func: A => B): Id[B] = 
  func(value)
{% endhighlight %}

Since `Id[A]` is just a type alias for `A`, we can notice that we avoid all
boxing in the implementations and, due to that fact, `flatMap` and `map` are
identical.
