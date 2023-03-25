---
layout: post
date: "Fri Sep  4 11:38:52 WEST 2020"
---

# September LeetCoding Challenge, Day 3: Repeated Substring Pattern

<div class="message" markdown="1">

This is part of a series of posts about the [September LeetCoding
Challenge][september-challenge]. Check the [first post]({% link
_posts/2020-09-02-september-leetcoding-challenge-day-1.md %}) for more
information.

</div>

The problem for September 3 is [Repeated Substring Pattern][problem]. The
problem statement is straightforward: given an non-empty string of at most 10000
characters, check if it can be constructed by taking a substring of it and
appending multiple (more than one) copies of it. In other words, the function
should return true if, for a given string $$s$$, there exists a proper substring
$$m$$ of $$s$$ such that $$s = m + \dots + m = n \times m$$, for $$n > 1$$.

The size of the string is small enough to check all proper substrings of $$s$$
(in $$\mathcal{O}(n^2)$$ time). The following is an implementation of that
strategy:

{% highlight cpp %}
class Solution {
private:
  bool is_rep(const string& rep, const string& s) {
    int R = rep.size(), S = s.size(), ir = 0;
    if (R == S || S % R != 0)
      return false;
    for (int i = 0; i < S; ++i) {
      if (s[i] != rep[ir])
        return false;
      ir = (ir + 1) % R;
    }
    return ir == 0;
  }

public:
  bool repeatedSubstringPattern(string s) {
    string rep = "";
    for (char ch : s) {
      rep += ch;
      if (is_rep(rep, s))
        return true;
    }
    return false;
  }
};
{% endhighlight %}

The previous solution is good enough, but some improvements can still be
performed under the same strategy. Namely, it's not necessary to check for
substrings larger than half the size of $$s$$, and there's no need to build a
new string for the prefix (we can just keep track of the size of the substring
under consideration). However, those improvements don't improve the asymptotic
time complexity of the solution.

One key observation for a solution with a better asymptotic time complexity is
that if we have a string $$s$$ of size $$N$$ composed of $$n$$ repetitions of
substring $$m$$ (let's say that $$s = n \times m$$), and we append string $$s$$
onto itself (i.e. we have $$s + s = 2 \times n \times m$$), then $$s$$ can also
be found in $$s + s$$ starting in an index other than $$0$$ or $$N$$ (since
$$|s + s| = 2N$$). Building on this insight, we can append $$s$$ onto itself,
remove the first and last character of it and try to find an occurrence of $$s$$
in the resulting string. If we find it, then $$s$$ must be built using a
repeated substring pattern. We remove the first and last character to avoid
finding the instances of $$s$$ starting at index $$0$$ and index $$N$$. If we're
able to find $$s$$ in the resulting string in $$\mathcal{O}(N)$$, then we arrive
at an $$\mathcal{O}(N)$$ solution for this problem. The
[Knuth-Morris-Pratt][kmp] (KMP) algorithm allows searching for occurrences of a
word $$W$$ within a main text string $$S$$ in $$\mathcal{O}(|W|) +
\mathcal{O}(|S|)$$ using $$\mathcal{O}(|W|)$$ extra space, and is therefore
suitable for our use case. I won't go into details describing the KMP algorithm.
The following is an implementation of the previously described strategy:

{% highlight cpp %}
class Solution {
private:
  bool kmp(const string& W, const string& S) {
    int M = W.size(), N = S.size();
    vector<int> T(M, 0);
    int len = 0;
    T[0] = 0;
    int i = 1;
    while (i < M) {
      if (W[i] == W[len]) {
        len++;
        T[i] = len;
        i++;
      } else if (len != 0) {
        len = T[len - 1];
      } else {
        T[i] = 0;
        i++;
      }
    }
    int j;
    i = j = 0;
    while (i < N) {
      if (W[j] == S[i]) {
        j++;
        i++;
      }
      if (j == M)
        return true;
      if (W[j] != S[i]) {
        if (j != 0)
          j = T[j - 1];
        else
          i = i + 1;
      }
    }
    return false;
  }

public:
  bool repeatedSubstringPattern(string s) {
    string res = (s + s).substr(1, s.size() * 2 - 2);
    return kmp(s, res);
  }
};
{% endhighlight %}

[kmp]: https://en.wikipedia.org/wiki/Knuth%E2%80%93Morris%E2%80%93Pratt_algorithm
[problem]: https://leetcode.com/problems/repeated-substring-pattern/
[september-challenge]: https://leetcode.com/explore/challenge/card/september-leetcoding-challenge/
