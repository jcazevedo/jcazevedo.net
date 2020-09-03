---
layout: post
date: "Thu Sep  3 11:18:01 WEST 2020"
---

# September LeetCoding Challenge, Day 2: Contains Duplicate III

<div class="message" markdown="1">

This is part of a series of posts about the [September LeetCoding
Challenge][september-challenge]. Check the [first post]({% link
posts/_posts/2020-09-02-september-leetcoding-challenge-day-1.md %}) for more
information.

</div>

The problem for September 2 is [Contains Duplicate
III](https://leetcode.com/problems/contains-duplicate-iii/). The title of the
problem is a bit misleading, since the statement isn't about finding duplicates.
Instead, we're interested in finding, from an array of numbers `nums` and
integers `k` and `t`, whether there are two distinct indices `i` and `j` such
that the absolute difference of `nums[i]` and `nums[j]` is at most `t` and the
absolute difference between `i` and `j` is at most `k`.

One way to approach this problem is to, for each number in the array, check if
there is a number in the previous `k` numbers such that the absolute difference
between them is at most `k`. If we can keep a sorted list of `k` numbers at all
times, we should be able to do this in $$\mathcal{O}(n \times log(k))$$, $$n$$
being the size of the `nums` array. The $$\mathcal{O}(n)$$ part is due to the
fact that we have to iterate through all elements of `nums`. The
$$\mathcal{O}(log(k))$$ part is due to the fact that, if we can keep a sorted
list of the previous `k` numbers, we can binary search for the element that
minimizes the absolute difference. A way to implement this in C++ is to use a
`multiset` (a simple `set` doesn't work since there can be repeated elements in
`nums`). Elements in C++
[`multisets`](http://www.cplusplus.com/reference/set/multiset/) are sorted and
the interface provides both `lower_bound` and `upper_bound` methods to search
for elements in logarithmic time complexity. The following is a sample
implementation of that strategy:

{% highlight cpp %}
class Solution {
public:
  bool containsNearbyAlmostDuplicate(vector<int>& nums, int k, int t) {
    if (nums.empty() || k == 0)
      return false;
    multiset<int> current;
    current.insert(nums[0]);
    int N = nums.size();
    for (int i = 1; i < N; ++i) {
      auto l_itr = current.lower_bound(nums[i]);
      if (l_itr != current.end() &&
          abs(((long long) *l_itr) - ((long long) nums[i])) <= t)
        return true;
      if (l_itr != current.begin() &&
          abs(((long long) *(--l_itr)) - ((long long) nums[i])) <= t)
        return true;
      current.insert(nums[i]);
      if (current.size() > k)
        current.erase(current.find(nums[i - k]));
    }
    return false;
  }
};
{% endhighlight %}

We check two numbers in each iteration: the number returned by the `lower_bound`
method (which is going to be the first number that is larger than or equal to
`nums[i]`) and the number immediately before (the larger number that is smaller
than `nums[i]`). One of those is going to be the one producing the smallest
absolute difference. If the smallest absolute difference is not greater than
`t`, we have found a satisfying pair.

The casts to `long long` are necessary because, even though `t` is an `int`, the
absolute difference between two numbers in `nums` may not fit in an `int`
(consider $$|2147483647 - (-2147483648)|$$ for example).

[september-challenge]: https://leetcode.com/explore/challenge/card/september-leetcoding-challenge/
[problem]: https://leetcode.com/problems/contains-duplicate-iii/
