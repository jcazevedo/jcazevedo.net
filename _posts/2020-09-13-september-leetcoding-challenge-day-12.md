---
layout: post
date: "Sun Sep 13 18:16:32 WEST 2020"
num: 19
---

# September LeetCoding Challenge, Day 12: Combination Sum III

<div class="message" markdown="1">

This is part of a series of posts about the [September LeetCoding
Challenge][september-challenge]. Check the [first post]({% post_url
2020-09-02-september-leetcoding-challenge-day-1 %}) for more information.

</div>

The problem for September 12 is [Combination Sum III][problem]. We are
interested in finding all possible distinct combinations of $$k$$ numbers that
add up to a number $$n$$, given that only numbers from $$1$$ to $$9$$ can be
used and each combination should be a unique set of numbers. Since you can only
use numbers from $$1$$ to $$9$$, both $$k$$ and $$n$$ can't be negative; $$k$$
is at most $$9$$ and $$n$$ is at most $$\sum_{i=1}^{9} i = \frac{9 \times (9 +
1)}{2} = 45$$.

An exhaustive search using a [DFS][dfs] is possible given these limits, so it
looks like a good candidate for a solution. The following is an implementation
of that:

{% highlight cpp %}
class Solution {
private:
  vector<vector<int>> ans;
  vector<int> next;

  void dfs(int curr_sum, int next_num, int n_nums, int k, int n) {
    if (n_nums == k) {
      if (curr_sum == n)
        ans.push_back(next);
      return;
    }
    for (int i = next_num; i <= 9; ++i) {
      if (curr_sum + i > n)
        continue;
      next.push_back(i);
      dfs(curr_sum + i, i + 1, n_nums + 1, k, n);
      next.pop_back();
    }
  }

public:
  vector<vector<int>> combinationSum3(int k, int n) {
    ans.clear();
    next.clear();
    dfs(0, 1, 0, k, n);
    return ans;
  }
};
{% endhighlight %}

[dfs]: https://en.wikipedia.org/wiki/Depth-first_search
[problem]: https://leetcode.com/problems/combination-sum-iii/
[september-challenge]: https://leetcode.com/explore/challenge/card/september-leetcoding-challenge/
