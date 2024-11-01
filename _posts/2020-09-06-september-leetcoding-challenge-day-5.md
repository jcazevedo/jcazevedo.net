---
layout: post
date: "Sun Sep  6 11:47:06 WEST 2020"
num: 12
---

# September LeetCoding Challenge, Day 5: All Elements in Two Binary Search Trees

<div class="message" markdown="1">

This is part of a series of posts about the [September LeetCoding
Challenge][september-challenge]. Check the [first post]({% post_url
2020-09-02-september-leetcoding-challenge-day-1 %}) for more information.

</div>

The problem for September 5 is [All Elements in Two Binary Search
Trees][problem]. We're interested in, given two binary search trees of integers,
returning a sorted list of all the integers from both trees.

Since we're dealing with [binary search trees][bst] here, each node is
guaranteed to store a key greater than all the keys in the node's left subtree
and less than those in its right subtree. As such, an [in-order
traversal][in-order] of the tree is guaranteed to produce a sorted list of its
elements. We can do an in-order traversal of a binary tree with $$n$$ nodes in
$$\mathcal{O}(n)$$. Having two sorted lists of size $$a$$ and $$b$$, we can
merge them in a new sorted list in $$\mathcal{O}(a + b)$$. With these two
building blocks, we can produce an algorithm to return the sorted list of all
integers of both trees in $$\mathcal{O}(n + m)$$, $$n$$ being the number of
nodes in the first tree, and $$m$$ being the number of nodes in the second tree.
The following is an implementation of that idea:

{% highlight cpp %}
class Solution {
private:
  void in_order_traverse(TreeNode* curr, vector<int>& list) {
    if (curr != nullptr) {
      in_order_traverse(curr->left, list);
      list.push_back(curr->val);
      in_order_traverse(curr->right, list);
    }
  }

public:
  vector<int> getAllElements(TreeNode* root1, TreeNode* root2) {
    vector<int> list1, list2;
    in_order_traverse(root1, list1);
    in_order_traverse(root2, list2);
    vector<int> ans;
    int N1 = list1.size(), N2 = list2.size(), i1 = 0, i2 = 0;
    while (i1 < N1 || i2 < N2) {
      if (i1 >= N1)
        ans.push_back(list2[i2++]);
      else if (i2 >= N2)
        ans.push_back(list1[i1++]);
      else if (list1[i1] < list2[i2])
        ans.push_back(list1[i1++]);
      else
        ans.push_back(list2[i2++]);
    }
    return ans;
  }
};
{% endhighlight %}

[bst]: https://en.wikipedia.org/wiki/Binary_search_tree
[in-order]: https://en.wikipedia.org/wiki/Tree_traversal#In-order_(LNR)
[problem]: https://leetcode.com/problems/all-elements-in-two-binary-search-trees/
[september-challenge]: https://leetcode.com/explore/challenge/card/september-leetcoding-challenge/
