# pt

Minimal client to use Pivotal Tracker from the console.

## Setup

    gem install pt

The first time you run it, `pt` will ask you some data about your Pivotal Tracker account and your current project.

## Usage

Run `pt` from the root folder of your project.

    pt                                     # show all available tasks

    pt create    [title] ~[owner] ~[type]  # create a new task

    pt show      [id]                      # shows detailed info about a task

    pt open      [id]                      # open a task in the browser

    pt assign    [id] [member]             # assign owner

    pt comment   [id] [comment]            # add a comment

    pt estimate  [id] [0-3]                # estimate a task in points scale

    pt start     [id]                      # mark a task as started

    pt finish    [id]                      # indicate you've finished a task

    pt deliver   [id]                      # indicate the task is delivered

    pt accept    [id]                      # mark a task as accepted

    pt reject    [id] [reason]             # mark a task as rejected, explaining why

    pt find      [query]                   # search for a task by title and show it

    pt done      [id] ~[0-3]               # lazy mans finish task, does everything

    pt updates                             # show recent activity from your current project

## Problems?

You can [open a new issue](https://github.com/raul/pt/issues/new). It can be helpful to include a trace of the requests and responses you're getting from Pivotal Tracker: you can get it by adding the `--debug` parameter while invoking `pt` (remember to remove all sensible data though).

# Contributors
- [orta therox](http://orta.github.com) (Current maintainer)
- [Raul Murciano](http://raul.murciano.net) (Original author)
- [Anthony Crumley](https://github.com/craftycode)
- [Johan Andersson](http://johan.andersson.net)

## Thanks to...
- the contributors mentioned above and all the issue reporters
- the [Pivotal Tracker](https://www.pivotaltracker.com) guys for making a planning tool that doesn't suck and has an API
- [Justin Smestad](https://github.com/jsmestad) for his nice `pivotal-tracker` gem
- [Bryan Liles](http://smartic.us/) for letting me take over the gem name

## License
See the LICENSE file included in the distribution.

## Copyright
Copyright (C) 2011 Raul Murciano <raul@murciano.net>.