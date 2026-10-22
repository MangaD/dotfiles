# Neovim Configuration

A personal Neovim configuration focused on providing a modern, IDE-like editing
experience while keeping the configuration understandable and relatively
lightweight.

The interface takes some inspiration from VS Code, with a file explorer, buffer
tabs, integrated terminal, status line, icons, multiple color schemes,
toggleable transparency, Tree-sitter syntax highlighting, sticky scroll,
Language Server Protocol (LSP) support, Telescope fuzzy finding, Git change
indicators, and manual LSP-based formatting.

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
* `clangd` for C and C++ LSP support
* `basedpyright` for Python type checking and language intelligence
* `ruff` for Python formatting and lint diagnostics
* `ripgrep` (`rg`) for Telescope project-wide text search
* `fd` or `fdfind` (recommended) for fast Telescope file finding

Language servers are external programs and are not installed by Neovim or
`nvim-lspconfig`. They must be installed separately and available in `PATH`.

### Language servers

Language Server Protocol (LSP) support is currently configured for:

| Language | Server |
| -------- | ------ |
| C/C++ | `clangd` |
| Python | `basedpyright` (language intelligence), `ruff` (formatting and linting) |

Language servers are installed separately from Neovim plugins.

#### C and C++

`clangd` must be installed and available in `PATH`.

On Debian-based systems it can be installed with:

```bash
sudo apt install clangd
```

Verify the installation with:

```bash
clangd --version
```

#### Python

Python uses `basedpyright`.

On Debian systems, Python's system environment may be externally managed under
PEP 668, so `basedpyright` should not be installed into the system Python with a
normal `pip install`.

Instead, install `pipx`:

```bash
sudo apt install pipx
```

Ensure the pipx executable directory is available in `PATH`:

```bash
pipx ensurepath
```

Then install `basedpyright` in its own isolated environment:

```bash
pipx install basedpyright
```

This provides the executables used from the command line and by Neovim:

```text
basedpyright
basedpyright-langserver
```

Verify the installation with:

```bash
basedpyright --version
command -v basedpyright-langserver
```

The language-server executable must be visible in the environment from which
Neovim is started.

#### Ruff (Python formatting and linting)

Ruff complements `basedpyright`: basedpyright handles Python type checking,
completion, navigation, and hover documentation, while Ruff handles formatting,
lint diagnostics, and code actions. Both servers attach to Python files.

Ruff includes its own language server (`ruff server`); do not install the older
`ruff-lsp` package. Install Ruff in an isolated environment:

```bash
pipx install ruff
```

Verify the installation and language-server command:

```bash
ruff --version
ruff server --help
command -v ruff
```

The `ruff` executable must be on `PATH` when Neovim starts.

### Telescope search tools

Telescope uses external command-line tools for some search features. On Debian
or Raspberry Pi OS, install them with:

```bash
sudo apt install ripgrep fd-find
```

Verify the executables:

```bash
rg --version
fdfind --version
```

Debian's `fd-find` package normally provides `fdfind`, whereas other systems may
provide `fd`. The configuration checks for both names and uses whichever is
available. If neither is installed, Telescope falls back to its normal file
finder. If `rg` is missing, project-wide text searching will not work.

