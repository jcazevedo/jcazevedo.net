---
layout: post
title: 'Solutions to Scala with Cats: Chapter 4'
date: 2023-04-04 18:59 +0000
index: 27
categories:
  - book-solutions
  - scala-with-cats
---

These are my solutions to the exercises of chapter 4 of [Scala with
Cats][scala-with-cats].

[scala-with-cats]: https://www.scalawithcats.com/

## Table of Contents

- [Exercise 4.1.2: Getting Func-y](#exercise-412-getting-func-y)
- [Exercise 4.3.1: Monadic Secret Identities](#exercise-431-monadic-secret-identities)
- [Exercise 4.4.5: What is Best?](#exercise-445-what-is-best)
- [Exercise 4.5.4: Abstracting](#exercise-454-abstracting)
- [Exercise 4.6.5: Safer Folding using Eval](#exercise-465-safer-folding-using-eval)
- [Exercise 4.7.3: Show Your Working](#exercise-473-show-your-working)
- [Exercise 4.8.3: Hacking on Readers](#exercise-483-hacking-on-readers)
- [Exercise 4.9.3: Post-Order Calculator](#exercise-493-post-order-calculator)
- [Exercise 4.10.1: Branching out Further with Monads](#exercise-4101-branching-out-further-with-monads)

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

## Exercise 4.8.3: Hacking on Readers

To create a type alias for a `Reader` that consumes a `Db` we want to fix the
first type parameter of `Reader` to `Db`, while still leaving the result type as
a type parameter:

{% highlight scala %}
import cats.data.Reader

type DbReader[A] = Reader[Db, A]
{% endhighlight %}

The `findUsername` and `checkPassword` functions can be implemented as follows:

{% highlight scala %}
def findUsername(userId: Int): DbReader[Option[String]] =
  Reader.apply(db => db.usernames.get(userId))

def checkPassword(username: String, password: String): DbReader[Boolean] =
  Reader.apply(db => db.passwords.get(username).contains(password))
{% endhighlight %}

The `checkLogin` method can be implemented as follows:

{% highlight scala %}
def checkLogin(userId: Int, password: String): DbReader[Boolean] =
  for {
    usernameOpt <- findUsername(userId)
    validLogin <- usernameOpt.map(checkPassword(_, password)).getOrElse(Reader.apply((_: Db) => false))
  } yield validLogin
{% endhighlight %}

We are making use of the `findUsername` and `checkPassword` methods. There are
two scenarios in which `checkLogin` can return a `false` for a given `Db`: when
the username doesn't exist and when the password doesn't match.

## Exercise 4.9.3: Post-Order Calculator

A possible implementation of `evalOne` with no proper error handling is the
following:

{% highlight scala %}
def evalOne(sym: String): CalcState[Int] = {
  def op(f: (Int, Int) => Int): CalcState[Int] = State {
    case y :: x :: rest =>
      val ans = f(x, y)
      (ans :: rest, ans)
    case _ =>
      throw new IllegalArgumentException("Insufficient stack size")
  }

  def num(value: String): CalcState[Int] = State { s =>
    val ans = value.toInt
    (ans :: s, ans)
  }

  sym match {
    case "+"   => op(_ + _)
    case "*"   => op(_ * _)
    case "-"   => op(_ - _)
    case "/"   => op(_ / _)
    case other => num(other)
  }
}
{% endhighlight %}

We're not told which operands to support, so I assumed at least `+`, `*`, `-`
and `/`.

For the `evalAll` implementation, we're not told what to do in case the input is
empty. I assumed it would be OK to just have an exception thrown (since that was
the case before), and relied on `reduce` over the `evalOne` calls:

{% highlight scala %}
def evalAll(input: List[String]): CalcState[Int] =
  input.map(evalOne).reduce((e1, e2) => e1.flatMap(_ => e2))
{% endhighlight %}

The `evalInput` method can rely on a call to `evalAll` after splitting the
input by whitespaces:

{% highlight scala %}
def evalInput(input: String): Int =
  evalAll(input.split("\\s+").toList).runA(Nil).value
{% endhighlight %}

## Exercise 4.10.1: Branching out Further with Monads

One implementation of `Monad` for `Tree` is the following:

{% highlight scala %}
implicit val treeMonad: Monad[Tree] = new Monad[Tree] {
  def pure[A](a: A): Tree[A] =
    Leaf(a)

  def flatMap[A, B](fa: Tree[A])(f: A => Tree[B]): Tree[B] =
    fa match {
      case Branch(left, right) =>
        Branch(flatMap(left)(f), flatMap(right)(f))

      case Leaf(value) =>
        f(value)
    }

  def tailRecM[A, B](a: A)(f: A => Tree[Either[A, B]]): Tree[B] =
    flatMap(f(a)) {
      case Left(value) =>
        tailRecM(value)(f)

      case Right(value) =>
        Leaf(value)
    }
}
{% endhighlight %}

However, `tailRecM` isn't tail-recursive. We can make it tail-recursive by
making the recursion explicit in the heap. In this case, we're using two mutable
stacks: one of open nodes to visit and one of already visited nodes. On that
stack, we use `None` to signal a non-leaf node and a `Some` to signal a leaf
node.

{% highlight scala %}
implicit val treeMonad: Monad[Tree] = new Monad[Tree] {
  def pure[A](a: A): Tree[A] =
    Leaf(a)

  def flatMap[A, B](fa: Tree[A])(f: A => Tree[B]): Tree[B] =
    fa match {
      case Branch(left, right) =>
        Branch(flatMap(left)(f), flatMap(right)(f))

      case Leaf(value) =>
        f(value)
    }

  def tailRecM[A, B](a: A)(f: A => Tree[Either[A, B]]): Tree[B] = {
    import scala.collection.mutable

    val open = mutable.Stack.empty[Tree[Either[A, B]]]
    val closed = mutable.Stack.empty[Option[Tree[B]]]

    open.push(f(a))

    while (open.nonEmpty) {
      open.pop() match {
        case Branch(l, r) =>
          open.push(r)
          open.push(l)
          closed.push(None)

        case Leaf(Left(value)) =>
          open.push(f(value))

        case Leaf(Right(value)) =>
          closed.push(Some(pure(value)))
      }
    }

    val ans = mutable.Stack.empty[Tree[B]]

    while (closed.nonEmpty) {
      closed.pop() match {
        case None    => ans.push(Tree.branch(ans.pop(), ans.pop()))
        case Some(v) => ans.push(v)
      }
    }

    ans.pop()
  }
}
{% endhighlight %}
