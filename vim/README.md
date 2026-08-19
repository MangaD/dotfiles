# Vim Configuration

This directory contains the Vim configuration managed by the dotfiles repository.

The configuration is intentionally lightweight and terminal-oriented. It is designed for normal local editing as well as remote editing over SSH and inside tmux, while relying primarily on Vim's built-in features.

## Files

```text
vim/
├── .stow-local-ignore
├── .vimrc
├── .vim/
│   └── autoload/
│       └── osc52.vim
└── README.md
```

When installed with GNU Stow, the managed files are linked to:

```text
vim/.vimrc                    → ~/.vimrc
vim/.vim/autoload/osc52.vim → ~/.vim/autoload/osc52.vim
```

`README.md` is repository documentation and is excluded from Stow by
`.stow-local-ignore`.

## Overview

The configuration provides:

- Filetype detection, filetype plugins, and filetype-specific indentation
- Syntax highlighting
- Absolute line numbers and current-line highlighting
- Enhanced command-line completion
- Confirmation before abandoning unsaved changes
- Automatic detection of files modified outside Vim
- Predictable Insert-mode Backspace behavior
- Mouse support
- System clipboard integration when supported by Vim
- OSC 52 clipboard support for remote editing
- Tab-page management and navigation
- Automatic conversion of multiple command-line files into tab pages
- `Ctrl-s` mappings for writing the current buffer
- Shortcuts for moving lines and Visual-mode selections
- Case-aware incremental searching
- Four-column tab and indentation settings
- Visible whitespace
- Scrolling margins and an 85-column guide
- A persistent status line showing file, buffer, encoding, format, and position information
- 24-bit terminal color support when available
- A transparent default colorscheme with interactive colorscheme browsing
- Custom line-number and whitespace highlighting
- Persistent undo when supported by Vim
- Insert-mode completion configuration
- C and C++ indentation using Vim's built-in C indentation rules
- Optional machine-specific overrides through `~/.vimrc.local`

## Leader Key

Space is used as the leader key:

```text
Space
```

Mappings documented as `Space ...` below therefore use Vim's `<Leader>` key.

## General Editing

Absolute line numbers are enabled. Relative line numbers are available in the configuration but remain disabled.

The current line is highlighted, matching brackets are briefly highlighted, and Vim's ruler displays the current cursor position.

Modified buffers may remain hidden, allowing another buffer to be displayed without first writing the current one.

`confirm` is enabled so operations that would otherwise fail because of unsaved changes can prompt for a decision.

`autoread` allows Vim to notice files changed outside the editor when Vim performs an external-change check.

Backspace is configured to work across indentation, line boundaries, and the point at which Insert mode began.

Mouse support is enabled in all modes.

## Command-Line Completion

Vim's enhanced command-line completion menu is enabled.

For example:

```vim
:edit src/<Tab>
:colorscheme <Tab>
```

Completion first expands the longest text shared by the available matches and shows the candidates. Further Tab presses cycle through the individual matches.

This command-line completion is separate from Insert-mode completion.

## Tabs and Indentation

Tabs are displayed as four columns, and indentation commands use a width of four columns.

The configuration deliberately uses real tab characters rather than replacing tabs with spaces:

```text
tabstop=4
shiftwidth=4
softtabstop=4
noexpandtab
```

Filetype-specific indentation is preferred over Vim's older general-purpose `smartindent` behavior.

## Tab Pages

The tab line is always visible.

Vim tab pages are technically containers for one or more windows rather than one-file-per-tab objects. This configuration nevertheless uses them as a convenient visible way to work with several files.

### Opening Multiple Files

When Vim starts with multiple file arguments, the configuration opens those arguments as tab pages automatically.

For example:

```bash
vim foo.cpp foo.hpp main.cpp
```

behaves similarly to:

```bash
vim -p foo.cpp foo.hpp main.cpp
```

With zero or one file argument, normal Vim startup behavior is unchanged.

This behavior applies to the complete argument list. A command such as:

```bash
vim *.cpp
```

therefore creates a tab page for every matching file.

A file can also be opened manually in a new tab with:

```vim
:tabedit file.cpp
```

