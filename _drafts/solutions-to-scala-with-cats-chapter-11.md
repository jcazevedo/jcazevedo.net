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

## Exercise 11.3.3: Generic GCounter

The following is a possible implementation of a generic `GCounter` that uses
instances of `CommutativeMonoid` and `BoundedSemiLattice`:

{% highlight scala %}
import cats.kernel.CommutativeMonoid
import cats.syntax.foldable._
import cats.syntax.semigroup._

final case class GCounter[A](counters: Map[String, A]) {
  def increment(machine: String, amount: A)(implicit m: CommutativeMonoid[A]): GCounter[A] =
    GCounter(counters |+| Map(machine -> amount))

  def merge(that: GCounter[A])(implicit b: BoundedSemiLattice[A]): GCounter[A] =
    GCounter(counters |+| that.counters)

  def total(implicit m: CommutativeMonoid[A]): A =
    counters.values.toList.combineAll
}
{% endhighlight %}

## Exercise 11.4: Abstracting GCounter to a Type Class

The implementation of an instance of the `GCounter` type class for `Map` closely
resembles the original `GCounter` implementation:

{% highlight scala %}
import cats.kernel.CommutativeMonoid
import cats.syntax.foldable._
import cats.syntax.semigroup._

trait GCounter[F[_, _], K, V] {
  def increment(f: F[K, V])(k: K, v: V)(implicit m: CommutativeMonoid[V]): F[K, V]
  def merge(f1: F[K, V], f2: F[K, V])(implicit b: BoundedSemiLattice[V]): F[K, V]
  def total(f: F[K, V])(implicit m: CommutativeMonoid[V]): V
}

object GCounter {
  implicit def mapInstance[K, V]: GCounter[Map, K, V] =
    new GCounter[Map, K, V] {
      def increment(f: Map[K, V])(k: K, v: V)(implicit m: CommutativeMonoid[V]): Map[K, V] =
        f |+| Map(k -> v)

      def merge(f1: Map[K, V], f2: Map[K, V])(implicit b: BoundedSemiLattice[V]): Map[K, V] =
        f1 |+| f2

      def total(f: Map[K, V])(implicit m: CommutativeMonoid[V]): V =
        f.values.toList.combineAll
    }
}
{% endhighlight %}

## Exercise 11.5: Abstracting a Key Value Store

The following is a possible implementation of an instance of the `KeyValueStore`
type class for `Map`:

{% highlight scala %}
trait KeyValueStore[F[_, _]] {
  def put[K, V](f: F[K, V])(k: K, v: V): F[K, V]
  def get[K, V](f: F[K, V])(k: K): Option[V]
  def values[K, V](f: F[K, V]): List[V]

  def getOrElse[K, V](f: F[K, V])(k: K, default: V): V =
    get(f)(k).getOrElse(default)
}

object KeyValueStore {
  implicit val mapInstance: KeyValueStore[Map] =
    new KeyValueStore[Map] {
      def put[K, V](f: Map[K, V])(k: K, v: V): Map[K, V] =
        f + (k -> v)

      def get[K, V](f: Map[K, V])(k: K): Option[V] =
        f.get(k)

      def values[K, V](f: Map[K, V]): List[V] =
        f.values.toList
    }
}
{% endhighlight %}
