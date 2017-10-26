---
layout: post
date: "Tue Oct  28 20:41:33 WET 2014"
---

# A Beets Plugin for Rateyourmusic

Genres are usually neglected in my music library metadata. My primary source for
music metadata [doesn't do genres][mb-genres] and therefore I tend not to worry
too much about them. However, I usually rely on [rateyourmusic.com][rym] to
discover new music, either by peeking at the ratings or by searching through
genres of albums that I enjoyed. Rateyourmusic attributes genres to albums based
on community voting and keeps a [tree of genres][rym-tree] whose structure is
also voted upon. I tend to find its genre information fairly accurate and more
often than not I find myself browsing through the "best" albums of a given
genre on the site.

Locally, I use [beets][beets] to manage my music library. It's a great piece of
software and I've been increasingly using its querying capabilities to populate
my playlists. Being able to do the same sort of genre-based queries I do on
Rateyourmusic locally would therefore be awesome.

Beets has a plugin to fetch genre data from [last.fm][lastfm] tags:
[LastGenre][lastgenre]. There are a couple of issues I identify with using
last.fm tags as genres:

1. To be reasonably accurate, one should use the album or track tags. However,
   those are usually neglected by users, who tend to tag artists mostly.
2. There's no hierarchy in the tags (one needs to
   [build it externally][canonicalization]). I would like to, for example, be
   able to search for `Ambient` and get albums of both `Ambient Techno` and
   `Dark Ambient`.

Taking that into account, I decided to write a plugin to fetch genre information
from Rateyourmusic and assign it to albums and items in the beets library:
[beets-rymgenre][beets-rymgenre]. Rateyourmusic doesn't provide a webservice or
API for developers to build upon[^1] so it's necessary to scrape for the desired
information. Beets is written in Python, and so are its plugins. I have little
experience with it and no familiarity with its ecosystem. I ended up using
[lxml][lxml] for scraping and [requests][requests] for the HTTP client, but more
lightweight solutions may exist.

I've already populated some albums in my library with genre information and I'm
happy with the plugin so far. A great plus of having genre information in the
library metadata is that now I can ask beets for random albums of a given genre
(or set of genres, for that matter) whenever I'm not sure what to listen to
next.

[^1]: There's actually an [open ticket][api-ticket] to build a webservice / API
    for Rateyourmusic open since 2009!

[api-ticket]: http://rateyourmusic.com/rymzilla/view?id=683
[beets]: http://beets.radbox.org/
[beets-rymgenre]: http://github.com/jcazevedo/beets-rymgenre
[canonicalization]: http://beets.readthedocs.org/en/latest/plugins/lastgenre.html#canonicalization
[lastfm]: http://www.last.fm/
[lastgenre]: http://beets.readthedocs.org/en/latest/plugins/lastgenre.html
[lxml]: http://lxml.de/
[mb-genres]: http://musicbrainz.org/doc/General_FAQ#Why_does_MusicBrainz_not_support_genre_information.3F
[requests]: http://docs.python-requests.org/
[rym]: http://rateyourmusic.com/
[rym-tree]: http://rateyourmusic.com/rgenre
