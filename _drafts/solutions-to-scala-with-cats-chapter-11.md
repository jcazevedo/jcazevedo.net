---
layout: post
title: 'Solutions to "Scala with Cats": Chapter 11'
---

These are my solutions to the exercises of chapter 10 of [Scala with
Cats][scala-with-cats].

[scala-with-cats]: https://www.scalawithcats.com/

## Exercise 11.2.3: GCounter Implementation

`GCounter` can be implemented as follows:

{% highlight scala %}
final case class GCounter(counters: Map[String, Int]) {
  def increment(machine: String, amount: Int) =
    GCounter(counters.updatedWith(machine)(v => Some(v.getOrElse(0) + amount)))

  def merge(that: GCounter): GCounter =
    GCounter(that.counters.foldLeft(counters) { case (acc, (k, v)) =>
      acc.updatedWith(k)(_.map(_ max v).orElse(Some(v)))
    })

  def total: Int =
    counters.values.sum
}
{% endhighlight %}
