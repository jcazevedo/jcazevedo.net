---
layout: post
title: "Tracking PostgreSQL Execution Statistics on Amazon RDS"
date: "Fri Jul 21 02:20:15 WEST 2017"
---

I've recently been working with [PostgreSQL][postgresql] on [Amazon RDS][rds]
and found out about the [`pg_stat_statements`][pgstatstatements] module, which allows tracking
execution statistics of all SQL statements executed by the server. It can be
very helpful when monitoring your application and discovering about slow running
queries. It is also very easy to set up.

## Enabling it on Amazon RDS

Setting it up on [Amazon RDS][rds] is easy, but does require rebooting your
database. First, go to your [AWS Console][console] and create a new parameter
group or modify one of the existing ones. You should find the _Parameter Groups_
option on the sidebar to your left (at least in the current version of the
interface). First, you should include `pg_stat_statements` as a shared library
to preload into the server. In order to do so, include the `pg_stat_statements`
string in the `shared_preload_libraries` parameter. The value of the parameter
should be a comma-separated list of libraries to preload. Chances are that the
value is currently empty, so you'd only need to set it to `pg_stat_statements`.
Afterwards, you should set the `pg_stat_statements.track` parameter to `ALL`,
enabling tracking of all queries, even those inside stored procedures. If you
use and want to keep track of large-sized queries, you should also increase the
`track_activity_query_size` parameter value. Its value specifies the number of
bytes reserved to track the currently executing command for each active session.
The default value is `1024` but you might want to increase it.

Once you have a parameter group with the relevant parameters defined, you must
modify your database to use the new parameter group (if you edited one the
database was already using then that's not necessary) and reboot your database.
Rebooting is necessary because libraries set in the `shared_preload_libraries`
parameter will only be loaded at server start. Once rebooted, connect to your
database as an RDS superuser and run the following commands to enable the
extension and make sure it was set up properly:

{% highlight sql %}
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
SELECT * FROM pg_stat_statements LIMIT 1;
{% endhighlight %}

If it returns one row of query statistics information then it's set up properly.
If not, you might not have restarted your database or have a misconfigured
instance.

## The `pg_stat_statements` View

The main thing the module provides is the `pg_stat_statements` view. The view
allows you to query statistics about the execution of SQL statements in the
server. The [official documentation][pgstatstatements] provides a complete
description of all columns the view provides, but the ones I find most useful are:

| Name         | Description                                                  |
|--------------|--------------------------------------------------------------|
| `query`      | Text of a representative statement.                          |
| `calls`      | Number of times executed.                                    |
| `total_time` | Total time spent in the statement, in milliseconds.          |
| `min_time`   | Minimum time spent in the statement, in milliseconds.        |
| `max_time`   | Maximum time spent in the statement, in milliseconds.        |
| `mean_time`  | Mean time spent in the statement, in milliseconds.           |
| `rows`       | Total number of rows retrieved or affected by the statement. |

According to the documentation, two plannable queries (`SELECT`, `INSERT`,
`UPDATE` and `DELETE`) will be considered the same if they are semantically
equivalent except for the values of literal constants appearing in the query.
This means that identical queries will be combined into a single entry in the
view.

I like to keep track of queries in which the server is spending most of the time, so I usually run:

{% highlight sql %}
SELECT * FROM pg_stat_statements ORDER BY total_time DESC;
{% endhighlight %}

Ocasionally, it might be necessary to reset the view. I tend to reset it before
running a stress test or otherwise to clean old data. In order to do so, the
module provides the `pg_stat_statements_reset()` function. To discard all
statistics gathered so far, simply run:

{% highlight sql %}
SELECT pg_stat_statements_reset();
{% endhighlight %}

If you want to know more about the module,
the [official documentation][pgstatstatements] is a good place to start. You
should also find instructions there on how to set it up in your own managed
instance.

[postgresql]: https://www.postgresql.org/
[rds]: https://aws.amazon.com/rds/
[console]: https://console.aws.amazon.com/rds/
[pgstatstatements]: https://www.postgresql.org/docs/9.6/static/pgstatstatements.html
