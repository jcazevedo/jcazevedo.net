---
layout: post
date: "Sun Sep 13 18:15:40 WEST 2020"
index: 18
---

# September LeetCoding Challenge, Day 11: Maximum Product Subarray

<div class="message" markdown="1">

This is part of a series of posts about the [September LeetCoding
Challenge][september-challenge]. Check the [first post]({% post_url
2020-09-02-september-leetcoding-challenge-day-1 %}) for more information.

</div>

The problem for September 11 is [Maximum Product Subarray][problem]. You're
given a non-empty array of integers `nums` and are interested in finding the
contiguous non-empty subarray which has the largest product. You're not given
any limits on the size of `nums`.

Since we're not given any limits on the size of `nums`, I didn't assume that the
naive algorithm of checking all possible subarrays in $$\mathcal{O}(n^3)$$
(possibly reducing to $$\mathcal{O}(n^2)$$ using dynamic programming) would
work. Instead, I tried to find an algorithm whose time complexity would match
the theoretical lower bound of $$\mathcal{O}(n)$$. Some relevant observations
are:

* If the array has a single element, then the maximum product will be that
  element;
* If the array has more than one element, then the maximum product subarray will
  contain an even number of negative integers, so that it is either positive or
  0;
* If there's at least one non-empty subarray without a 0 with an even number of
  negative integers, then the maximum product will never be 0.
  
Based on the previous observations, we can derive an $$\mathcal{O}(n)$$
algorithm to solve this problem. The idea is to iterate through all the values
of `nums`, keeping track of, for the product of a non-empty subarray ending at
that number, the largest possible positive number and the smallest possible
negative number. When visiting a new number, if the number is 0, we reset both
these values. If the number is positive, both the largest positive number and
smallest negative number are multiplied by that number. If the number is
negative, the largest possible positive number becomes the multiplication of the
smallest negative number with that number, and vice-versa for the smallest
possible negative number. The largest positive number at each iteration (or 0)
is the largest product of a non-empty subarray ending at that number. The
following is an implementation of that idea:

{% highlight cpp %}
class Solution {
public:
  int maxProduct(vector<int>& nums) {
    int best_neg = -1;
    int best_pos = -1;
    int ans = nums[0];
    if (nums[0] < 0)
      best_neg = -nums[0];
    else if (nums[0] > 0)
      best_pos = nums[0];
    else {
      best_neg = -1;
      best_pos = -1;
    }
    int N = nums.size();
    for (int i = 1; i < N; ++i) {
      if (nums[i] < 0) {
        int prev_best_pos = best_pos;
        int prev_best_neg = best_neg;
        if (prev_best_neg != -1)
          best_pos = prev_best_neg * abs(nums[i]);
        else
          best_pos = -1;
        if (prev_best_pos != -1)
          best_neg = prev_best_pos * abs(nums[i]);
        else
          best_neg = abs(nums[i]);
      }
      if (nums[i] == 0) {
        best_neg = -1;
        best_pos = -1;
        ans = max(ans, 0);
      }
      if (nums[i] > 0) {
        if (best_pos != -1)
          best_pos = best_pos * nums[i];
        else
          best_pos = nums[i];
        if (best_neg != -1)
          best_neg = best_neg * nums[i];
      }
      ans = max(ans, best_pos);
    }
    return ans;
  }
};
{% endhighlight %}

[problem]: https://leetcode.com/problems/maximum-product-subarray/
[september-challenge]: https://leetcode.com/explore/challenge/card/september-leetcoding-challenge/
