[![Gem Version](https://badge.fury.io/rb/ptt.svg)](https://badge.fury.io/rb/ptt)

# ptt ( pivotal tracker terminal )

Minimal client to use Pivotal Tracker API v5 from the command line (forked from pt

# Demo

[![asciicast](https://asciinema.org/a/0u8dnizygazrksgtd1p33a69b.png)](https://asciinema.org/a/0u8dnizygazrksgtd1p33a69b)

## Setup

    gem install ptt

The first time you run it, `ptt` will ask you some data about your Pivotal Tracker account and your current project.

## Usage

Run `ptt` from the root folder of your project.

```
  ptt                                                                      # show all available stories

  ptt todo      <owner>                                                    # show all unscheduled stories

  ptt (unscheduled,started,finished,delivered, accepted, rejected) <owner> # show all (unscheduled,started,finished,delivered, accepted, rejected) stories

  ptt create    [title] <owner> <type> -m                                  # create a new story (and include descripttion ala git commit)

  ptt show      [id]                                                       # shows detailed info about a story

  ptt tasks     [id]                                                       # manage tasks of story

  ptt open      [id]                                                       # open a story in the browser

  ptt assign    [id] <owner>                                               # assign owner

  ptt comment   [id] [comment]                                             # add a comment

  ptt label     [id] [label]                                               # add a label

  ptt estimate  [id] [0-3]                                                 # estimate a story in points scale

  ptt (start,finish,deliver,accept)     [id]                               # mark a story as started

  ptt reject    [id] [reason]                                              # mark a story as rejected, explaining why

  ptt done      [id]  <0-3> <comment>                                      # lazy mans finish story, opens, assigns to you, estimates, finish & delivers

  ptt find      [query]                                                    # looks in your stories by title and presents it

  ptt list      [owner]                                                    # list all stories for another ptt user

  ptt list      all                                                        # list all stories for all users

  ptt updates                                                              # shows number recent activity from your current project

  ptt recent                                                               # shows stories you've recently shown or commented on with ptt

  All commands can be run entirely without arguments for a wizard based UI. Otherwise [required] <optional>.
  Anything that takes an id will also take the num (index) from the ptt command.
```

## Problems?

[Open a new issue](https://github.com/raul/ptt/issues/new). It can be helpful to include a trace of the requests and responses you're getting from Pivotal Tracker: you can get it by adding the `--debug` parameter while invoking `ptt` (remember to remove all sensible data though).

# Contributors
- Slamet Kristanto (Current maintainer of ptt)
- [orta therox](http://orta.github.com) (Current maintainer of pt)
- [Raul Murciano](http://raul.murciano.net) (Original author)
- [Anthony Crumley](https://github.com/craftycode)
- [Johan Andersson](http://johan.andersson.net)

## Thanks to...
- the contributors of pt
- the [Pivotal Tracker](https://www.pivotaltracker.com) guys for making a planning tool that doesn't suck and has an API
- forest for 'tracker-api' gem

## License
See the LICENSE file included in the distribution.

## Copyright
Copyright (C) 2017 Slamet Kristanto <cakmet14@gmail.com>.
Copyright (C) 2013 Orta Therox <orta.therox@gmail.com>.
Copyright (C) 2011 Raul Murciano <raul@murciano.net>.
