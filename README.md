# jtodo
A command line based todo app. Designed to be simple, functional, and good looking

## Usage
#### Commands
- `todo`: show your todo list
- `todo a bunch of random word`: adds 'a bunch of random words' as an item to your todo list
- `todo -t 2`: toggles the state of the second item of the todo list. The index of the items are printed next to them
- `todo -r 1`: removes the first item of the todo list
- `todo -c`: clears all items in the todo list that are labeled done

#### Multiple Lists
- `todo -l list_name [command]`: this works with any of the above commands and applies it to the specified list. list names can not include a space in them

#### Other Commands
- `todo -h`: basically shows all this info
- `todo -ls`: prints all your lists
