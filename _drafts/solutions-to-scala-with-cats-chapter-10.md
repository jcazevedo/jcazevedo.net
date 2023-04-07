---
layout: post
title: 'Solutions to "Scala with Cats": Chapter 10'
---

These are my solutions to the exercises of chapter 10 of [Scala with
Cats][scala-with-cats]. The book is available for free at
[https://www.scalawithcats.com/][scala-with-cats].

[scala-with-cats]: https://www.scalawithcats.com/

## Exercise 10.3: Basic Combinators

The `and` method of `Check` will create a new `Check` that calls `apply` on both
instances. However, we soon hit the problem of what to do if they both return a
`Left`:

{% highlight scala %}
def and(that: Check[E, A]): Check[E, A] =
  new Check[E, A] {
    def apply(value: A): Either[E, A] = {
      val selfCheck = self.apply(value)
      val thatCheck = that.apply(value)
      // How to combine if both fail?

      ???
    }
  }
{% endhighlight %}

We need a way to combine values of type `E`, which hints towards the need for a
`Semigroup` instance for `E`. We're assuming that we don't want to short-circuit
but rather accumulate all errors.

For the `and` implementation, we follow the algebraic data type style that is
recommended by the book:

{% highlight scala %}
import cats.Semigroup
import cats.syntax.either._
import cats.syntax.semigroup._

sealed trait Check[E, A] {
  import Check._

  def and(that: Check[E, A]): Check[E, A] =
    And(this, that)

  def apply(a: A)(implicit s: Semigroup[E]): Either[E, A] =
    this match {
      case Pure(func) =>
        func(a)

      case And(left, right) =>
        (left(a), right(a)) match {
          case (Left(e1), Left(e2)) => (e1 |+| e2).asLeft
          case (Left(e),  Right(_)) => e.asLeft
          case (Right(_), Left(e))  => e.asLeft
          case (Right(_), Right(_)) => a.asRight
        }
    }
}

object Check {
  final case class And[E, A](left: Check[E, A], right: Check[E, A]) extends Check[E, A]

  final case class Pure[E, A](func: A => Either[E, A]) extends Check[E, A]

  def pure[E, A](f: A => Either[E, A]): Check[E, A] =
    Pure(f)
}
{% endhighlight %}

`Validated` is a more appropriate data type to accumulate errors than `Either`.
We can also rely on the `Applicative` instance for `Validated` to avoid the
pattern match:

{% highlight scala %}
import cats.Semigroup
import cats.data.Validated
import cats.syntax.apply._

sealed trait Check[E, A] {
  import Check._

  def and(that: Check[E, A]): Check[E, A] =
    And(this, that)

  def apply(a: A)(implicit s: Semigroup[E]): Validated[E, A] =
    this match {
      case Pure(func) =>
        func(a)

      case And(left, right) =>
        (left(a), right(a)).mapN((_, _) => a)
    }
}

object Check {
  final case class And[E, A](left: Check[E, A], right: Check[E, A]) extends Check[E, A]

  final case class Pure[E, A](func: A => Validated[E, A]) extends Check[E, A]

  def pure[E, A](f: A => Validated[E, A]): Check[E, A] =
    Pure(f)
}
{% endhighlight %}

The `or` combinator should return a `Valid` if the left hand side is `Valid` or
if the left hand side is `Invalid` but the right hand side is `Valid`. If both
are `Invalid`, it should return an `Invalid` combining both errors. Due to the
latter, we can't rely on `orElse` but rather have a slightly more complicated
implementation:

{% highlight scala %}
import cats.Semigroup
import cats.data.Validated
import cats.syntax.apply._
import cats.syntax.semigroup._

sealed trait Check[E, A] {
  import Check._

  def and(that: Check[E, A]): Check[E, A] =
    And(this, that)

  def or(that: Check[E, A]): Check[E, A] =
    Or(this, that)

  def apply(a: A)(implicit s: Semigroup[E]): Validated[E, A] =
    this match {
      case Pure(func) =>
        func(a)

      case And(left, right) =>
        (left(a), right(a)).mapN((_, _) => a)

      case Or(left, right) =>
        left(a) match {
          case Validated.Valid(a)    => Validated.Valid(a)
          case Validated.Invalid(el) =>
            right(a) match {
              case Validated.Valid(a)    => Validated.Valid(a)
              case Validated.Invalid(er) => Validated.Invalid(el |+| er)
            }
        }
    }
}

object Check {
  final case class And[E, A](left: Check[E, A], right: Check[E, A]) extends Check[E, A]

  final case class Or[E, A](left: Check[E, A], right: Check[E, A]) extends Check[E, A]

  final case class Pure[E, A](func: A => Validated[E, A]) extends Check[E, A]

  def pure[E, A](f: A => Validated[E, A]): Check[E, A] =
    Pure(f)
}
{% endhighlight %}
