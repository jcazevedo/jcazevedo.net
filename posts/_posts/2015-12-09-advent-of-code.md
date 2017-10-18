---
layout: post
title: "Advent of Code"
date: "Wed Dec  9 23:41:22 WET 2015"
---

Yesterday, I started solving a series of small programming puzzles in
[Advent of Code][adventofcode]. You get one puzzle per day, as a proper advent
calendar. So far, each puzzle is divided in two parts, granting a maximum of two
stars per puzzle. The two parts of a puzzle use the same input and the second
part is usually a simple variation of the first one. You only have to submit the
output to the provided puzzles, so it's possible to do things by hand, albeit
unlikely. The puzzles so far have been simple, either by definition, or by
having small input sizes, thus not requiring efficient algorithms to be solved.
The tree lights up as you go along, giving it a nice effect.

{% include image.html 
   url="/img/adventofcodetree.png" 
   description="Advent of Code tree with 9 levels lit up." %}

I've decided to solve them all in Scala. Initially I started in C++, but in
[day 4][day4]'s puzzle it was required to find MD5 hashes and I decided to
leverage Java and Scala's standard library to ease up the process, sticking with
it for the rest of the puzzles (so far).

[adventofcode]: http://adventofcode.com/
[day4]: http://adventofcode.com/day/4