Missing tools trigger warnings rather than preventing Neovim from starting.

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
·    spaces
→    tabs
```

### Saving

The current file can be saved using:

```text
Ctrl+S              Save current file
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
Tab width:        4
Shift width:      4
Soft tab width:   4
Default style:    tabs
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
Alt+j              Move line down
Alt+k              Move line up
Alt+Down           Move line down
Alt+Up             Move line up
```

The same shortcuts work on Visual selections and keep the moved lines selected.

## Telescope

[`telescope.nvim`](https://github.com/nvim-telescope/telescope.nvim) provides
interactive fuzzy finding and searchable lists for files, project text, open
buffers, Neovim help, diagnostics, and LSP information. It uses
[`plenary.nvim`](https://github.com/nvim-lua/plenary.nvim) and the existing
`nvim-web-devicons` plugin.

### Keybindings

All Telescope mappings start with `Space+f`:

```text
Space+f+f           Find files
Space+f+g           Search project text (live grep)
Space+f+w           Search the word under the cursor
Space+f+b           Search open buffers
Space+f+h           Search Neovim help
Space+f+d           Browse diagnostics
Space+f+s           Search document symbols via LSP
Space+f+r           Search references via LSP
```

Telescope pickers open in Insert mode, ready for typing. Use `Ctrl+n` and
`Ctrl+p` to move through results, `Enter` to select, and `Esc` to close.

File and text searches operate relative to Neovim's current working directory.

Check it with `:pwd`; for project-wide searches, start Neovim in the project's
root directory or change directory with `:cd`.

### File discovery and text search

When `fd` or `fdfind` is available, the file picker explicitly searches for
files, includes hidden files such as `.gitignore`, and excludes the `.git`
directory. The command also follows `fd`'s usual ignore rules, so ignored files
are generally omitted. Without `fd` or `fdfind`, Telescope uses its normal
fallback.

`Space+f+g` and `Space+f+w` use `ripgrep` (`rg`) for text searches. `rg`
respects ignore rules by default.

### LSP integration

`Space+f+s` and `Space+f+r` use the language server attached to the current
buffer. For example, `clangd` provides C/C++ symbols and references, while
`basedpyright` provides Python symbols and references. These pickers require a
working LSP client for the relevant file.

`Space+f+d` offers a searchable view of diagnostics, complementing the direct
diagnostic navigation mappings described below.

## File Explorer

[`nvim-tree.lua`](https://github.com/nvim-tree/nvim-tree.lua) provides a file
explorer on the left side of the editor.

```text
Ctrl+n              Toggle file explorer
```

The explorer displays file, directory, and Git-status icons using
`nvim-web-devicons`.

Its default width is 30 columns.

## Buffers

[`bufferline.nvim`](https://github.com/akinsho/bufferline.nvim) displays open
buffers across the top of the editor in a tab-like interface.

These are Neovim **buffers**, not Vim tab pages.

```text
Alt+Left            Previous buffer
Alt+Right           Next buffer
Alt+Shift+Left      Move buffer left
Alt+Shift+Right     Move buffer right
Alt+w               Close current buffer
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
Ctrl+\              Show/hide terminal
Esc                 Leave Terminal mode
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

When an LSP server is attached to the current buffer, the status line displays
the active LSP client and its progress. For example, C/C++ buffers can show
`clangd`, while Python buffers can show `basedpyright`.

Diagnostic counts reported by the language server are also displayed in the
status line.

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
F7                  Previous color scheme
F8                  Next color scheme
```

The selected color scheme name is displayed as a notification.

Changing the theme this way is temporary. Restarting Neovim restores the
configured default.

### Toggleable Transparency

The editor supports toggleable background transparency without requiring an
additional plugin.

Transparency is disabled by default. When enabled, selected Neovim interface
elements stop drawing their own background colors, allowing the terminal's
background to show through.

```text
Space+u+t           Toggle transparency
```

The following interface elements become transparent:

- Main editor background, including the line-number and sign columns
- File explorer (nvim-tree)
- Sticky scroll (nvim-treesitter-context)
- Buffer tabs (bufferline.nvim)
- Most status-line sections (lualine.nvim)

The Lualine mode indicator on the left and the line/column position indicator
on the right retain their original colored backgrounds. This preserves their
contrast and readability.

### Transparency and Color Schemes

Transparency can be enabled or disabled without restarting Neovim.

The current transparency setting is preserved when switching color schemes
with F7 and F8.

When transparency is disabled, the original highlight colors for the currently
selected theme are restored. For example, switching from Kanagawa Dragon to
Gruvbox while transparency is enabled and then disabling transparency restores
Gruvbox's normal colors.

Both the selected color scheme and transparency setting are temporary.
Restarting Neovim restores Kanagawa Dragon with transparency disabled.

### Terminal Transparency

Neovim controls whether its interface elements draw background colors, but
the terminal emulator controls the actual window opacity.

To see the desktop or windows behind the terminal, transparency must also be
configured in the terminal emulator.

Neovim transparency can still be useful with an opaque terminal because it
allows the editor to use the terminal's own background color.

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
* Python
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
:TSInstall bash c cpp git_config gitignore lua markdown markdown_inline python ssh_config vim vimdoc
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
:TSInstall python
```

If the parser is already installed, `:TSInstall` may have nothing further to do.

To inspect the syntax tree for the current buffer:

```vim
:InspectTree
```

This is also a useful way to verify that Tree-sitter is active for the current
buffer.

## Sticky Scroll

