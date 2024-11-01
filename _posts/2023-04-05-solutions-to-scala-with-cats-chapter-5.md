---
layout: post
title: 'Solutions to Scala with Cats: Chapter 5'
date: 2023-04-05 00:03 +0000
num: 28
categories:
  - book-solutions
  - scala-with-cats
---

These are my solutions to the exercises of chapter 5 of [Scala with
Cats][scala-with-cats].

[scala-with-cats]: https://www.scalawithcats.com/

## Table of Contents

- [Exercise 5.4: Transform and Roll Out](#exercise-54-transform-and-roll-out)

## Exercise 5.4: Transform and Roll Out

We can rewrite `Response` using a monad transformer as follows:

{% highlight scala %}
import cats.data.EitherT
import scala.concurrent.Future

type Response[A] = EitherT[Future, String, A]
{% endhighlight %}

We can implement `getPowerLevel` as follows. Note that we need an implicit
`ExecutionContext` in scope so that we can have an instance of `Functor` for
`Future`, even if we just create our `Future`s with `Future.successful` (which
doesn't need one). We are using the global `ExecutionContext` for convenience.

{% highlight scala %}
import scala.concurrent.ExecutionContext.Implicits.global

def getPowerLevel(autobot: String): Response[Int] =
  powerLevels.get(autobot) match {
    case Some(powerLevel) => EitherT.right(Future.successful(powerLevel))
    case None => EitherT.left(Future.successful(s"Autobot $autobot is unreachable"))
  }
{% endhighlight %}

To implement `canSpecialMove` we can request the power levels of each autobot
and check if their sum is greater than 15. We can use `flatMap` on `EitherT`
which makes sure that errors being raised on calls to `getPowerLevel` stop the
sequencing and have `canSpecialMove` return a `Response` with the appropriate
error message.

{% highlight scala %}
def canSpecialMove(ally1: String, ally2: String): Response[Boolean] =
  for {
    powerLevel1 <- getPowerLevel(ally1)
    powerLevel2 <- getPowerLevel(ally2)
  } yield (powerLevel1 + powerLevel2) > 15
{% endhighlight %}

To implement `tacticalReport`, we need to produce a `String` from a `Future`, so
we must use `Await`.

{% highlight scala %}
import scala.concurrent.Await
import scala.concurrent.duration._

def tacticalReport(ally1: String, ally2: String): String = {
  Await.result(canSpecialMove(ally1, ally2).value, 5.seconds) match {
    case Left(msg) =>
      s"Comms error: $msg"
    case Right(true) =>
      s"$ally1 and $ally2 are ready to roll out!"
    case Right(false) =>
      s"$ally1 and $ally2 need a recharge."
  }
}
{% endhighlight %}