### Tab Navigation

Vim's native tab mappings remain available:

```text
gt                  Next tab page
gT                  Previous tab page
```

Additional mappings are provided:

```text
Alt-Left            Previous tab page
Alt-Right           Next tab page
Space t n           Open a new empty tab page
Space t c           Close the current tab page
Space t h           Move the current tab page left
Space t l           Move the current tab page right
```

Some terminal emulators may intercept `Alt-Left` and `Alt-Right`. `gt` and `gT` remain available in that case.

## Saving

`Ctrl-s` writes the current buffer in Normal, Insert, and Visual modes:

```text
Ctrl-s              Write the current buffer
```

In Insert mode the write is performed without permanently leaving Insert mode. In Visual mode the selection is restored after writing.

Some terminals reserve `Ctrl-s` for XON/XOFF software flow control. If `Ctrl-s` freezes terminal output instead of reaching Vim, inspect the terminal settings with:

```bash
stty -a
```

If `ixon` is enabled, it can be disabled for the current terminal with:

```bash
stty -ixon
```

`Ctrl-q` traditionally resumes output when XON/XOFF flow control is active.

## Moving Lines

The current line can be moved directly:

```text
Alt-j               Move the current line down
Alt-k               Move the current line up
Alt-Down            Move the current line down
Alt-Up              Move the current line up
```

The same shortcuts work on a Visual-mode selection. The selected block remains selected after it is moved, allowing the mapping to be pressed repeatedly.

Moved lines are reindented according to the indentation rules for the current file.

## Clipboard

The configuration supports two clipboard mechanisms.

### Native Vim clipboard

Vim uses the `+` register as its default register when clipboard support is
available:

```vim
set clipboard=unnamedplus
````

This integrates normal yank, delete, change, and paste operations with the
system clipboard on builds of Vim that provide clipboard support.

### OSC 52 clipboard

Visual selections can also be copied explicitly to the local terminal
clipboard with:

```text
Space + y
```

The mapping calls `osc52#copy()`, implemented in:

```text
~/.vim/autoload/osc52.vim
```

The implementation chooses between two methods:

1. If Vim can communicate with the current tmux server, it uses
   `tmux load-buffer -w -` and lets tmux forward the text to the terminal
   clipboard.

2. Otherwise, it emits an OSC 52 escape sequence directly to `/dev/tty`.

The fallback allows clipboard copying to work in environments such as:

```text
terminal
  -> tmux
    -> Docker
      -> Vim
```

where the container may inherit `$TMUX` but cannot access the tmux server
socket.

Direct OSC 52 mode requires:

* `base64`
* `tr`
* a controlling terminal (`/dev/tty`)
* a terminal emulator that permits OSC 52 clipboard writes

When the sequence passes through tmux, tmux must also allow clipboard
forwarding.

## Searching

Search behavior is configured as follows:

- Searches ignore case by default.
- A pattern containing uppercase characters becomes case-sensitive.
- Matches are shown while the search pattern is being typed.
- Matches for the current search remain highlighted.

This provides convenient case-insensitive searching while still allowing case-sensitive searches without changing an option manually.

## Whitespace

Invisible whitespace characters are displayed.

The configuration distinguishes:

- Leading spaces
- Tab characters
- Trailing spaces
- Text extending beyond the right edge
- Text extending beyond the left edge

This makes accidental whitespace easier to identify while editing source code.

## Display and Scrolling

Long lines are not visually wrapped.

Vim attempts to keep five lines visible above and below the cursor and five columns visible to either side when scrolling horizontally.

A vertical guide is displayed at column 85.

24-bit terminal colors are enabled when the Vim build supports `termguicolors`.

The status line is always displayed and provides information about the current buffer and cursor position.

The left side shows the current file path together with indicators when the buffer is modified, read-only, or a help buffer.

The right side shows:

- File type
- File encoding
- File format
- Current line and column
- Position through the file as a percentage

The status line uses Vim's `StatusLine` highlighting rather than defining its own colors. Its appearance therefore follows the currently selected colorscheme, including colorschemes browsed with F7 and F8.

## Colorschemes

