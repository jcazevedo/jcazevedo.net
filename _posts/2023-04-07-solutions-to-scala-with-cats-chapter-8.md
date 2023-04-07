---
layout: post
title: 'Solutions to "Scala with Cats": Chapter 8'
date: 2023-04-07 13:51 +0000
---

These are my solutions to the exercises of chapter 8 of [Scala with
Cats][scala-with-cats]. The book is available for free at
[https://www.scalawithcats.com/][scala-with-cats].

[scala-with-cats]: https://www.scalawithcats.com/

## Table of Contents

- [Exercise 8.1: Abstracting over Type Constructors](#exercise-81-abstracting-over-type-constructors)
- [Exercise 8.2: Abstracting over Monads](#exercise-82-abstracting-over-monads)

## Exercise 8.1: Abstracting over Type Constructors

To write a trait definition for `UptimeClient` that abstracts over the return
types, we can add a type constructor `F[_]` as a type parameter:

{% highlight scala %}
trait UptimeClient[F[_]] {
  def getUptime(hostname: String): F[Int]
}
{% endhighlight %}

We can then extend it with two traits that bind `F` to `Future` and `Id`
respectively:

{% highlight scala %}
trait RealUptimeClient extends UptimeClient[Future]

trait TestUptimeClient extends UptimeClient[Id]
{% endhighlight %}

To make sure that the code compiles, we write out the method signatures for
`getUptime` in each case:

{% highlight scala %}
trait RealUptimeClient extends UptimeClient[Future] {
  def getUptime(hostname: String): Future[Int]
}

trait TestUptimeClient extends UptimeClient[Id] {
  def getUptime(hostname: String): Id[Int]
}
{% endhighlight %}

We can now have a `TestUptimeClient` as a full class based on `Map[String, Int]`
with no need for relying on `Future`:

{% highlight scala %}
class TestUptimeClient(hosts: Map[String, Int]) extends UptimeClient[Id] {
  def getUptime(hostname: String): Id[Int] =
    hosts.getOrElse(hostname, 0)
}
{% endhighlight %}

## Exercise 8.2: Abstracting over Monads

We can rewrite the method signatures of `UptimeService` so that it abstracts
over the context as follows:

{% highlight scala %}
class UptimeService[F[_]](client: UptimeClient[F]) {
  def getTotalUptime(hostnames: List[String]): F[Int] =
    ???
}
{% endhighlight %}

To get the previous implementation working, we need to not only prove the
compiler that `F` has an `Applicative`, but also add a few syntax imports so
that we can call `traverse` and `map`:

{% highlight scala %}
import cats.Applicative
import cats.instances.list._
import cats.syntax.functor._
import cats.syntax.traverse._

class UptimeService[F[_]: Applicative](client: UptimeClient[F]) {
  def getTotalUptime(hostnames: List[String]): F[Int] =
     hostnames.traverse(client.getUptime).map(_.sum)
}
{% endhighlight %}
