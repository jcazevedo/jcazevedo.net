---
layout: post
date: "Wed Sep  9 10:55:45 WEST 2020"
---

# September LeetCoding Challenge, Day 8: Sum of Root To Leaf Binary Numbers

<div class="message" markdown="1">

This is part of a series of posts about the [September LeetCoding
Challenge][september-challenge]. Check the [first post]({% post_url
2020-09-02-september-leetcoding-challenge-day-1 %}) for more information.

</div>

The problem for September 8 is [Sum of Root to Leaf Binary Numbers][problem].
You're given a binary tree in which each node has value 0 or 1. In this case,
each path from the root to a leaf represents a binary number starting with the
most significant bit. For example, a path from root to leaf $$0 \rightarrow 1
\rightarrow 1 \rightarrow 0 \rightarrow 1$$ represents the number $$01101$$ in
binary, or $$13$$ in decimal. We're interested in the sum of numbers produced
from the paths from the root to every leaf in the tree.

We're told that the number of nodes in the tree doesn't exceed 1000 and that the
sum will not exceed $$2^{31} - 1$$. Therefore, we can do a [DFS][dfs] on the
tree while keeping track of the number at each path, accumulating the current
number whenever we reach a leaf. Since the path follows the significance of the
bits in the resulting number, we can keep track of the current number while
traversing the tree by multiplying the current number by 2 whenever we go either
left or right, and sum the value at the node we're visiting. The following is an
implementation of this idea:

{% highlight cpp %}
class Solution {
private:
  void dfs(TreeNode* curr, int curr_value, int& curr_sum) {
    if (curr == nullptr)
      return;
    bool is_leaf = curr->left == nullptr && curr->right == nullptr;
    curr_value = curr_value * 2 + curr->val;
    if (is_leaf)
      curr_sum += curr_value;
    if (curr->left != nullptr)
      dfs(curr->left, curr_value, curr_sum);
    if (curr->right != nullptr)
      dfs(curr->right, curr_value, curr_sum);
  }

public:
  int sumRootToLeaf(TreeNode* root) {
    int ans = 0;
    dfs(root, 0, ans);
    return ans;
  }
};
{% endhighlight %}

[dfs]: https://en.wikipedia.org/wiki/Depth-first_search
[problem]: https://leetcode.com/problems/sum-of-root-to-leaf-binary-numbers/
[september-challenge]: https://leetcode.com/explore/challenge/card/september-leetcoding-challenge/