The configuration uses a dark background and `koehler` as its default colorscheme.

At startup, the background of the default colorscheme is made transparent by clearing the background colors of Vim's main editing and common UI highlight groups. This allows the terminal emulator's background to show through. Actual transparency must be configured in the terminal emulator itself.

The transparency overrides apply only to the colorscheme loaded during startup. They are intentionally not reapplied when browsing colorschemes with F7 and F8, so each browsed colorscheme is displayed with its own original background and highlight settings.

Available colorschemes can be browsed interactively:

```text
F7                  Previous colorscheme
F8                  Next colorscheme
```

The list is discovered from the colorschemes available in Vim's runtime path, so it is not necessary to maintain a hard-coded list.

Colorscheme changes made with F7 and F8 are temporary. To make a selection permanent, change the `colorscheme` command in `.vimrc`.

The configuration also defines custom highlighting for ordinary line numbers, the current line number, and visible whitespace. Because these highlights are defined after the default colorscheme is loaded, they override the corresponding colors from that scheme at startup.

## Persistent Undo

Persistent undo is enabled when supported by the installed Vim build.

This allows undo history to survive between Vim sessions.

Vim currently uses its configured undo-file location automatically. A dedicated `undodir` can be introduced later if a specific storage location is desired.

## Insert-Mode Completion

The completion menu is configured with:

```text
menuone,noinsert,noselect
```

This causes Vim to show the completion menu even when only one candidate is available, while avoiding automatic insertion or automatic selection of a candidate.

## C and C++

For C and C++ files, Vim's built-in C indentation rules are enabled with `cindent`.

General filetype detection, plugins, and filetype-specific indentation are also enabled globally.

## Machine-Specific Configuration

The tracked `.vimrc` optionally loads:

```text
~/.vimrc.local
````

when that file exists.

This provides a place for Vim configuration that should apply only to the
current machine rather than every system using the dotfiles repository.

Because `.vimrc.local` is sourced at the end of `.vimrc`, its settings are
loaded after the shared configuration and can therefore intentionally override
it.

Possible uses include:

* Machine-specific paths
* Terminal-specific behavior
* Host-specific mappings
* Local colorscheme preferences
* Experimental settings that are not ready for the shared configuration
* Other settings that should not be committed to the dotfiles repository

For example:

```vim
" Use a different line-length guide on this machine.
set colorcolumn=100

" Override the default colorscheme.
colorscheme desert
```

Vim does not treat `.vimrc.local` specially by itself. The file works because
the tracked `.vimrc` explicitly checks for it and sources it when present.

`~/.vimrc.local` should remain outside the Stow-managed `vim` package and
should not be committed to the repository.

## Key Reference

| Mapping | Mode | Action |
| --- | --- | --- |
| `Ctrl-s` | Normal | Write the current buffer |
| `Ctrl-s` | Insert | Write without permanently leaving Insert mode |
| `Ctrl-s` | Visual | Write and restore the selection |
| `Alt-j` | Normal / Visual | Move line or selection down |
| `Alt-k` | Normal / Visual | Move line or selection up |
| `Alt-Down` | Normal / Visual | Move line or selection down |
| `Alt-Up` | Normal / Visual | Move line or selection up |
| `gt` | Normal | Next tab page |
| `gT` | Normal | Previous tab page |
| `Alt-Left` | Normal | Previous tab page |
| `Alt-Right` | Normal | Next tab page |
| `Space t n` | Normal | Open a new tab page |
| `Space t c` | Normal | Close the current tab page |
| `Space t h` | Normal | Move the current tab page left |
| `Space t l` | Normal | Move the current tab page right |
| `Space y` | Visual | Copy selection through OSC 52 |
| `F7` | Normal | Previous colorscheme |
| `F8` | Normal | Next colorscheme |

## Design Philosophy

The Vim configuration is intended to remain small, understandable, and useful without turning Vim into a plugin-heavy IDE.

Settings and mappings should be added when they solve an actual problem or improve an established workflow. Features that require substantial IDE-like functionality can remain part of the separate Neovim configuration.

Historical settings that may still be useful for reference can remain commented in `.vimrc` rather than being enabled without a clear need.
