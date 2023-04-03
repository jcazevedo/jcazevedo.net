---
layout: post
title: 'Solutions to "Scala with Cats": Chapter 2'
---

These are my solutions to the exercises of chapter 2 of [Scala with
Cats][scala-with-cats]. The book is available for free at
[https://www.scalawithcats.com/][scala-with-cats].

[scala-with-cats]: https://www.scalawithcats.com/

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
