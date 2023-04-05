---
layout: post
title: 'Solutions to "Scala with Cats": Chapter 7'
---

These are my solutions to the exercises of chapter 7 of [Scala with
Cats][scala-with-cats]. The book is available for free at
[https://www.scalawithcats.com/][scala-with-cats].

[scala-with-cats]: https://www.scalawithcats.com/

## Exercise 7.1.2: Reflecting on Folds

If we use `foldLeft` with an empty list as the accumulator and `::` as the
binary operator we get back the reversed list:

{% highlight scala %}
val list = List(1, 2, 3, 4)
list.foldLeft(List.empty[Int])((acc, e) => e :: acc)
// Returns List(4, 3, 2, 1).
{% endhighlight %}

On the other hand, if we use `foldRight` with an empty list as the accumulator
and `::` as the binary operator we get back the same list:

{% highlight scala %}
val list = List(1, 2, 3, 4)
list.foldRight(List.empty[Int])(_ :: _)
// Returns List(1, 2, 3, 4).
{% endhighlight %}
