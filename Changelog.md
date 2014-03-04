# pt changelog

## v0.7.3

Fix to `pt list` ( icetan )

## v0.7.2

Show task updates for attachments, labels, and a recent stories list

## v0.7.1

Fixes to pt show
Updates to the help
Fixed the -m option

## v0.7.0

Comment, Assign, Estimate, Start, Finish, Deliver, Accept all accept the num value in `pt` or a story id

## v0.6.3 & v0.6.4

Added the ability to see started by username ( good idea marcolz )

## v0.6.2

Added "-m" to create that will load the description in your editor ( good idea ahunt09 )

## v0.6

Added command pt started ( Matthijs Groen )
Added command pt tasks ( Matthijs Groen )

## v0.5.8

Improved support for ruby 1.8 ( Paco Benavent )

## v0.5.7

Fixed `pt list [username]` ( stephencelis )

## v0.5.6

Added `pt list all` which shows tickets from all members of the project ( kylewest )

## v0.5.5

Show the id of tickes by default in tables, adds the url of the task to show and shows more information about attachments ( derwiki )

## v0.5.4

Fix to pt create, wherein skipping optional parameters wouldn't work as expected, or at all. ( aniccolai )

## v0.5.3

Added a command todo, that only shows unscheduled stories ( orta )

## v0.5.2

Made create agnostic of order for assignee / type, and use defaults of you / feature ( orta )
Added query limit size to activity ( jonmountjoy )

## v0.5.1

Extra commands added, they can be accessed through 'pt help' ( orta )
Fix for 1.9.3 not getting deprecation warnings

## v0.4

Added support for calling functions without going through the walkthroughs ( orta )

## v0.3.9

Attachments displayed in 'show' task, thanks Anthony Crumley!

## v0.3.8

Fix converting encodings, thanks Johan Andersson!

## v0.3.7
Fix and story's id in "show" command

## v0.3.6
Fix for ruby 1.9 strings, thanks David Ramirez for reporting!

## v0.3.5
New 'show' command largely based on craftycode's (Anthony Crumley) contribution

## v0.3.4
Improved charset support

## v0.3.3
Added SSL support

## v0.3.2
Fix in requests debugger

## v0.3.1
Dependencies versions added to gemspec

## v0.3.0
Added --debug option to see the interaction with PT's API

## v0.2.2
Fix: list of tasks to start

## v0.2.1
Error message when using pt from ~

## v0.2
Fix for ruby 1.8

## v0.1
First release
