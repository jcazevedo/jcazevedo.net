---
layout: post
date: "Tue Sep  8 11:09:18 WEST 2020"
index: 14
---

# September LeetCoding Challenge, Day 7: Word Pattern

<div class="message" markdown="1">

This is part of a series of posts about the [September LeetCoding
Challenge][september-challenge]. Check the [first post]({% post_url
2020-09-02-september-leetcoding-challenge-day-1 %}) for more information.

</div>

The problem for September 7 is [Word Pattern][problem]. You're given two
strings. One of them consists of lowercase letters and the other consists of
lowercase letters separated by spaces. You want to find out if a
[bijection][bijection] exists between the characters of the first string and the
words in the second string. In other words, you want to return `true` if there
is a one-to-one correspondence between the characters of the first string and
the characters of the second string, and `false` otherwise.

If the number of words is different from the number of characters, then you can
be sure that no bijection exists. If the number of words is the same, we can go
word by word and check if a word happens to be mapped to different characters.
If it does, then no bijection exists. This is still not sufficient to determine
a bijection, since the same character can still be mapped to different words. In
order for a bijection to exist, the number of different words must be equal to
the number of different characters. Combining all those checks lets us determine
if there is a one-to-one correspondence between characters and words. The
following is an implementation of the previous idea:

{% highlight cpp %}
class Solution {
private:
  vector<string> split(string str) {
    istringstream ss(str);
    vector<string> ans;
    string curr;
    while (ss >> curr)
      ans.push_back(curr);
    return ans;
  }

public:
  bool wordPattern(string pattern, string str) {
    vector<string> words = split(str);
    if (words.size() != pattern.size())
      return false;
    unordered_map<string, char> pat;
    set<char> used;
    int N = words.size();
    for (int i = 0; i < N; ++i) {
      if (pat.find(words[i]) != pat.end() && pat[words[i]] != pattern[i])
        return false;
      pat[words[i]] = pattern[i];
      used.insert(pattern[i]);
    }
    return pat.size() == used.size();
  }
};
{% endhighlight %}

[bijection]: https://en.wikipedia.org/wiki/Bijection
[problem]: https://leetcode.com/problems/word-pattern/
[september-challenge]: https://leetcode.com/explore/challenge/card/september-leetcoding-challenge/
