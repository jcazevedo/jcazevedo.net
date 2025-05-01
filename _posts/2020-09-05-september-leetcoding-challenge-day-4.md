---
layout: post
date: "Sat Sep  5 19:31:07 WEST 2020"
---

# September LeetCoding Challenge, Day 4: Partition Labels

<div class="message" markdown="1">

This is part of a series of posts about the [September LeetCoding
Challenge][september-challenge]. Check the [first post]({% post_url
2020-09-02-september-leetcoding-challenge-day-1 %}) for more information.

</div>

The problem for September 4 is [Partition Labels][problem]. According to the
problem statement, we have a string $$S$$ of lowercase English characters which
we want to partition in as many parts as possible. The catch is that each letter
must appear in at most one part. Each part is a substring, not a subsequence of
string $$S$$. For example, given string $$S$$ equal to
`"ababcbacadefegdehijhklij"`, the valid partition that produces most parts is
`"ababcbaca"`, `"defegde"` and `"hijhklij"`.

Once we select a given character to belong to a part, then all characters with
the same letter as the chosen character must belong to that part. In sum, each
part must go as far as the last occurrence of each letter in the part. We can
solve this in $$\mathcal{O}(|S|)$$ by first identifying the indices of the last
occurrences of each letter, and then greedily collect characters for each part
until the previous restriction is satisfied. The following is an implementation
of that strategy:

{% highlight cpp %}
class Solution {
public:
  vector<int> partitionLabels(string S) {
    vector<int> ans;
    unordered_map<char, int> last;
    int N = S.size();
    for (int i = 0; i < N; ++i)
      last[S[i]] = i;
    int curr = 0;
    int prev = -1;
    for (int i = 0; i < N; ++i) {
      curr = max(curr, last[S[i]]);
      if (curr == i) {
        ans.push_back(curr - prev);
        prev = curr;
      }
    }
    return ans;
  }
};
{% endhighlight %}

[problem]: https://leetcode.com/problems/partition-labels/
[september-challenge]: https://leetcode.com/explore/challenge/card/september-leetcoding-challenge/
