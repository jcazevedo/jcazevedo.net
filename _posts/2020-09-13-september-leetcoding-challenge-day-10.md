---
layout: post
date: "Sun Sep 13 18:14:51 WEST 2020"
---

# September LeetCoding Challenge, Day 10: Bulls and Cows

<div class="message" markdown="1">

This is part of a series of posts about the [September LeetCoding
Challenge][september-challenge]. Check the [first post]({% link
_posts/2020-09-02-september-leetcoding-challenge-day-1.md %}) for more
information.

</div>

The problem for September 10 is [Bulls and Cows][problem]. You have to return
the hint for an opponent's guess in a game of [Bulls and Cows][bulls-and-cows],
the paper and pencil game that predated [Mastermind][mastermind].

To get the number of bulls, we simply count the number of digits that match in
both digit and position. For the remaining of digits, for each possible digit
value, we count the number of times there's a repeated occurrence in both the
guess and the secret. The following is an implementation of this idea:

{% highlight cpp %}
class Solution {
public:
  string getHint(string secret, string guess) {
    int N = secret.size();
    int bulls = 0, cows = 0;
    map<char, int> in_secret, in_guess;
    for (int i = 0; i < N; ++i) {
      if (secret[i] == guess[i])
        bulls++;
      else {
        in_secret[secret[i]]++;
        in_guess[guess[i]]++;
      }
    }
    for (auto itr = in_guess.begin(); itr != in_guess.end(); ++itr) {
      char ch = itr->first;
      int cnt = itr->second;
      cows += min(cnt, in_secret[ch]);
    }
    ostringstream ss;
    ss << bulls << "A" << cows << "B";
    return ss.str();
  }
};
{% endhighlight %}

[mastermind]: https://en.wikipedia.org/wiki/Mastermind_(board_game)
[bulls-and-cows]: https://en.wikipedia.org/wiki/Bulls_and_Cows
[problem]: https://leetcode.com/problems/bulls-and-cows/
[september-challenge]: https://leetcode.com/explore/challenge/card/september-leetcoding-challenge/
