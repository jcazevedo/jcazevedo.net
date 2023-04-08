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
  def increment(machine: String, amount: Int): GCounter =
    GCounter(counters.updatedWith(machine)(v => Some(v.getOrElse(0) + amount)))

  def merge(that: GCounter): GCounter =
    GCounter(that.counters.foldLeft(counters) { case (acc, (k, v)) =>
      acc.updatedWith(k)(_.map(_ max v).orElse(Some(v)))
    })

  def total: Int =
    counters.values.sum
}
{% endhighlight %}

## Exercise 11.3.2: BoundedSemiLattice Instances

The following are possible implementations of `BoundedSemiLattice` for `Int`s
and `Set`s. As described in the problem statement, we don't need to model
non-negativity in the instance for `Int`s:

{% highlight scala %}
import cats.kernel.CommutativeMonoid

trait BoundedSemiLattice[A] extends CommutativeMonoid[A] {
  def combine(a1: A, a2: A): A
  def empty: A
}

object BoundedSemiLattice {
  implicit val intBoundedSemiLattice: BoundedSemiLattice[Int] =
    new BoundedSemiLattice[Int] {
      def combine(a1: Int, a2: Int): Int = a1 max a2
      def empty: Int = 0
    }

  implicit def setBoundedSemiLattice[A]: BoundedSemiLattice[Set[A]] =
    new BoundedSemiLattice[Set[A]] {
      def combine(a1: Set[A], a2: Set[A]): Set[A] = a1 union a2
      def empty: Set[A] = Set.empty[A]
    }
}
{% endhighlight %}
