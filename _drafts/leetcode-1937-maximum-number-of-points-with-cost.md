---
layout: post
index: 36
---

# LeetCode 1937: Maximum Number of Points with Cost

[LeetCode][leetcode][^1]'s daily challenge[^2] for the 17th of August 2024 was a
fun little problem whose solution is interesting enough to provide a dedicated
write-up.

The problem is named [Maximum Number of Points with Cost][leetcode-1937]. In the
problem, we are given an $$M \times N$$ integer matrix named $$points$$ from
which we want to maximize the number of points we can get from. To gain points
from a matrix, we must pick exactly one cell in each row. By picking the cell
with coordinates $$(r, c)$$ we add $$points[r][c]$$ to the score. There is,
however, a caveat that prevents us from being greedy and always choosing the
cell with most points from each row: for every two adjacent rows $$r$$ and $$r +
1$$, picking cells at coordinates $$(r, c_1)$$ and $$(r + 1, c_2)$$ will
subtract $$\operatorname{abs}(c_1 - c_2)$$ from the total score. In other words,
the horizontal distance between selected cells in adjacent rows is subtracted
from the total score.

In terms of constraints, we have, for $$M$$ being the number of rows and $$N$$
being the number of columns:

- $$1 \leq M \leq 10^5$$;
- $$1 \leq N \leq 10^5$$;
- $$1 \leq M \times N \leq 10^5$$;
- $$0 \leq points[r][c] \leq 10^5$$.

We can take a look at some example inputs to better understand how we can get
points from a matrix:

<img class="center-image" src="/img/36/matrix1.svg" width="200rem">

Using the above matrix as input, the maximum number of points we can achieve is
obtained from selecting the maximum value from each row, for a total of $$3 -
1 + 5 - 1 + 3 = 9$$ points.

<img class="center-image" src="/img/36/matrix2.svg" width="200rem">

Using the above matrix as input, it is preferable to not select the maximum
value from the first row (the $$6$$), because we would be penalized by $$2$$ if
we were to select the $$5$$ from the second row. Since all selected cells lie in
the same column, we get a total of $$5 + 5 + 5 = 15$$ points. If we were to
change the selected cell from the first row from the 5 to the 6, we would get a
total of $$6 - 2 + 5 + 5 = 14$$ points.

There are various ways to approach this problem. We are going to take a look at
some of them, even those that won't lead to accepted solutions given the problem
constraints.

## Brute Force

A potential brute force solution involves checking every possible combination of
selections for each row. Since we have $$N$$ options per row and $$M$$ rows, a
brute force approach would lead to a time complexity of $$\mathcal{O}(N^M)$$.
Even though it is not a practical approach given the problem constraints, let's
see how a brute force solution would look like:

{% highlight cpp %}
#include <algorithm>
#include <cmath>
#include <queue>
#include <tuple>
#include <vector>

using namespace std;

class Solution {
 public:
  long long maxPoints(vector<vector<int>>& points) {
    int M = points.size(), N = points[0].size();
    queue<tuple<int, int, long long>> q;
    for (int c = 0; c < N; ++c) { q.push({0, c, points[0][c]}); }
    long long ans = 0L;
    int currRow, currCol;
    long long currPoints;
    while (!q.empty()) {
      tie(currRow, currCol, currPoints) = q.front();
      q.pop();
      if (currRow == M - 1) {
        ans = max(ans, currPoints);
      } else {
        for (int c = 0; c < N; ++c) {
          q.push({currRow + 1, c, currPoints + points[currRow + 1][c] - abs(currCol - c)});
        }
      }
    }
    return ans;
  }
};
{% endhighlight %}

On the C++ sample code above, we're doing a breadth-first search[^3] over the
state of possible solutions. Each search state is comprised of the current row,
current column and points gathered so far. We produce new search states by
checking how many points we would get for every cell in the next row. Once we
reach the bottom row we don't expand our search state further and update our
current best score accordingly. As expected by the problem constraints, the
above code is going to exceed the time (and likely memory) limit of the online
judge.

## Brute Force with Cuts

Building on the brute force approach above, we can avoid complete search paths
if we don't explore search states that have less points than the maximum we have
observed so far for that cell.

{% highlight cpp %}
#include <algorithm>
#include <cmath>
#include <queue>
#include <tuple>
#include <vector>

using namespace std;

class Solution {
 public:
  long long maxPoints(vector<vector<int>>& points) {
    int M = points.size(), N = points[0].size();
    queue<tuple<int, int, long long>> q;
    vector<vector<long long>> maxSoFar(M, vector<long long>(N, 0L));
    for (int c = 0; c < N; ++c) {
      q.push({0, c, points[0][c]});
      maxSoFar[0][c] = points[0][c];
    }
    long long ans = 0L;
    int currRow, currCol;
    long long currPoints;
    while (!q.empty()) {
      tie(currRow, currCol, currPoints) = q.front();
      q.pop();
      if (currRow == M - 1) {
        ans = max(ans, currPoints);
      } else {
        for (int c = 0; c < N; ++c) {
          long long nextPoints = currPoints + points[currRow + 1][c] - abs(currCol - c);
          if (nextPoints > maxSoFar[currRow + 1][c]) {
            maxSoFar[currRow + 1][c] = nextPoints;
            q.push({currRow + 1, c, nextPoints});
          }
        }
      }
    }
    return ans;
  }
};
{% endhighlight %}

