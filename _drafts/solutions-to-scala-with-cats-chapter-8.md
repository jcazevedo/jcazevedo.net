---
layout: post
title: 'Solutions to "Scala with Cats": Chapter 8'
---

These are my solutions to the exercises of chapter 8 of [Scala with
Cats][scala-with-cats]. The book is available for free at
[https://www.scalawithcats.com/][scala-with-cats].

[scala-with-cats]: https://www.scalawithcats.com/

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
