[![Gem Version](https://badge.fury.io/rb/pt.svg)](https://badge.fury.io/rb/pt)

# pt 

Minimal client to use Pivotal Tracker API v5 from the command line 

# Demo
[![asciicast](https://asciinema.org/a/d1er0ca9kg6yw1o2hpyjuq5ku.png)](https://asciinema.org/a/d1er0ca9kg6yw1o2hpyjuq5ku)

## Setup

    gem install pt

The first time you run it, `pt` will ask you some data about your Pivotal Tracker account and your current project.

## Usage

Run `pt` from the root folder of your project.

```
  pt                                                                      # show all available stories

  pt todo      <owner>                                                    # show all unscheduled stories

  pt (unscheduled,started,finished,delivered, accepted, rejected) <owner> # show all (unscheduled,started,finished,delivered, accepted, rejected) stories

  pt create    [title] <owner> <type> -m                                  # create a new story (and include description ala git commit)

  pt show      [id]                                                       # shows detailed info about a story

  pt tasks     [id]                                                       # manage tasks of story

  pt open      [id]                                                       # open a story in the browser

  pt assign    [id] <owner>                                               # assign owner

  pt comment   [id] [comment]                                             # add a comment

  pt label     [id] [label]                                               # add a label

  pt estimate  [id] [0-3]                                                 # estimate a story in points scale

  pt (start,finish,deliver,accept)     [id]                               # mark a story as started

  pt reject    [id] [reason]                                              # mark a story as rejected, explaining why

  pt done      [id]  <0-3> <comment>                                      # lazy mans finish story, opens, assigns to you, estimates, finish & delivers

  pt find      [query]                                                    # looks in your stories by title and presents it

  pt list      [owner]                                                    # list all stories for another pt user

  pt list      all                                                        # list all stories for all users

  pt updates                                                              # shows number recent activity from your current project

  pt recent                                                               # shows stories you've recently shown or commented on with pt

  All commands can be run entirely without arguments for a wizard based UI. Otherwise [required] <optional>.
  Anything that takes an id will also take the num (index) from the pt command.
```

## Problems?

[Open a new issue](https://github.com/raul/pt/issues/new). It can be helpful to include a trace of the requests and responses you're getting from Pivotal Tracker: you can get it by adding the `--debug` parameter while invoking `ptt` (remember to remove all sensible data though).

# Contributors
- [Slamet Kristanto](http://github.com/drselump14) (Current maintainer)
- [orta therox](http://orta.github.com) (Current maintainer)
- [Raul Murciano](http://raul.murciano.net) (Original author)
- [Anthony Crumley](https://github.com/craftycode)
- [Johan Andersson](http://johan.andersson.net)

## Thanks to...
- the contributors of pt
- the [Pivotal Tracker](https://www.pivotaltracker.com) guys for making a planning tool that doesn't suck and has an API
- [dashofcode](http://github.com/dashofcode) for `tracker_api` gem
- [Bryan Liles](http://smartic.us/) for letting me take over the gem name

## License
See the LICENSE file included in the distribution.

## Copyright
Copyright (C) 2017 Slamet Kristanto <cakmet14@gmail.com>.
Copyright (C) 2013 Orta Therox <orta.therox@gmail.com>.
Copyright (C) 2011 Raul Murciano <raul@murciano.net>.
