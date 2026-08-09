# Neovim Configuration

A personal Neovim configuration focused on providing a modern, IDE-like editing
experience while keeping the configuration understandable and relatively
lightweight.

The interface takes some inspiration from VS Code, with a file explorer, buffer
tabs, integrated terminal, status line, icons, multiple color schemes, and
Tree-sitter syntax highlighting.

The configuration is written in Lua and uses
[`lazy.nvim`](https://github.com/folke/lazy.nvim) for plugin management.

## Requirements

The configuration requires:

* Neovim 0.12 or later
* Git
* A terminal with true-color support
* A Nerd Font
* `curl`
* `tar`
* A C compiler
* `tree-sitter-cli` 0.26.1 or later

Some features may require additional external tools as the configuration grows.

### Nerd Font

A Nerd Font is recommended because several plugins use additional glyphs for
filetypes, operating systems, Git information, and other UI elements.

After installing a Nerd Font, configure the terminal emulator to use it.

Without a Nerd Font, Neovim will still work, but some icons may appear as
missing or incorrect characters.

## Installation

The configuration lives at:

```text
~/.config/nvim/
```

with the main configuration file at:

```text
~/.config/nvim/init.lua
```

On the first launch, `lazy.nvim` is automatically cloned and used to install the
configured plugins.

Run:

```bash
nvim
```

and allow the plugin installation to complete.

Plugin state is recorded in:

```text
lazy-lock.json
```

This file should be committed to the dotfiles repository so plugin versions can
be reproduced on another machine.

## Features

### Clipboard integration

Clipboard operations use OSC 52.

This allows text copied inside Neovim to reach the local system clipboard even
when Neovim is running remotely over SSH or inside tmux.

The `unnamedplus` clipboard is enabled, so normal yank, delete, and paste
operations use the system clipboard by default.

### Editing

The configuration provides:

* Absolute line numbers
* Current-line highlighting
* No automatic line wrapping
* An 85-column guide
* True-color support
* Scroll context around the cursor
* Visible whitespace
* Persistent undo
* Case-aware searching
* Familiar `Ctrl+S` saving

Invisible whitespace is displayed using characters such as:

```text
·    spaces
→    tabs
```

### Saving

The current file can be saved using:

```text
Ctrl+S             Save current file
```

The shortcut works in Normal, Insert, and Visual modes.

When used from Insert mode, the file is saved without permanently leaving Insert
mode. When used from Visual mode, the current selection remains active after the
save.

> **Terminal note:** Some terminals use `Ctrl+S` for XON/XOFF software flow
> control. If `Ctrl+S` freezes terminal output instead of saving the file, check
> the terminal settings with `stty -a`. If `ixon` is enabled, it can be disabled
> for the current terminal with `stty -ixon`. `Ctrl+Q` traditionally resumes
> output when software flow control is enabled.


### Indentation detection

Default indentation is:

```text
Tab width:        4
Shift width:      4
Soft tab width:   4
Default style:    tabs
```

These values are fallbacks.

[`guess-indent.nvim`](https://github.com/NMAC427/guess-indent.nvim) examines
existing files and automatically determines whether they use tabs or spaces and
their likely indentation width.

The detected settings are applied only to that buffer, allowing files in
different projects to use different indentation conventions.

### Moving lines

Lines can be moved without manually cutting and pasting them.

```text
Alt+j             Move line down
Alt+k             Move line up
Alt+Down          Move line down
Alt+Up            Move line up
```

The same shortcuts work on Visual selections and keep the moved lines selected.

## File Explorer

[`nvim-tree.lua`](https://github.com/nvim-tree/nvim-tree.lua) provides a file
explorer on the left side of the editor.

```text
Ctrl+n            Toggle file explorer
```

The explorer displays file, directory, and Git-status icons using
`nvim-web-devicons`.

Its default width is 30 columns.

## Buffers

[`bufferline.nvim`](https://github.com/akinsho/bufferline.nvim) displays open
buffers across the top of the editor in a tab-like interface.

These are Neovim **buffers**, not Vim tab pages.

```text
Alt+Left          Previous buffer
Alt+Right         Next buffer

Alt+Shift+Left    Move buffer left
Alt+Shift+Right   Move buffer right

Alt+w             Close current buffer
```

Terminal buffers are deliberately excluded from Bufferline because the terminal
is treated as a separate editor panel rather than an open file.

### Safe buffer deletion

[`nvim-bufdel`](https://github.com/ojroques/nvim-bufdel) is used when closing
buffers.

This allows a file buffer to be removed without unnecessarily destroying the
surrounding window layout, such as the file explorer or integrated terminal.

Buffers containing unsaved changes are not force-closed.

## Integrated Terminal

Neovim includes a toggleable terminal in a horizontal split at the bottom of the
editor.

```text
Ctrl+\            Show/hide terminal
Esc               Leave Terminal mode
```

The terminal split is 12 lines high.

Hiding the terminal closes only its window. The terminal buffer and shell
process remain alive, so reopening the terminal restores the existing shell
session rather than starting a new one.

Terminal buffers are hidden from Bufferline.

## Status Line

[`lualine.nvim`](https://github.com/nvim-lualine/lualine.nvim) provides the
status line.

It displays information including:

* Current Vim mode
* Git branch
* Git diff statistics
* Diagnostics
* Filename
* Search match count
* Visual selection count
* File encoding
* Line-ending format
* Indentation style and width
* File size
* Filetype
* LSP status
* Progress through the file
* Current line and column

The line-ending component displays both an operating-system icon and the
explicit line-ending sequence, for example:

```text
 LF
 CRLF
 CR
```

Indentation is displayed using values such as:

```text
Spaces: 4
Spaces: 2
Tab Size: 4
```

Because this reads Neovim's current buffer-local settings, it also reflects
indentation detected by `guess-indent.nvim`.

LSP-related information becomes useful once Language Server Protocol support is
configured.

## Color Schemes

Several color schemes are installed:

* VS Code
* Catppuccin
* Tokyo Night
* Kanagawa
* Gruvbox

Available configured variants include:

```text
vscode
catppuccin-mocha
catppuccin-macchiato
tokyonight-night
tokyonight-moon
kanagawa-wave
kanagawa-dragon
gruvbox
```

The default color scheme is:

```text
kanagawa-dragon
```

Themes can be changed at runtime:

```text
F7                 Previous color scheme
F8                 Next color scheme
```

The selected color scheme name is displayed as a notification.

Changing the theme this way is temporary. Restarting Neovim restores the
configured default.

## Tree-sitter

[`nvim-treesitter`](https://github.com/nvim-treesitter/nvim-treesitter) provides
parser management for syntax-tree-based highlighting.

Tree-sitter highlighting is currently configured for:

* Bash
* C
* C++
* Git config
* Git ignore files
* Lua
* Markdown
* SSH config
* Vim script
* Vim documentation

### External dependencies

Installing or updating Tree-sitter parsers requires:

```text
tar
curl
tree-sitter-cli >= 0.26.1
C compiler (cc, gcc, or clang)
```

The configuration checks for these dependencies when Neovim starts and displays
a warning when any are missing.

Existing parsers may continue working even if an installation dependency is
missing.

### Installing parsers

Install the configured parsers with:

```vim
:TSInstall bash c cpp git_config gitignore lua markdown markdown_inline ssh_config vim vimdoc
```

Update installed parsers with:

```vim
:TSUpdate
```

Tree-sitter parsers are also updated after `nvim-treesitter` itself is updated.

### Troubleshooting

Check the Tree-sitter environment with:

```vim
:checkhealth nvim-treesitter
```

If a configured parser is unavailable, the configuration displays a warning
rather than preventing the file from opening.

A parser can be installed or reinstalled with:

```vim
:TSInstall <language>
```

For example:

```vim
:TSInstall cpp
```

To inspect the syntax tree for the current buffer:

```vim
:InspectTree
```

This is also a useful way to verify that Tree-sitter is active.

## Plugins

The configuration currently uses:

| Plugin                            | Purpose                         |
| --------------------------------- | ------------------------------- |
| `folke/lazy.nvim`                 | Plugin manager                  |
| `Mofiqul/vscode.nvim`             | VS Code color scheme            |
| `catppuccin/nvim`                 | Catppuccin color schemes        |
| `folke/tokyonight.nvim`           | Tokyo Night color schemes       |
| `rebelot/kanagawa.nvim`           | Kanagawa color schemes          |
| `ellisonleao/gruvbox.nvim`        | Gruvbox color scheme            |
| `nvim-tree/nvim-tree.lua`         | File explorer                   |
| `nvim-tree/nvim-web-devicons`     | Nerd Font icons                 |
| `nvim-lualine/lualine.nvim`       | Status line                     |
| `akinsho/bufferline.nvim`         | Buffer tabs                     |
| `ojroques/nvim-bufdel`            | Safe buffer deletion            |
| `NMAC427/guess-indent.nvim`       | Automatic indentation detection |
| `nvim-treesitter/nvim-treesitter` | Tree-sitter parser management   |

## Plugin Management

Open the `lazy.nvim` interface with:

```vim
:Lazy
```

From there, plugins can be inspected, installed, updated, synchronized, and
removed.

Useful commands include:

```vim
:Lazy update
:Lazy sync
:Lazy clean
```

After updating `nvim-treesitter`, its configured build command automatically
runs:

```vim
:TSUpdate
```

## Health Checks

Neovim provides built-in health checks that are useful when debugging the
configuration.

Run all health checks with:

```vim
:checkhealth
```

Tree-sitter can be checked specifically with:

```vim
:checkhealth nvim-treesitter
```

## Planned Improvements

The configuration is intentionally being expanded incrementally rather than
installing a large preconfigured Neovim distribution.

Potential additions include:

* Language Server Protocol (LSP) support
* Code completion
* Telescope fuzzy finding and project search
* Git integration
* Automatic formatting
* Linting
* Comment toggling
* Surround operations
* Automatic bracket and quote pairs
* Session/project persistence
* Keybinding discovery

The next planned addition is **LSP support**, beginning with C and C++ using
`clangd`.
