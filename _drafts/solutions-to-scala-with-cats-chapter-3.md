---
layout: post
title: 'Solutions to "Scala with Cats": Chapter 3'
---

These are my solutions to the exercises of chapter 3 of [Scala with
Cats][scala-with-cats]. The book is available for free at
[https://www.scalawithcats.com/][scala-with-cats].

[scala-with-cats]: https://www.scalawithcats.com/

## Exercise 3.5.4: Branching out with Functors

A `Functor` for `Tree` can be implemented as follows:

{% highlight scala %}
import cats.Functor

implicit val treeFunctor: Functor[Tree] = new Functor[Tree] {
  def map[A, B](fa: Tree[A])(f: A => B): Tree[B] =
    fa match {
      case Branch(left, right) =>
        Branch(map(left)(f), map(right)(f))

      case Leaf(value) =>
        Leaf(f(value))
    }
}
{% endhighlight %}

Note that the implementation above is not stack-safe, but I didn't worry to much
about it. We can check that the implementation works as expected by using `map`
over some `Tree` instances:

{% highlight scala %}
import cats.syntax.functor._

val tree: Tree[Int] = Branch(Branch(Leaf(1), Leaf(2)), Branch(Leaf(3), Leaf(4)))

tree.map(_ * 2)
// Returns Branch(Branch(Leaf(2),Leaf(4)),Branch(Leaf(6),Leaf(8))).

tree.map(_.toString)
// Returns Branch(Branch(Leaf("1"),Leaf("2")),Branch(Leaf("3"),Leaf("4"))).
{% endhighlight %}

On the above, we won't be able to call `map` directly over instances of `Branch`
or `Leaf` because we don't have `Functor` instances in place for those types. To
make the API more friendly, we can add smart constructors to `Tree` (i.e.
`branch` and `leaf` methods that return instances of type `Tree`).

## Exercise 3.6.1.1: Showing off with Contramap

To implement the `contramap` method, we can create a `Printable` instance that
uses the `format` of the instance it's called on (note the `self` reference) and
uses `func` to transform the value to an appropriate type:

{% highlight scala %}
trait Printable[A] { self =>
  def format(value: A): String

  def contramap[B](func: B => A): Printable[B] =
    new Printable[B] {
      def format(value: B): String =
        self.format(func(value))
    }
}
{% endhighlight %}

With this `contramap` method in place, it becomes simpler to define a
`Printable` instance for our `Box` case class:

{% highlight scala %}
final case class Box[A](value: A)

object Box {
  implicit def printableBox[A](implicit p: Printable[A]): Printable[Box[A]] =
    p.contramap(_.value)
}
{% endhighlight %}

## Exercise 3.6.2.1: Transformative Thinking with _imap_

To implement `imap` for `Codec`, we need to rely on the `encode` and `decode`
methods of the instance `imap` is called on:

{% highlight scala %}
trait Codec[A] { self =>
  def encode(value: A): String
  def decode(value: String): A
  def imap[B](dec: A => B, enc: B => A): Codec[B] =
    new Codec[B] {
      def encode(value: B): String = self.encode(enc(value))
      def decode(value: String): B = dec(self.decode(value))
    }
}
{% endhighlight %}

Similarly to what's described in the chapter, we can create a `Codec` for
`Double` by piggybacking on the `Codec` for `String` that we already have in
place:

{% highlight scala %}
implicit val doubleCodec: Codec[Double] =
  stringCodec.imap(_.toDouble, _.toString)
{% endhighlight %}

When implementing the `Codec` for `Box`, we can use `imap` and describe how to
box and unbox a value, respectively:

{% highlight scala %}
final case class Box[A](value: A)

object Box {
  implicit def codec[A](implicit c: Codec[A]): Codec[Box[A]] =
    c.imap(Box.apply, _.value)
}
{% endhighlight %}
