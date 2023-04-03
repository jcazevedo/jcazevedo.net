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
