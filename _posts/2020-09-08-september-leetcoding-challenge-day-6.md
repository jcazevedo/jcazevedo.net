---
layout: post
date: "Tue Sep  8 00:19:42 WEST 2020"
---

# September LeetCoding Challenge, Day 6: Image Overlap

<div class="message" markdown="1">

This is part of a series of posts about the [September LeetCoding
Challenge][september-challenge]. Check the [first post]({% post_url
2020-09-02-september-leetcoding-challenge-day-1 %}) for more information.

</div>

The problem for September 6 is [Image Overlap][problem]. You're given two images
represented as binary, square matrices, of the same size. You want to translate
one of the images by sliding it left, right, up or down any number of units such
that, when placed on top of the other image, the number of 1s that overlap in
both images is maximized. The length of the side of the images is at most 30.

The length of the side of the images is small enough for us to try all possible
translations in $$\mathcal{O}(n^4)$$. The following is an implementation of that
strategy:

{% highlight cpp %}
class Solution {
public:
  int largestOverlap(vector<vector<int>>& A, vector<vector<int>>& B) {
    int L = A.size(), ans = 0;
    for (int di = -L + 1; di < L; ++di) {
      for (int dj = -L + 1; dj < L; ++dj) {
        int curr = 0;
        for (int i = 0; i < L; ++i) {
          for (int j = 0; j < L; ++j) {
            int bi = i + di, bj = j + dj, vb = 0;
            if (bi >= 0 && bi < L && bj >= 0 && bj < L)
              vb = B[bi][bj];
            if (A[i][j] == 1 && vb == 1)
              curr++;
          }
        }
        ans = max(ans, curr);
      }
    }
    return ans;
  }
};
{% endhighlight %}

[problem]: https://leetcode.com/problems/image-overlap/
[september-challenge]: https://leetcode.com/explore/challenge/card/september-leetcoding-challenge/
