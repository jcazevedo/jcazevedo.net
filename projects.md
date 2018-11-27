---
layout: main
title: Projects
---

# Projects

The following is a list of projects I have worked on or am currently working on:

[PureConfig](https://github.com/pureconfig/pureconfig) (2016 -- )

: A boilerplate-free Scala library for loading configuration files. It
leverages [shapeless][shapeless]' generic representation of (sealed families of)
case classes to allow loading configuration files into supported types with
minimal to no boilerplate. I started contributing to the project in 2016 and am
now one of the authors.

[MoultingYAML](https://github.com/jcazevedo/moultingyaml) (2015 -- )

: A Scala wrapper for [SnakeYAML][snakeyaml], providing a simple immutable model
of the YAML language, built on top of SnakeYAML models, as well as type-class
based (de)serialization of custom objects. I created the project because at the
time there was no Scala library for dealing with YAML.
Since [SnakeYAML][snakeyaml] is already a great parser, a wrapper for it made
more sense than implementing a new parser from scratch.

[The ShiftForward Private DMP](https://dmp.shiftforward.eu/) (2014 -- )

: An on-site, single-tenant, first-party [DMP][dmp]. It's built to support
customization and integration with various services through its API-centric
design. It has been one of the projects I've been involved with
at [ShiftForward][sf] since 2014.

[Mucuchies](https://github.com/ShiftForward/mucuchies) (2014 -- )

: An engine for dashboards that only requires a browser to run. It
combines [Dashing][dashing]'s style with [Ember.js][emberjs]' object model. It
has been used to run a dashboard in [ShiftForward][sf]'s office for a while. We
haven't updated it in ages, but might be able to give support to it if the need
arises.

[AdForecaster](https://www.adforecaster.com/) (2012 -- )

: A forecasting engine for online advertising campaigns. It aims to accurately
predict future ad impressions traffic levels and campaign inventory availability
using an unlimited number of targeting variables. It has been one of the
projects I've been involved in since joining [ShiftForward][sf] in 2012.

[beets-rymgenre](https://github.com/jcazevedo/beets-rymgenre) (2014)

: A plugin for [beets][beets] to fetch genre information
from [rateyourmusic.com][rym]. It’s written in Python, using lxml and
requests. [rateyourmusic.com][rym] doesn't allow access via scraping or scripts
which accesses the site in an automated fashion, so you should refrain from
using this until they complete their API. I'll probably revive the project once
that goes live.

[YapR](https://github.com/jcazevedo/YapR) (2010 -- 2011)

: A [YAP][yap] module to provide an interface to [R][r] in the Prolog engine.
I'm not sure if it still works, so use at your own risk.

[adforecaster]: http://www.adforecaster.com/
[adstax]: http://dmp.shiftforward.eu/
[beets-rymgenre]: http://github.com/jcazevedo/beets-rymgenre
[beets]: http://beets.radbox.org/
[dashing]: http://dashing.io/
[dmp]: http://en.wikipedia.org/wiki/Personalized_marketing#DMP
[emberjs]: http://emberjs.com/
[lxml]: http://lxml.de/
[moultingyaml]: http://github.com/jcazevedo/moultingyaml
[mucuchies]: http://github.com/ShiftForward/mucuchies
[pureconfig]: http://github.com/melrief/pureconfig
[r]: http://www.r-project.org/
[requests]: http://docs.python-requests.org/
[rym]: http://rateyourmusic.com/
[sf]: http://www.shiftforward.eu/
[shapeless]: http://github.com/milessabin/shapeless
[snakeyaml]: https://bitbucket.org/asomov/snakeyaml
[yap]: http://www.dcc.fc.up.pt/~vsc/Yap/
[yapr]: http://github.com/jcazevedo/YapR