The time complexity of the solution above is still $$\mathcal{O}(N^M)$$, but
avoids entire search paths for some inputs. It is still not good enough to be
accepted.

## Dynamic Programming

Given that $$M \times N$$ is at most $$10^5$$, a $$\mathcal{O}(M \times N)$$
solution or even a $$\mathcal{O}(M \times N \times \log(N))$$ or $$\mathcal{O}(M
\times N \times \log(M))$$ solution would work, but anything assymptotically
larger would be challenging. Let's see if there's an opportunity to reuse
previous computations when building our solution.

There are some observations we can make in order to base our solution in terms
of smaller subproblems. To compute the maximum number of points for a given cell
of a row $$r$$ we only need the maximum number of points we can obtain from each
cell in row $$r - 1$$.

To illustrate this idea, let's consider the following matrix:

<img class="center-image" src="/img/36/matrix3.svg" width="200rem">

Let's go row by row and fill each cell with the maximum points we could get by
picking it at that point:

<img class="center-image" src="/img/36/matrix4.svg" width="200rem">

Looking at the above, we can make some observations:

* The first row is equal to the first row of $$points$$.
* On each subsequent row $$r$$, we only need the values from row $$r - 1$$ to
  compute the best we can get for each cell. For example, at the second row, we
  chose $$10$$ for its maximum value since it's the value we get from $$5 +
  \max(5 + 0, 1 - 1, 6 - 2)$$.

More formally, if $$f(r, c)$$ is the maximum number of points we can get at cell
$$(r, c)$$ then we can arrive at the following recurrence based on this idea:

