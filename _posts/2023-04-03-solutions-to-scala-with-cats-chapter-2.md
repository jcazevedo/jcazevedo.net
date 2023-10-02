---
layout: post
title: 'Solutions to "Scala with Cats": Chapter 2'
date: 2023-04-03 17:05 +0000
categories:
  - book-solutions
  - scala-with-cats
---

These are my solutions to the exercises of chapter 2 of [Scala with
Cats][scala-with-cats].

[scala-with-cats]: https://www.scalawithcats.com/

## Table of Contents

- [Exercise 2.3: The Truth About Monoids](#exercise-23-the-truth-about-monoids)
- [Exercise 2.4: All Set for Monoids](#exercise-24-all-set-for-monoids)
- [Exercise 2.5.4: Adding All the Things](#exercise-254-adding-all-the-things)

## Exercise 2.3: The Truth About Monoids

For this exercise, rather than defining instances for the proposed types, I
defined instances for Cats' `Monoid` directly. For that purpose, we need to
import `cats.Monoid`.

For the `Boolean` type, we can define 4 monoid instances. The first is boolean
or, with `combine` being equal to the application of the `||` operator and
`empty` being `false`:

{% highlight scala %}
val booleanOrMonoid: Monoid[Boolean] = new Monoid[Boolean] {
  def combine(x: Boolean, y: Boolean): Boolean = x || y
  def empty: Boolean = false
}
{% endhighlight %}

The second is boolean and, with `combine` being equal to the application of the
`&&` operator and `empty` being `true`:

{% highlight scala %}
val booleanAndMonoid: Monoid[Boolean] = new Monoid[Boolean] {
  def combine(x: Boolean, y: Boolean): Boolean = x && y
  def empty: Boolean = true
}
{% endhighlight %}

The third is boolean exclusive or, with `combine` being equal to the application
of the `^` operator and `empty` being `false`:

{% highlight scala %}
val booleanXorMonoid: Monoid[Boolean] = new Monoid[Boolean] {
  def combine(x: Boolean, y: Boolean): Boolean = x ^ y
  def empty: Boolean = false
}
{% endhighlight %}

The fourth is boolean exclusive nor (the negation of exclusive or), with
`combine` being equal to the negation of the application of the `^` operator and
`empty` being `true`:

{% highlight scala %}
val booleanXnorMonoid: Monoid[Boolean] = new Monoid[Boolean] {
  def combine(x: Boolean, y: Boolean): Boolean = !(x ^ y)
  def empty: Boolean = true
}
{% endhighlight %}

To convince ourselves that the monoid laws hold for the proposed monoids, we can
verify them on all instances of `Boolean` values. Since they're only 2 (`true`
and `false`), it's easy to check them all:

{% highlight scala %}
object BooleanMonoidProperties extends App {
  final val BooleanValues = List(true, false)

  def checkAssociativity(monoid: Monoid[Boolean]): Boolean =
    (for {
      a <- BooleanValues
      b <- BooleanValues
      c <- BooleanValues
    } yield monoid.combine(monoid.combine(a, b), c) == monoid.combine(a, monoid.combine(b, c))).forall(identity)

  def checkIdentityElement(monoid: Monoid[Boolean]): Boolean =
    (for { a <- BooleanValues } yield monoid.combine(a, monoid.empty) == a).forall(identity)

  def checkMonoidLaws(monoid: Monoid[Boolean]): Boolean =
    checkAssociativity(monoid) && checkIdentityElement(monoid)

  assert(checkMonoidLaws(booleanOrMonoid))
  assert(checkMonoidLaws(booleanAndMonoid))
  assert(checkMonoidLaws(booleanXorMonoid))
  assert(checkMonoidLaws(booleanXnorMonoid))
}
{% endhighlight %}

## Exercise 2.4: All Set for Monoids

Set union forms a monoid for sets:

{% highlight scala %}
def setUnion[A]: Monoid[Set[A]] = new Monoid[Set[A]] {
  def combine(x: Set[A], y: Set[A]): Set[A] = x.union(y)
  def empty: Set[A] = Set.empty[A]
}
{% endhighlight %}

Set intersection only forms a semigroup for sets, since we can't define an
identity element for the general case. In theory, the identity element would be
the set including all instances of the type of elements in the set, but in
practice we can't produce that for a generic type `A`:

{% highlight scala %}
def setIntersection[A]: Semigroup[Set[A]] = new Semigroup[Set[A]] {
  def combine(x: Set[A], y: Set[A]): Set[A] = x.intersect(y)
}
{% endhighlight %}

The book's solutions suggest an additional monoid (symmetric difference), which
didn't occur to me at the time:

{% highlight scala %}
def setSymdiff[A]: Monoid[Set[A]] = new Monoid[Set[A]] {
  def combine(x: Set[A], y: Set[A]): Set[A] = (x.diff(y)).union(y.diff(x))
  def empty: Set[A] = Set.empty[A]
}
{% endhighlight %}

## Exercise 2.5.4: Adding All the Things

The exercise is clearly hinting us towards using a monoid, but the first step
can be defined in terms of `Int` only. The description doesn't tell us what we
should do in case of an empty list, but, since we're in a chapter about monoids,
I assume we want to return the identity element:

{% highlight scala %}
def add(items: List[Int]): Int =
  items.foldLeft(0)(_ + _)
{% endhighlight %}

Changing the code above to also work with `Option[Int]` and making sure there is
no code duplication can be achieved by introducing a dependency on a `Monoid`
instance:

{% highlight scala %}
import cats.Monoid

def add[A](items: List[A])(implicit monoid: Monoid[A]): A =
  items.foldLeft(monoid.empty)(monoid.combine)
{% endhighlight %}

With the above in place we continue to be able to add `Int`s, but we're also now
able to add `Option[Int]`s, provided we have the appropriate `Monoid` instances
in place:

{% highlight scala %}
import cats.instances.int._
import cats.instances.option._

add(List(1, 2, 3))
// Returns 6.

add(List(1))
// Returns 1.

add(List.empty[Int])
// Returns 0.

add(List(Some(1), Some(2), Some(3), None))
// Returns Some(6).

add(List(Option.apply(1)))
// Returns Some(1).

add(List.empty[Option[Int]])
// Returns None.
{% endhighlight %}

To be able to add `Order` instances without making any modifications to `add`,
we can define a `Monoid` instance for `Order`. In this case, we're piggybacking
on the `Monoid` instance for `Double`, but we could've implemented the sums and
the production of the identity element directly:

{% highlight scala %}
case class Order(totalCost: Double, quantity: Double)

object Order {
  implicit val orderMonoid: Monoid[Order] = new Monoid[Order] {
    import cats.instances.double._

    val doubleMonoid = Monoid[Double]

    def combine(x: Order, y: Order): Order =
      Order(
        totalCost = doubleMonoid.combine(x.totalCost, y.totalCost),
        quantity = doubleMonoid.combine(x.quantity, y.quantity)
      )

    def empty: Order =
      Order(
        totalCost = doubleMonoid.empty,
        quantity = doubleMonoid.empty
      )
  }
}
{% endhighlight %}
