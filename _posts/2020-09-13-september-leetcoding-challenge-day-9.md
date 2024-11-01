---
layout: post
date: "Sun Sep 13 18:13:53 WEST 2020"
num: 16
---

# September LeetCoding Challenge, Day 9: Compare Version Numbers

<div class="message" markdown="1">

This is part of a series of posts about the [September LeetCoding
Challenge][september-challenge]. Check the [first post]({% post_url
2020-09-02-september-leetcoding-challenge-day-1 %}) for more information.

</div>

The problem for September 9 is [Compare Version Numbers][problem]. Given two
version numbers `version1` and `version2`, represented as strings, you want to
return -1 if `version1` is smaller than `version2`, 1 if `version1` is larger
than `version2`, and 0 if they're equal. Versions are strings consisting of one
or more revisions joined by a `.`. Each revision consists of digits only, but
may contain leading zeros. Every revision contains at least one character, so
it's impossible for a substring of two `.` to exist. Comparing versions consists
in comparing the integer value of its revisions in left-to-right order. If a
version doesn't specify a revision at a given index, then the revision should be
treated as 0.

A solution for this problem consists in splitting the two provided strings in
two sequences of numbers and do a pairwise comparison of them. Whenever a
version number is missing a revision, assume 0 as its value. The following is an
implementation of this strategy:

{% highlight cpp %}
class Solution {
private:
  int str_to_int(string str) {
    int ans;
    istringstream ss(str);
    ss >> ans;
    return ans;
  }

  vector<int> split_version(string version) {
    vector<int> ans;
    size_t pos;
    while ((pos = version.find('.')) != string::npos) {
      ans.push_back(str_to_int(version.substr(0, pos)));
      version.erase(0, pos + 1);
    }
    ans.push_back(str_to_int(version));
    return ans;
  }

public:
  int compareVersion(string version1, string version2) {
    vector<int> v1 = split_version(version1);
    vector<int> v2 = split_version(version2);
    int N1 = v1.size(), N2 = v2.size(), i = 0;
    while (i < N1 || i < N2) {
      int p1 = i < N1 ? v1[i] : 0;
      int p2 = i < N2 ? v2[i] : 0;
      if (p1 < p2)
        return -1;
      if (p1 > p2)
        return 1;
      i++;
    }
    return 0;
  }
};
{% endhighlight %}

[problem]: https://leetcode.com/problems/compare-version-numbers/
[september-challenge]: https://leetcode.com/explore/challenge/card/september-leetcoding-challenge/
