# Cheat Sheet

A quick cheat sheet for my configuration, and for poorly-documented syntax I use often.

## git

Make sure to always ignore the following patterns in a repository:
* `.env`
* `.envrc`
* `.direnv`
* `*.code-workspace`
* `.vscode`
* `*.sw[p]`

## dotdrop

dotdrop relies on jinja template syntax, but alters the symbols for some ungodly reason. 
It also adds some helper functions, which are nice, but difficult to find.

Header:
  - `{{@@ header() @@}}`
  - Simple string to convey that dotdrop manages the file. Typically placed in front of a comment token.

### Template Syntax

Variable insertion with no control flow:
  - `{{@@ var @@}}`

Control flow statements:
  - `{%@@ if bool_statement @@%}`
  - `{%@@ elif bool_statement @@%}`
  - `{%@@ else @@%}`
  - `{%@@ endif @@%}`

Logical operators to be used inside evaluated statements:
  - or
  - and

Helper variables:
  - `env['VAR']`
    - Accesses the environment variables
    - ex. `env['HOME']`

Helper functions:
  - `exists_in_path('command')`
    - Bool statement, indicates whether or not the command can be found in the 'PATH' environment variable.
    - ex. `{%@@ if exists_in_path('git')@@%}`
  - `is defined`
    - Syntactic sugar for returning a bool if a variable is defined or not.
    - ex. `{%@@ if env['HOME'] is defined @@%}`
  - `exists('file')`
    - Bool statement that indicates whether a file or folder exists in the filesystem.
    - ex. `{%@@ if exists('$HOME/.cargo/bin') @@%}`

## tmux

`prefix` is `Ctrl a`

`C-*` is `Ctrl + *`


`prefix + h` and `prefix + C-h`: select pane on the left

`prefix + j` and `prefix + C-j`: select pane below the current one

`prefix + k` and `prefix + C-k`: select pane above

`prefix + l` and `prefix + C-l`: select pane on the right


`prefix + shift + h`: resize current pane 5 cells to the left

`prefix + shift + j`: resize 5 cells in the down direction

`prefix + shift + k`: resize 5 cells in the up direction

`prefix + shift + l`: resize 5 cells to the right


`prefix + |`: split current pane horizontally

`prefix + -`: split current pane vertically

`prefix + \`: split current pane full width horizontally

`prefix + _`: split current pane full width vertically


`prefix + < `: moves current window one position to the left

`prefix + > `: moves current window one position to the right

`prefix + I`: installs new plugins from GitHub or any other git repository. Refreshes TMUX environment
`prefix + U`: updates plugin(s)
`prefix + alt + u`: remove/uninstall plugins not on the plugin list

## vim

`\`: leader character

## direnv

Export an alias by using the bash function `export_alias command_name "bash command"

