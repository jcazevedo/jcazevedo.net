---
layout: post
title: 'Solutions to "Scala with Cats": Chapter 1'
date: 2023-03-25 20:13 +0000
---
These are my solutions to the exercises of chapter 1 of [Scala with
Cats][scala-with-cats]. The book is available for free at
[https://www.scalawithcats.com/][scala-with-cats].

## Table of Contents

- [Setting Up the Scala Project](#setting-up-the-scala-project)
- [Exercise 1.3: Printable Library](#exercise-13-printable-library)
- [Exercise 1.4.6: Cat Show](#exercise-146-cat-show)
- [Exercise 1.5.5: Equality, Liberty, and Felinity](#exercise-155-equality-liberty-and-felinity)

[scala-with-cats]: https://www.scalawithcats.com/

## Setting Up the Scala Project

I solved the exercises in a sandbox Scala project that has [Cats][cats] as a
dependency. The book recommends using a Giter8 template, so that's what I used:

{% highlight bash %}
$ sbt new scalawithcats/cast-seed.g8
{% endhighlight %}

The above command generates (at the time of writing) a minimal project with the
following `build.sbt` file:

{% highlight scala %}
name := "scala-with-cats"
version := "0.0.1-SNAPSHOT"

scalaVersion := "2.13.8"

libraryDependencies += "org.typelevel" %% "cats-core" % "2.8.0"

// scalac options come from the sbt-tpolecat plugin so need to set any here

addCompilerPlugin("org.typelevel" %% "kind-projector" % "0.13.2" cross CrossVersion.full)
{% endhighlight %}

The above differs a bit from what the book lists, since there are both new Scala
2.13 and Cats versions out already, but I followed along using these settings
with minimal issues.

[cats]: https://github.com/typelevel/cats

## Exercise 1.3: Printable Library

The definition of the `Printable` type class can be as follows:

{% highlight scala %}
trait Printable[A] {
  def format(value: A): String
}
{% endhighlight %}

In terms of defining the `Printable` instances for Scala types, I'd probably
prefer to include those in the companion object of `Printable` so that they were
readily available in the implicit scope, but the exercise asks us explicitly to
create a `PrintableInstances` object:

{% highlight scala %}
object PrintableInstances {
  implicit val stringPrintable: Printable[String] =
    new Printable[String] {
      def format(value: String): String = value
    }

  implicit val intPrintable: Printable[Int] =
    new Printable[Int] {
      def format(value: Int): String = value.toString
    }
}
{% endhighlight %}

The interface methods in the companion object of `Printable` can be defined as
follows:

{% highlight scala %}
object Printable {
  def format[A](value: A)(implicit p: Printable[A]): String =
    p.format(value)

  def print[A](value: A)(implicit p: Printable[A]): Unit =
    println(p.format(value))
}
{% endhighlight %}

On the above, the `print` method could have relied on the `format` method
directly, but I opted to not have the unnecessary call.

For the `Cat` example, we can define a `Printable` instance for that data type
directly in its companion object:

{% highlight scala %}
final case class Cat(name: String, age: Int, color: String)

object Cat {
  implicit val printable: Printable[Cat] =
    new Printable[Cat] {
      import PrintableInstances._

      val sp = implicitly[Printable[String]]
      val ip = implicitly[Printable[Int]]

      def format(value: Cat): String = {
        val name = sp.format(value.name)
        val age = ip.format(value.age)
        val color = sp.format(value.color)
        s"$name is a $age year-old $color cat."
      }
    }
}
{% endhighlight %}

This allows us to use the `Printable` instance without explicit imports:

{% highlight scala %}
val garfield = Cat("Garfield", 41, "ginger and black")
Printable.print(garfield)
// Prints "Garfield is a 41 year-old ginger and black cat.".
{% endhighlight %}

For the extension methods, we can define the `PrintableSyntax` object as
follows:

{% highlight scala %}
object PrintableSyntax {
  implicit class PrintableOps[A](val value: A) extends AnyVal {
    def format(implicit p: Printable[A]): String =
      p.format(value)

    def print(implicit p: Printable[A]): Unit =
      println(p.format(value))
  }
}
{% endhighlight %}

I have opted to use a value class for performance reasons, but for the purpose
of this exercise it was likely unnecessary.

By importing `PrintableSyntax._` we can now call `print` directly on our `Cat`
instance:

{% highlight scala %}
import PrintableSyntax.__

val garfield = Cat("Garfield", 41, "ginger and black")
garfield.print
// Prints "Garfield is a 41 year-old ginger and black cat.".
{% endhighlight %}

## Exercise 1.4.6: Cat Show

To implement the previous example using `Show` instead of `Printable`, we need
to define an instance of `Show` for `Cat`. Similar to the approach taken before,
we're defining the instance directly in the companion object of `Cat`:

{% highlight scala %}
import cats.Show

final case class Cat(name: String, age: Int, color: String)

object Cat {
  implicit val show: Show[Cat] =
    new Show[Cat] {
      val stringShow = Show[String]
      val intShow = Show[Int]

      def show(t: Cat): String = {
        val name = stringShow.show(t.name)
        val age = intShow.show(t.age)
        val color = stringShow.show(t.color)
        s"$name is a $age year-old $color cat."
      }
    }
}
{% endhighlight %}

Cats implements summoners for the `Show` type class, so we no longer need to use
`implicitly`.

This can be used as follows:

{% highlight scala %}
import cats.implicits._

val garfield = Cat("Garfield", 41, "ginger and black")
println(garfield.show)
// Prints "Garfield is a 41 year-old ginger and black cat.".
{% endhighlight %}

Cats doesn't have an extension method to directly print an instance using its
`Show` instance, so we're using `println` with the value returned by the `show`
call.

## Exercise 1.5.5: Equality, Liberty, and Felinity

A possible `Eq` instance for `Cat` can be implemented as follows. Similar to the
above, I've opted to include it in the companion object of `Cat`.

{% highlight scala %}
object Cat {
  implicit val eq: Eq[Cat] =
    new Eq[Cat] {
      val stringEq = Eq[String]
      val intEq = Eq[Int]

      def eqv(x: Cat, y: Cat): Boolean =
        stringEq.eqv(x.name, y.name) && intEq.eqv(x.age, y.age) && stringEq.eqv(x.color, y.color)
    }
}
{% endhighlight %}

We can now use it to compare `Cat` instances:

{% highlight scala %}
import cats.implicits._

val cat1 = Cat("Garfield", 38, "orange and black")
val cat2 = Cat("Heathcliff", 33, "orange and black")
val optionCat1 = Option(cat1)
val optionCat2 = Option.empty[Cat]

cat1 === cat2
// Returns false.

cat1 === cat1
// Returns true.

optionCat1 === optionCat2
// Returns false.
{% endhighlight %}
