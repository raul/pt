# pt

Minimal client to use Pivotal Tracker from the console.

## Setup

    gem install pt

The first time you run it, `pt` will ask you some data about your Pivotal Tracker account and your current project.

## Usage

Run `pt` from the root folder of your project.

    pt          # shows your "My work" tasks list

Run `pt create` to create a new bug, chore or feature.

The rest of the commands will open you a list of your tasks and let you interact with it:

    pt open     # open a task in the browser

    pt assign   # assign owner

    pt comment  # add a comment

    pt estimate # estimate a task in points scale

    pt start    # mark a task as started

    pt finish   # indicate you've finished a task

    pt deliver  # indicate the task is delivered

    pt accept   # mark a task as accepted

    pt reject   # mark a task as rejected, explaining why

## Problems?

You can [open a new issue](https://github.com/raul/pt/issues/new). It can be helpful to include a trace of the requests and responses you're getting from Pivotal Tracker: you can get it by adding the `--debug` parameter while invoking `pt` (remember to remove all sensible data though).

## Thanks to...

- the [Pivotal Tracker](https://www.pivotaltracker.com) guys for making a planning tool that doesn't suck and has an API
- [Justin Smestad](https://github.com/jsmestad) for his nice `pivotal-tracker` gem
- [Bryan Liles](http://smartic.us/) for letting me take over the gem name

## License
See the LICENSE file included in the distribution.

## Copyright
Copyright (C) 2011 Raul Murciano <raul@murciano.net>.