[`nvim-treesitter-context`](https://github.com/nvim-treesitter/nvim-treesitter-context)
provides sticky scroll functionality similar to VS Code.

When scrolling through a long function, class, loop, or other supported syntax
structure, the surrounding code context remains visible at the top of the
editor window.

The plugin uses the existing Tree-sitter parsers, so no separate language
servers or external executables are required beyond the Tree-sitter
dependencies already described.

### Configuration

Sticky scroll is enabled by default with the following behavior:

- Up to three lines of surrounding code context are displayed.
- Context follows the current cursor position.
- Line numbers are displayed beside the sticky context.
- Sticky scroll is disabled in windows shorter than 10 lines.
- Context is displayed only in the active editor window.

The feature requires an installed Tree-sitter parser and appropriate context
queries for the current language.

### Keybinding

```text
Space+u+s           Toggle sticky scroll
```

The toggle takes effect immediately without restarting Neovim.

## Language Server Protocol

Language Server Protocol support is provided through Neovim's built-in LSP
client together with `nvim-lspconfig`.

The configuration currently enables:

| Language | Server |
| -------- | ------ |
| C/C++ | `clangd` |
| Python | `basedpyright` (language intelligence), `ruff` (formatting and linting) |

The language servers provide features such as:

* Diagnostics
* Code completion
* Go to definition
* Find references
* Hover documentation
* Symbol renaming
* Code actions

### LSP keybindings

The following mappings are created when an LSP server attaches to the current
buffer:

```text
gd                  Go to definition
gr                  Find references
K                   Show hover documentation
Space+r+n           Rename symbol
Space+c+a           Show code actions
```

Because these mappings are buffer-local, they are only active in buffers where
an LSP server is available.

### Completion

Neovim's built-in LSP completion is enabled when an attached language server
advertises completion support.

Completion suggestions are displayed while typing in Insert mode and use
Neovim's built-in completion facilities rather than a separate completion
plugin.

The current language servers provide completion for:

```text
C/C++       clangd
Python      basedpyright
```

### Diagnostics

Diagnostics reported by language servers are displayed by Neovim and are also
summarized in the status line and Bufferline.

Useful diagnostic mappings are:

```text
Space+d             Show diagnostics for the current line
[d                  Previous diagnostic
]d                  Next diagnostic
```

`Space+d` opens the diagnostic message for the current line in a floating
window.

The previous and next diagnostic mappings move between diagnostics and also
display the corresponding diagnostic message in a floating window.

### LSP troubleshooting

To inspect the LSP configuration and troubleshoot attached language servers,
run:

```vim
:checkhealth vim.lsp
```

The LSP clients attached to the current buffer can also be inspected with:

```vim
:lua vim.print(vim.lsp.get_clients({ bufnr = 0 }))
```

For example, a Python buffer with the configured servers running should include
clients named `basedpyright` and `ruff`.

## Formatting

Formatting uses Neovim's built-in LSP client. No separate Neovim formatting
plugin is installed.

```text
Space+f+m           Format the current buffer
```

Formatting is **manual**, not automatic on save. The shortcut sends a
whole-document formatting request to an attached language server. If none
supports formatting for the buffer, Neovim displays a warning. The request is
synchronous and has a three-second timeout.

### C and C++: clangd

`clangd` formats C and C++ through its integrated clang-format engine; a
separate `clang-format` executable is not required for this LSP operation.

A project's `.clang-format` file controls indentation, spacing, brace placement,
and other style decisions. clangd searches the source file's directory and its
parents for that file. Without one, clangd uses its configured fallback style
(LLVM by default).

### Python: Ruff

`basedpyright` does not provide document formatting. The Ruff language server
provides it instead, while also reporting lint diagnostics. Ruff formatting can
be configured using `pyproject.toml`, `ruff.toml`, or `.ruff.toml`; without a
configuration file, Ruff's defaults apply.

Hover documentation remains with basedpyright. Built-in completion is only
enabled for attached language servers that advertise completion support.

### Other languages

The same shortcut can format other languages once a suitable formatting-capable
LSP server is configured and attached. Tree-sitter parsers provide syntax
parsing/highlighting, **not** document formatting.

To inspect available formatters for the current buffer:

```vim
:lua vim.print(vim.lsp.get_clients({ bufnr = 0, method = "textDocument/formatting" }))
```

## Git Integration

[`gitsigns.nvim`](https://github.com/lewis6991/gitsigns.nvim) displays Git
changes in the sign column beside the line numbers and provides actions for
inspecting and managing individual **hunks** (contiguous groups of changed
lines). Git itself must be installed, and the file must belong to a Git
repository for repository-specific features to work.

The configured gutter indicators are:

```text
+                   Added lines
~                   Changed lines
_                   Deleted lines
‾                   Deletion at the top of the file
┆                   Untracked lines
```

Gitsigns also tracks changes before a file is saved. The configuration enables
attachment to untracked files and disables inline blame by default.

### Git keybindings

The mappings are buffer-local and are created when Gitsigns attaches:

```text
]h                  Next Git hunk
[h                  Previous Git hunk
Space+g+p           Preview current hunk
Space+g+d           Diff current file against the Git index
Space+g+s           Stage current hunk
Space+g+u           Undo staging of a hunk staged through Gitsigns
Space+g+r           Reset current hunk (discard unstaged changes)
Space+g+b           Show blame for the current line
Space+g+B           Toggle inline blame for the current line
```

### Staging, unstaging, and resetting

**Stage** (`Space+g+s`) adds only the current hunk to Git's index, allowing part
of a file to be staged without staging every change in the file.

**Undo stage** (`Space+g+u`) reverses a hunk staging operation performed by
Gitsigns in the current session. It preserves the corresponding working-tree
changes; it is not a general-purpose replacement for `git restore --staged`.

**Reset** (`Space+g+r`) discards unstaged changes in the current hunk and
restores its indexed content. **This can permanently lose work and does not
prompt for confirmation.** Use it carefully.

### Inspecting changes and blame

`Space+g+p` previews the current hunk without modifying the file.

`Space+g+d` opens a diff against Git's index. `Space+g+b` shows information
about the commit responsible for the current line, and `Space+g+B` toggles
inline blame text without changing the file.

The existing Lualine Git branch and diff components and nvim-tree Git icons
complement these features.

## Plugins

The configuration currently uses:

| Plugin | Purpose |
| --- | --- |
| `folke/lazy.nvim` | Plugin manager |
| `Mofiqul/vscode.nvim` | VS Code color scheme |
| `catppuccin/nvim` | Catppuccin color schemes |
| `folke/tokyonight.nvim` | Tokyo Night color schemes |
| `rebelot/kanagawa.nvim` | Kanagawa color schemes |
| `ellisonleao/gruvbox.nvim` | Gruvbox color scheme |
| `nvim-tree/nvim-tree.lua` | File explorer |
| `nvim-tree/nvim-web-devicons` | Nerd Font icons |
| `nvim-lualine/lualine.nvim` | Status line |
| `akinsho/bufferline.nvim` | Buffer tabs |
| `ojroques/nvim-bufdel` | Safe buffer deletion |
| `NMAC427/guess-indent.nvim` | Automatic indentation detection |
| `nvim-treesitter/nvim-treesitter` | Tree-sitter parser management |
| `nvim-treesitter/nvim-treesitter-context` | Sticky scroll using Tree-sitter context |
| `nvim-telescope/telescope.nvim` | Fuzzy finding and searchable pickers |
| `nvim-lua/plenary.nvim` | Telescope utility dependency |
| `lewis6991/gitsigns.nvim` | Git signs, hunks, and blame |
| `neovim/nvim-lspconfig` | LSP server configuration |

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

### Updating Neovim plugins

Neovim plugins are managed by `lazy.nvim`.

Check for available updates with:

```vim
:Lazy check
```

Update plugins with:

```vim
:Lazy update
```

After updating, restart Neovim and run:

```vim
:checkhealth
```

`lazy.nvim` records the resolved plugin versions in `lazy-lock.json`. This file
should be committed to the dotfiles repository.

If an update causes problems, the versions recorded in the lockfile can be
restored with:

```vim
:Lazy restore
```

### Updating Tree-sitter parsers

Tree-sitter parsers are managed separately from normal Neovim plugins.

Update installed parsers with:

```vim
:TSUpdate
```

The `nvim-treesitter` plugin is also configured to run this command after the
plugin itself is updated.

### Updating language servers

Language servers are external programs and are not managed by `lazy.nvim`.

Programs installed through the operating-system package manager should be
updated through that package manager. For example, `clangd` installed through
APT is updated through normal Debian package updates.

`basedpyright` and `ruff`, installed with pipx, can be updated with:

```bash
pipx upgrade basedpyright
pipx upgrade ruff
```

These are therefore three separate layers:

```text
Neovim plugins          lazy.nvim
Tree-sitter parsers     nvim-treesitter
Language servers        APT, pipx, or another external package manager
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

LSP configuration and attached language servers can be checked with:

```vim
:checkhealth vim.lsp
```

## Planned Improvements

The configuration is intentionally being expanded incrementally rather than
installing a large preconfigured Neovim distribution.

Tree-sitter highlighting, sticky scroll, toggleable transparency, LSP support
and built-in completion for C/C++ and Python, Telescope fuzzy finding, Git hunk
management, and manual formatting for C/C++ and Python are configured.

Potential additions include:

* Additional language-specific formatters and linters
* Comment toggling
* Surround operations
* Automatic bracket and quote pairs
* Session/project persistence
* Keybinding discovery

Formatting is currently manual via LSP, with clangd for C/C++ and Ruff for
Python.

Automatic format-on-save remains intentionally disabled.
