---
layout: post
date: "Mon Dec  7 16:40:38 WET 2020"
num: 20
---

# September LeetCoding Challenge, Day 13: Insert Interval

<div class="message" markdown="1">

This is part of a series of posts about the [September LeetCoding
Challenge][september-challenge]. Check the [first post]({% post_url
2020-09-02-september-leetcoding-challenge-day-1 %}) for more information.

</div>

I got mildly bored of writing these blog posts for the September LeetCoding
Challenge, hence this huge gap in days between the last post and this one. I
continued solving the problems, and LeetCode continued to put up challenges for
the following months. Let's see if I can at least complete the series of posts
for September.

The problem for September 13 is [Insert Interval][problem]. We are given a set
of non-overlapping intervals, represented by their start and end points, and we
are asked to return a new set of non-overlapping intervals that results from
merging a new given interval to the existing set. We are also told that the
original set of non-overlapping intervals is sorted according to their start
point.

This problem can be solved in $$\mathcal{O}(n)$$ by iterating through the list
of intervals and keeping track of an interval to merge (which originally is the
new interval). Whenever we see a new interval, we decide whether we want to
include it as is in the final set or merge with the new interval (if it
overlaps). The following is an implementation of that idea:

{% highlight cpp %}
class Solution {
public:
  vector<vector<int>>
  insert(vector<vector<int>>& intervals, vector<int>& newInterval) {
    vector<vector<int>> result;
    for (vector<int> interval : intervals) {
      if (interval[1] < newInterval[0]) {
        result.push_back(interval);
      } else if (interval[0] > newInterval[1]) {
        result.push_back(newInterval);
        newInterval = interval;
      } else if (interval[1] >= newInterval[0] ||
                 interval[0] <= newInterval[1]) {
        newInterval = {min(interval[0], newInterval[0]),
                       max(interval[1], newInterval[1])};
      }
    }
    result.push_back(newInterval);
    return result;
  }
};
{% endhighlight %}

In order to simplify the logic of handling the fact that we've gone past the new
interval to insert, the previous solution keeps replacing the interval to merge
with the current interval once the starting point of the intervals exceeds the
ending point of the interval to merge. This allows us to always push the
interval to merge at the end, without having special considerations on whether
or not it should be included. An alternative approach, but probably more
error-prone to implement, would be to keep track if the merged interval had
already been inserted or not.

[problem]: https://leetcode.com/problems/insert-interval/
[september-challenge]: https://leetcode.com/explore/challenge/card/september-leetcoding-challenge/
