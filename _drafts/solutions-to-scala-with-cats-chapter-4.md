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

## Exercise 4.4.5: What is Best?

The answer depends on what we are looking for in specific instances, but some
things that the previous examples for error handling don't cover are:

* We can't accumulate errors. The proposed examples all fail fast.
* We can't tell exactly where the error was raised.
* It's not easy to do error recovery.

## Exercise 4.5.4: Abstracting

A possible implementation for `validateAdult` is the following:

{% highlight scala %}
import cats.{Applicative, MonadError}

def validateAdult[F[_]](age: Int)(implicit me: MonadError[F, Throwable]): F[Int] =
  if (age >= 18) Applicative[F].pure(age)
  else me.raiseError(new IllegalArgumentException("Age must be greater than or equal to 18"))
}
{% endhighlight %}

If `age` is greater than or equal to 18, we summon an `Applicative` for `F`
(which we must have in scope due to `MonadError`) and lift the `age` to `F`. If
`age` is less than 18, we use the `MonadError` instance we have in scope to lift
an `IllegalArgumentException` to `F`.

## Exercise 4.6.5: Safer Folding using Eval

One way to make the naive implementation of `foldRight` stack safe using `Eval`
is the following:

{% highlight scala %}
import cats.Eval

def foldRightEval[A, B](as: List[A], acc: B)(fn: (A, B) => B): B = {
  def aux(as: List[A], acc: B): Eval[B] =
    as match {
      case head :: tail =>
        Eval.defer(aux(tail, acc)).map(fn(head, _))
      case Nil =>
        Eval.now(acc)
    }

  aux(as, acc).value
}
{% endhighlight %}

We defer the call to the recursive step and then map over it to apply `fn`, all
within the context of `Eval`.

## Exercise 4.7.3: Show Your Working

A possible rewrite of `factorial` so that it captures the log messages in a
`Writer` is the following:

{% highlight scala %}
import cats.data.Writer

def factorial(n: Int): Writer[Vector[String], Int] = {
  slowly {
    if (n == 0)
      Writer.apply(Vector("fact 0 1"), 1)
    else
      factorial(n - 1).mapBoth { (log, res) =>
        val ans = res * n
        (log :+ s"fact $n $ans", ans)
      }
  }
}
{% endhighlight %}

We can show that this allows us to reliably separate the logs for concurrent
computations because we have the logs for each instance captured in each
`Writer` instance:

{% highlight scala %}
Await.result(Future.sequence(Vector(
  Future(factorial(5)),
  Future(factorial(5))
)).map(_.map(_.written)), 5.seconds)
// Returns Vector(
//   Vector("fact 0 1", "fact 1 1", "fact 2 2", "fact 3 6", "fact 4 24", "fact 5 120"),
//   Vector("fact 0 1", "fact 1 1", "fact 2 2", "fact 3 6", "fact 4 24", "fact 5 120")
// )
{% endhighlight %}