$$
f(r, c) = \left\{
  \begin{array}{ll}
      points[r][c], & \mbox{if $r = 0$}.\\
      \smash{points[r][c] + \displaystyle\max_{0 \leq c_{prev} < N}} (f(r - 1, c_{prev}) - \operatorname{abs}(c - c_{prev})), & \mbox{otherwise}.
  \end{array}
\right.
$$

With the above recurrence in place, the solution to our problem is given by:

$$
\smash{\displaystyle\max_{0 \leq c < N}} f(M - 1, c)
$$

We can implement the idea above with the following C++ code:

{% highlight cpp %}
#include <algorithm>
#include <cmath>
#include <vector>

using namespace std;

class Solution {
 public:
  long long maxPoints(vector<vector<int>>& points) {
    int M = points.size(), N = points[0].size();
    vector<vector<long long>> dp(M, vector<long long>(N, 0L));
    for (int c = 0; c < N; ++c) { dp[0][c] = points[0][c]; }
    for (int r = 1; r < M; ++r) {
      for (int c = 0; c < N; ++c) {
        for (int cp = 0; cp < N; ++cp) {
          dp[r][c] = max(dp[r][c], dp[r - 1][cp] - abs(c - cp) + points[r][c]);
        }
      }
    }
    long long ans = 0L;
    for (int c = 0; c < N; ++c) { ans = max(ans, dp[M - 1][c]); }
    return ans;
  }
};
{% endhighlight %}

This is better than our brute force approach, but we are at a time complexity of
$$\mathcal{O}(M \times N^2)$$, which is still not good enough to get accepted.

In order to improve the time complexity, let's focus on what we are doing to
compute $$f(r, c)$$ for $$r \neq 0$$:

$$
\smash{points[r][c] + \displaystyle\max_{0 \leq c_{prev} < N}} (f(r - 1, c_{prev}) - \operatorname{abs}(c - c_{prev}))
$$

Can we avoid iterating through all possible values of $$c_{prev}$$ for every
$$(r, c)$$ pair? If we could produce a function $$g(r, c)$$ that would give us
the best selection from the previous row for a given $$c$$ column we could
rewrite our recurrence as:

$$
f(r, c) = \left\{
  \begin{array}{ll}
      points[r][c], & \mbox{if $r = 0$}.\\
      points[r][c] + g(r - 1, c), & \mbox{otherwise}.
  \end{array}
\right.
$$

To produce $$g(r, c)$$ it is important to notice that at any given column $$c$$
we have three options: we either don't move horizontally (so there's no
penalty), or we either go left or right. In essence, we have that $$g(r, c) =
\max(points[r][c], \operatorname{left}(r, c), \operatorname{right}(r, c))$$,
with $$\operatorname{left}(r, c)$$ being the maximum value we can get by going
left of $$c$$ and $$\operatorname{right}(r, c)$$ being the maximum value we can
get by going right of $$c$$. We are now left with the task of efficiently
producing $$\operatorname{left}$$ and $$\operatorname{right}$$.

If we suspect that there is a recurrence at place, it is often helpful to try
and investigate a possible base case and an inductive step that seems plausible.
As such, if we look at the $$\operatorname{left}$$ function, we can conclude
that $$\operatorname{left}(r, 0) = f(r, 0)$$, because we can't go any left, so
the best we can get at column $$0$$ is the maximum so far for cell $$(r, 0)$$.
For $$\operatorname{left}(r, 1)$$ we can pick the maximum of either $$f(r, 1)$$
or $$\operatorname{left}(r, 0) - 1$$. In other words, we either pick the value
we get from choosing the current cell or we pick the best value we have to our
left and subtract $$1$$ (which is the penalty of moving right). We can
generalize $$\operatorname{left}$$ as follows:

$$
\operatorname{left}(r, c) = \left\{
  \begin{array}{ll}
      f(r, c), & \mbox{if $c = 0$}.\\
      \max(\operatorname{left}(r, c - 1) - 1, f(r, c)), & \mbox{otherwise}.
  \end{array}
\right.
$$

We can apply a similar strategy for our $$\operatorname{right}$$ function:

$$
\operatorname{right}(r, c) = \left\{
  \begin{array}{ll}
      f(r, c), & \mbox{if $c = N - 1$}.\\
      \max(\operatorname{right}(r, c + 1) - 1, f(r, c)), & \mbox{otherwise}.
  \end{array}
\right.
$$

With that idea in place, we can avoid one extra inner loop.

{% highlight cpp %}
#include <algorithm>
#include <vector>

using namespace std;

class Solution {
 public:
  long long maxPoints(vector<vector<int>>& points) {
    int M = points.size(), N = points[0].size();
    vector<vector<long long>> dp(M, vector<long long>(N, 0L));
    for (int c = 0; c < N; ++c) { dp[0][c] = points[0][c]; }
    vector<long long> left(N), right(N);
    for (int r = 1; r < M; ++r) {
      left[0] = dp[r - 1][0];
      for (int c = 1; c < N; ++c) { left[c] = max(left[c - 1] - 1, dp[r - 1][c]); }
      right[N - 1] = dp[r - 1][N - 1];
      for (int c = N - 2; c >= 0; --c) { right[c] = max(right[c + 1] - 1, dp[r - 1][c]); }
      for (int c = 0; c < N; ++c) {
        dp[r][c] = max((long long)points[r - 1][c], max(left[c], right[c])) + points[r][c];
      }
    }
    long long ans = 0L;
    for (int c = 0; c < N; ++c) { ans = max(ans, dp[M - 1][c]); }
    return ans;
  }
};
{% endhighlight %}

The above solution has time complexity $$\mathcal{O}(M \times 3 \times N)$$
which simplifies to $$\mathcal{O}(M \times N)$$ and is good to get accepted.

## Reducing the Space Complexity

Even though the solution described above has a sufficient time complexity to be
accepted, we can reduce its space complexity with the following three
observations:

1. We don't need to keep track of the maximum number of points for each cell
   previously visited (our previously defined $$f$$ function), since we're only
   ever interested in the previous row.
2. We don't need to have separate vectors for $$\operatorname{left}$$ and
   $$\operatorname{right}$$. Since we're always computing the maximum of both
   functions, we can reuse the same vector.
3. At every new row, we're only interested in the $$\operatorname{left}$$ and
   $$\operatorname{right}$$ functions (which we saw previously that can be
   combined into one lookup vector), so we can reuse the vector of the maximum
   values for the previous row (the lookup for our $$f$$ function) for that.

If we put those ideas into practice we arrive at the following solution, which
still has a time complexity of $$\mathcal{O}(M \times N)$$ but an extra space
complexity of just $$\mathcal{O}(N)$$, which is better than the previous
$$\mathcal{O}(M \times N)$$:

{% highlight cpp %}
#include <algorithm>
#include <vector>

using namespace std;

class Solution {
 public:
  long long maxPoints(vector<vector<int>>& points) {
    int M = points.size(), N = points[0].size();
    vector<long long> prev(N);
    for (int c = 0; c < N; ++c) { prev[c] = points[0][c]; }
    for (int r = 1; r < M; ++r) {
      for (int c = 1; c < N; ++c) { prev[c] = max(prev[c - 1] - 1, prev[c]); }
      for (int c = N - 2; c >= 0; --c) { prev[c] = max(prev[c + 1] - 1, prev[c]); }
      for (int c = 0; c < N; ++c) { prev[c] += points[r][c]; }
    }
    long long ans = prev[0];
    for (int c = 1; c < N; ++c) { ans = max(ans, prev[c]); }
    return ans;
  }
};
{% endhighlight %}

[^1]: LeetCode is an online platform providing practice coding and algorithmic
    problems.

[^2]: LeetCode's daily challenges are problems from LeetCode's database that are
    meant to be solved on each day of the year. Solving them provides some extra
    rewards in terms of LeetCoins and can get you a badge if you solve all
    problems of a given calendar month. I have been solving them for fun and
    trying to keep a streak going.

[^3]: We can change the queue into a stack for a depth-first search.

[leetcode]: https://leetcode.com/
[leetcode-1937]: https://leetcode.com/problems/maximum-number-of-points-with-cost/
