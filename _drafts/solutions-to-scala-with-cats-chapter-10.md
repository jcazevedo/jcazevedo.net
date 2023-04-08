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

## Exercise 10.4.2: Checks

With our previous `Check` renamed to `Predicate`, we can implement the new
`Check` with the proposed interface as follows, using an algebraic data type
approach as before:

{% highlight scala %}
import cats.Semigroup
import cats.data.Validated

sealed trait Check[E, A, B] {
  import Check._

  def apply(a: A)(implicit s: Semigroup[E]): Validated[E, B]

  def map[C](func: B => C): Check[E, A, C] =
    Map[E, A, B, C](this, func)
}

object Check {
  final case class Map[E, A, B, C](check: Check[E, A, B], func: B => C) extends Check[E, A, C] {
    def apply(a: A)(implicit s: Semigroup[E]): Validated[E, C] =
      check(a).map(func)
  }

  final case class Pure[E, A](pred: Predicate[E, A]) extends Check[E, A, A] {
    def apply(a: A)(implicit s: Semigroup[E]): Validated[E, A] =
      pred(a)
  }

  def pure[E, A](pred: Predicate[E, A]): Check[E, A, A] =
    Pure(pred)
}
{% endhighlight %}

`flatMap` is a bit weird to implement because we don't have a `flatMap` for
`Validated`. Fortunately, we have `flatMap` in `Either` and a `withEither`
method in `Validated` that allows us to apply a function over an `Either` that
gets converted back to a `Validated`.

{% highlight scala %}
sealed trait Check[E, A, B] {
  // ...

  def flatMap[C](func: B => Check[E, A, C]) =
    FlatMap[E, A, B, C](this, func)

  // ...
}

object Check {
  // ...

  final case class FlatMap[E, A, B, C](check: Check[E, A, B], func: B => Check[E, A, C])
      extends Check[E, A, C] {
    def apply(a: A)(implicit s: Semigroup[E]): Validated[E, C] =
      check(a).withEither(_.flatMap(b => func(b)(a).toEither))
  }

  // ...
}
{% endhighlight %}

`andThen` gets implemented very similarly to `flatMap`, except that we don't use
the output of the first `Check` to decide which other `Check` to use. The next
`Check` is already statically provided to us:

{% highlight scala %}
sealed trait Check[E, A, B] {
  // ...

  def andThen[C](that: Check[E, B, C]): Check[E, A, C] =
    AndThen[E, A, B, C](this, that)

  // ...
}

object Check {
  // ...

  final case class AndThen[E, A, B, C](left: Check[E, A, B], right: Check[E, B, C])
      extends Check[E, A, C] {
    def apply(a: A)(implicit s: Semigroup[E]): Validated[E, C] =
      left(a).withEither(_.flatMap(b => right(b).toEither))
  }

  // ...
}
{% endhighlight %}

## Exercise 10.4.3: Recap

The helper predicates that are introduced in this exercise make use of a `lift`
method on `Predicate` that we haven't implemented yet. Its implementation can be
something like the following:

{% highlight scala %}
object Predicate {
  // ...

  def lift[E, A](e: E, func: A => Boolean): Predicate[E, A] =
    pure(a => if (func(a)) Validated.Valid(a) else Validated.Invalid(e))

  // ...
}
{% endhighlight %}

A `Check` for username can be implemented as follows, making use of the
`longerThan` and `alphanumeric` predicates.

{% highlight scala %}
val usernameCheck = Check.pure(longerThan(3) and alphanumeric)
{% endhighlight %}

A `Check` for the email address can be implemented as follows. We first check
that the string contains at least one `@`, then split the string, check each of
the sides and combine them back at the end:

{% highlight scala %}
val emailAddressCheck = {
  val checkLeft =
    Check.pure(longerThan(0))

  val checkRight =
    Check.pure(longerThan(3) and contains('.'))

  val checkLeftAndRight =
    Check.pure(Predicate.pure[Errors, (String, String)] { case ((left, right)) =>
      (checkLeft(left), checkRight(right)).mapN((_, _))
    })

  Check
    .pure(containsOnce('@'))
    .map({ str =>
      val Array(left, right) = str.split("@")
      (left, right)
    })
    .andThen(checkLeftAndRight)
    .map({ case ((left, right)) => s"$left@$right" })
}
{% endhighlight %}

## Exercise 10.5: Kleislis

The `run` method on `Predicate` must return a `A => Either[E, A]`. We must rely
on the existing `apply` method so we also need a `Semigroup` instance for `E`:

{% highlight scala %}
sealed trait Predicate[E, A] {
  // ...

  def run(implicit s: Semigroup[E]): A => Either[E, A] =
    a => apply(a).toEither

  // ...
}
{% endhighlight %}

Our checks don't change much. We have decided to implement the email address
check slightly differently here, applying the checks directly in the split step:

{% highlight scala %}
val usernameCheck = checkPred(longerThan(3) and alphanumeric)

val emailAddressCheck = {
  val checkLeft: Check[String, String] =
    checkPred(longerThan(0))

  val checkRight: Check[String, String] =
    checkPred(longerThan(3) and contains('.'))

  val split: Check[String, (String, String)] =
    check(_.split('@') match {
      case Array(name, domain) =>
        Right((name, domain))

      case _ =>
        Left(error("Must contain a single @ character"))
    })

  val join: Check[(String, String), String] =
    check({ case (l, r) => (checkLeft(l), checkRight(r)).mapN(_ + "@" + _) })

  split andThen join
}
{% endhighlight %}
