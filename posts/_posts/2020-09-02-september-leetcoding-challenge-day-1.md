---
layout: post
date: "Wed Sep  2 19:34:26 WEST 2020"
---

# September LeetCoding Challenge, Day 1: Largest Time for Given Digits

[LeetCode][leetcode] is a platform with programming challenges. They're designed
around helping prepare for technical interviews, but they also host programming
contests and have some [explore](https://leetcode.com/explore/) packages, which
are bundles of problems and articles. In April 2020, they started providing
monthly explore packages in the form of challenges, in which they'd add a
problem each day of the month. Solving all problems within 24 hours of their
release makes you eligible for some rewards. I have been solving these monthly
challenges for fun since April, but decided to start writing a bit about them in
September. It's very easy to find solutions for most of these problems online,
but I'll try to post these the day after the challenge, to avoid unnecessary
copying. I'm solving these problems in C++, since it's my language of choice for
this type of algorithmic programming problems.

The problem for September 1 is [Largest Time for Given Digits][problem]. The
statement is straightforward: given 4 digits, return the largest 24 hour time
(in a "HH:MM" string) that can be made using all of those digits, or an empty
string if no valid time can be made.

A possible solution for this problem is to enumerate all valid times and check
the largest one that uses all of the provided digits. Since there are at most
$$24 \times 60 = 1440$$ valid times, this is good enough to avoid a time limit
exceeded. The following is a sample implementation of that strategy:

{% highlight cpp %}
class Solution {
private:
  pair<int, int> inc(pair<int, int> curr) {
    pair<int, int> ans = {curr.first, curr.second + 1};
    if (ans.second >= 60) {
      ans.first++;
      ans.second = 0;
    }
    return ans;
  }

  bool good(unordered_map<int, int> cnt, pair<int, int>& curr) {
    cnt[curr.first / 10]--;
    cnt[curr.first % 10]--;
    cnt[curr.second / 10]--;
    cnt[curr.second % 10]--;
    for (auto itr = cnt.begin(); itr != cnt.end(); ++itr) {
      if (itr->second != 0)
        return false;
    }
    return true;
  }

public:
  string largestTimeFromDigits(vector<int>& A) {
    pair<int, int> curr = {0, 0};
    pair<int, int> best = {-1, -1};
    unordered_map<int, int> cnt;
    for (int num : A)
      cnt[num]++;
    while (curr.first < 24) {
      if (good(cnt, curr))
        best = curr;
      curr = inc(curr);
    }
    if (best.first == -1)
      return "";
    string ans = "";
    ans += (best.first / 10) + '0';
    ans += (best.first % 10) + '0';
    ans += ':';
    ans += (best.second / 10) + '0';
    ans += (best.second % 10) + '0';
    return ans;
  }
};
{% endhighlight %}

Another possible solution is to iterate through all the permutations of the
provided digits, and return the one that produces a valid time and is the
largest. Since there are only $$4! = 24$$ permutations, this runs much faster
than the previous solution. The following is a sample implementation of that
strategy:

{% highlight cpp %}
class Solution {
private:
  bool good(const vector<int>& A) {
    int hours = A[0] * 10 + A[1];
    int minutes = A[2] * 10 + A[3];
    return hours <= 23 && minutes <= 59;
  }

public:
  string largestTimeFromDigits(vector<int>& A) {
    sort(A.begin(), A.end());
    vector<int> best;
    do {
      if (good(A))
        best = A;
    } while (next_permutation(A.begin(), A.end()));
    if (best.empty())
      return "";
    string ans = "";
    ans += best[0] + '0';
    ans += best[1] + '0';
    ans += ':';
    ans += best[2] + '0';
    ans += best[3] + '0';
    return ans;
  }
};
{% endhighlight %}

After reading this problem for the first time, I was under the impression that a
greedy algorithm that would pick the next largest available digit satisfying the
following restrictions would also work:

* The digit in the tens place of the hours number must not be larger than 2;
* The digit in the ones place of the hours number must not be larger than 3 if
  the digit in the tens place of the hours number is equal to 2;
* The digit in the tens place of the minutes number must not be larger than 5.

However, it's easy to come up with a counter example in which this algorithm
would fail. If provided with the digits $$[0, 2, 6, 6]$$, the correct output
would be "06:26". However, the previously described algorithm would fail to
produce a valid answer, since it'd try to use digits $$[0, 2]$$ for the hours
and be left with $$[6, 6]$$ for the minutes, which can't produce a valid minute
number.

[leetcode]: https://leetcode.com/
[problem]: https://leetcode.com/problems/largest-time-for-given-digits/
