# dotfiles

Personal Linux configuration files for Bash, Git, SSH, tmux, Vim,
Neovim, and related command-line tools.

The configurations are organized into packages and managed using [GNU
Stow](https://www.gnu.org/software/stow/).

## Contents

```text
dotfiles/
├── .gitignore
├── README.md
├── bash/
│   ├── .bash_profile
│   ├── .bashrc
│   └── .config/
│       └── bash/
│           └── functions/
│               └── cppsymbols.sh
├── bat/
│   └── .config/
│       └── bat/
│           └── config
├── bin/
│   ├── .stow-local-ignore
│   ├── .local/
│   │   └── bin/
│   │       └── bz
│   └── README.md
├── gdb/
│   └── .gdbinit
├── git/
|   ├── .gitattributes
│   └── .gitconfig
├── ssh/
│   └── .ssh/
│       └── config
├── tmux/
│   └── .tmux.conf
└── vim/
    ├── .stow-local-ignore
    ├── .vimrc
    ├── .vim/
    │   └── autoload/
    │       └── osc52.vim
    └── README.md
```

Each directory is a GNU Stow package whose contents mirror their
location relative to the home directory.

For example:

```text
bash/.bash_profile → ~/.bash_profile
bash/.bashrc       → ~/.bashrc
bash/.config/bash/functions/cppsymbols.sh → ~/.config/bash/functions/cppsymbols.sh
bin/.local/bin/bz  → ~/.local/bin/bz
gdb/.gdbinit       → ~/.gdbinit
git/.gitconfig     → ~/.gitconfig
ssh/.ssh/config    → ~/.ssh/config
tmux/.tmux.conf    → ~/.tmux.conf
vim/.vimrc         → ~/.vimrc
vim/.vim/autoload/osc52.vim → ~/.vim/autoload/osc52.vim
```

## Installation

### 1. Install GNU Stow

On Debian/Ubuntu:

```bash
sudo apt install stow
```

On Fedora:

```bash
sudo dnf install stow
```

On Arch Linux:

```bash
sudo pacman -S stow
```

### 2. Install optional dependencies

The dotfiles repository manages configuration but does not install the programs
that use that configuration.

Only GNU Stow is required to create the symbolic links. The additional tools
below are required only for the corresponding features.

On Debian and Raspberry Pi OS, most dependencies can be installed with:

```bash
sudo apt update

sudo apt install \
    bash-completion \
    bat \
    curl \
    figlet \
    gdb \
    git \
    git-lfs \
    jq \
    less \
    lolcat \
    screenfetch \
    tmux \
    universal-ctags \
    vim
```

Some package names or availability may differ between Debian releases and other
Linux distributions.

#### Bash

The interactive Bash configuration can make use of:

* `bash-completion` — programmable, command-aware shell completion
* `bat` — syntax-highlighting file viewer
* Universal Ctags — C/C++ source-code analysis used by `cppsymbols`
* `jq` — processing, sorting, and formatting of Ctags JSON output
* `tmux` — automatic persistent terminal sessions for SSH logins and host clipboard access through OSC 52

The `cppsymbols`, `cppsyms`, and `cppsymsloc` helpers require both Universal
Ctags and `jq`.

#### Login banner

The Raspberry Pi login banner can make use of:

* Screenfetch — Raspbian ASCII artwork
* figlet — large machine-name heading
* lolcat — colorized figlet output
* curl — public-IP and weather lookups
* `vcgencmd` — Raspberry Pi CPU temperature and throttling information

`vcgencmd` is Raspberry Pi-specific and is normally provided by Raspberry Pi
OS rather than installed as a general dotfiles dependency.

The banner checks for optional commands before using them where appropriate, so
missing decorative tools do not prevent the shell from starting.

#### Git

Git is required for version control and for cloning this repository.

Git LFS is used when repositories contain files managed through Git Large File
Storage.

After installing Git LFS for the first time, initialize it with:

```bash
git lfs install
```

#### tmux

tmux is required for the managed terminal multiplexer configuration.

The configuration also uses TPM and several tmux plugins. See the
[tmux configuration](#tmux-plugins) section for plugin installation and usage.

#### Neovim and Tree-sitter

Neovim may be installed separately when a newer version than the distribution
package is required.

Machine-specific Neovim installation paths should be added to
`~/.bashrc.local` rather than the tracked `.bashrc`. For example:

```bash
export PATH="/opt/nvim-linux-arm64/bin:$PATH"
```

The Neovim Tree-sitter configuration also requires the external tools needed
to build parsers:

* `tar`
* `curl`
* `tree-sitter-cli` 0.26.1 or later
* A C compiler

`tree-sitter-cli` should be installed through an appropriate package manager
rather than npm.

These Neovim-specific requirements can be expanded when the Neovim
configuration is fully documented in this README.

### 3. Clone the repository

Clone the repository into the home directory:

```bash
git clone <repository-url> ~/dotfiles
cd ~/dotfiles
```

Replace `<repository-url>` with the URL of this repository.

### 4. Handle existing configuration

GNU Stow will not overwrite conflicting files automatically.

If configuration files already exist, move them into the corresponding
package in this repository before creating the symbolic links.

For example, for an existing `.bashrc`:

```bash
mv ~/.bashrc ~/dotfiles/bash/.bashrc
```

Do the same for any other configuration that should be managed by this
repository.

Be especially careful with `~/.ssh/`: only the SSH configuration belongs
in this repository. Private keys and other SSH files should remain in
`~/.ssh/`.

### 5. Create the symbolic links

Install all packages:

```bash
stow --no-folding bash bat bin gdb git ssh tmux vim
```

Or install packages individually:

```bash
stow --no-folding bash
stow --no-folding bat
stow --no-folding bin
stow --no-folding gdb
stow --no-folding git
stow --no-folding ssh
stow --no-folding tmux
stow --no-folding vim
```

`--no-folding` makes Stow create links for the individual managed files
and directories rather than replacing an entire directory with a
symbolic link.

This is particularly useful for directories such as `~/.ssh/`, which
contain files that are intentionally not managed by this repository.

After installation, the configuration files in the home directory will
point to the files in this repository:

```text
~/.bash_profile → ~/dotfiles/bash/.bash_profile
~/.bashrc       → ~/dotfiles/bash/.bashrc
~/.gdbinit      → ~/dotfiles/gdb/.gdbinit
~/.gitconfig    → ~/dotfiles/git/.gitconfig
~/.ssh/config   → ~/dotfiles/ssh/.ssh/config
~/.tmux.conf    → ~/dotfiles/tmux/.tmux.conf
~/.vimrc        → ~/dotfiles/vim/.vimrc
```

#### Package documentation

Individual Stow packages may contain their own `README.md` when the
configuration is substantial enough to benefit from dedicated documentation.

Package-level documentation belongs to the repository but should not be
symlinked into the home directory. Packages containing such files therefore
use `.stow-local-ignore` to exclude them from Stow.

For example:

```text
vim/
├── .stow-local-ignore
├── .vimrc
├── .vim/
│   └── autoload/
│       └── osc52.vim
└── README.md
````

with:

```text
README\.md
```

When:

```bash
stow --no-folding vim
```

is run, `.vimrc` is managed normally while `README.md` remains only in the
repository.

`.stow-local-ignore` controls which files GNU Stow ignores; it is unrelated to
`.gitignore`, which controls which files Git tracks.

## Updating

Because the files in the home directory are symbolic links, editing them
also edits the files stored in this repository.

Changes can therefore be committed normally:

```bash
cd ~/dotfiles

git status
git add .
git commit -m "Update configuration"
git push
```

When the repository is cloned onto another machine, running Stow
recreates the required symbolic links.

## Removing Configuration

Remove the symbolic links for a package without deleting its files from
the repository:

```bash
stow --delete --no-folding bash
```

Recreate the links for a package:

```bash
stow --restow --no-folding bash
```

This can be useful after changing the structure of a package.

## Machine-Specific Configuration

Some configuration should apply only to a particular machine or should
not be stored in a public repository.

Machine-specific files such as `~/.bashrc.local`, `~/.vimrc.local`, and
`~/.ssh/config.local` should remain outside the tracked Stow packages.
Files that contain private information should also be excluded explicitly
when necessary.

### Bash

The tracked `.bashrc` automatically loads:

```text
~/.bashrc.local
```

when the file exists.

This file can contain machine-specific paths, environment variables,
aliases, or other settings that should not be shared between machines.

For example, a Raspberry Pi with Neovim installed manually under `/opt` can
contain:

```bash
export PATH="/opt/nvim-linux-arm64/bin:$PATH"
```

Other machine-specific paths, environment variables, aliases, and settings can
be added to the same file as required.

Keeping these settings in `~/.bashrc.local` prevents machine-specific
configuration from leaking into the portable dotfiles repository.

### SSH

The tracked SSH configuration loads:

```text
~/.ssh/config.local
```

using:

```sshconfig
Include ~/.ssh/config.local
```

This file can contain machine-specific or private SSH host definitions.

For example:

```sshconfig
Host server
    HostName 192.168.1.10
    User user
    Port 22
    IdentityFile ~/.ssh/id_ed25519
```

The host can then be accessed with:

```bash
ssh server
```

Hostnames, usernames, and IP addresses are not inherently secrets and
may be placed in the tracked configuration when appropriate.
`config.local` is useful when those details are private or specific to
one machine.

### Vim

The tracked `.vimrc` optionally loads:

```text
~/.vimrc.local
```

when the file exists.

This file can contain machine-specific or private Vim settings that should not
be stored in the shared dotfiles repository.

Because `.vimrc.local` is loaded after the main configuration, settings in it
can intentionally override values from the tracked `.vimrc`.

For example:

```vim
set colorcolumn=100
colorscheme desert
```

`~/.vimrc.local` is not part of the `vim` Stow package and should remain
outside the repository.

## Sensitive Information

Credentials and secrets must never be committed to this repository.

In particular, do not commit:

-   SSH private keys
-   Passwords
-   API keys
-   Access tokens
-   Authentication credentials
-   Private certificates

SSH private keys such as:

```text
~/.ssh/id_rsa
~/.ssh/id_ed25519
```

must remain outside the repository.

Public SSH keys are not secret, but they are also not managed by this
repository.

The repository is intended to manage **configuration**, not credentials.


## Configuration Overview

### Bash

The Bash package contains separate configuration for login shells and
normal interactive shells.

`bash/.bash_profile` is used by Bash login shells, including SSH login
sessions. For interactive login shells it displays a Raspberry
Pi-oriented system banner and then loads `~/.bashrc`.

The login banner uses Screenfetch's Raspbian ASCII artwork on the left
and a custom diagnostic panel on the right. The diagnostic panel
includes:

-   Current date and time
-   Operating system and kernel
-   Current shell and shell version
-   Number of installed Debian packages
-   Uptime
-   Memory usage: used, available, and total
-   Root filesystem usage
-   1, 5, and 15 minute load averages
-   Running process count
-   Available APT updates
-   Separate IPv4 addresses for Wi-Fi (`wlan0`) and Ethernet (`eth0`)
-   Public IPv4 address
-   Current weather for Lisbon
-   CPU vendor, model, core count, and maximum frequency
-   Raspberry Pi CPU temperature
-   Raspberry Pi firmware throttling, under-voltage, and thermal status
-   Reboot-required warnings

The banner is restricted to interactive shells so that non-interactive
SSH commands are not polluted with decorative output. Network-dependent
lookups such as the public IP address and weather use short timeouts so
they do not significantly delay login when the network or remote service
is unavailable.

Screenfetch is used only for the Raspbian ASCII artwork; the diagnostic
values are collected independently. ANSI escape sequences in the artwork
are ignored when calculating its visible width so that the diagnostics
remain aligned.

`bash/.bashrc` contains configuration for interactive Bash shells, including:

* Expanded and persistent shell history
* Automatic terminal-size updates after terminal, SSH, or tmux resizing
* Vim as the default terminal editor
* `~/.local/bin` at the front of `PATH` when that directory exists
* A colored `user@host:directory` prompt
* Automatic terminal-title updates in compatible terminals
* Colorized `ls` and `grep` output when GNU `dircolors` is available
* Programmable command completion when `bash-completion` is installed
* Compatibility aliases for tools whose command names differ between distributions
* A `copy` helper for copying text to the host system clipboard through OSC 52
* Modular Bash helper functions loaded from `~/.config/bash/functions/`
* C/C++ source inspection using Universal Ctags and `jq`
* Support for machine-specific settings through `~/.bashrc.local`
* Automatic attachment to the most recently active tmux session when logging in through SSH

The Bash package provides a `cppsymbols` helper for quickly inspecting classes
and functions in C++ source code.

The implementation is kept separately from `.bashrc` in:

```text
~/.config/bash/functions/cppsymbols.sh
```

and is loaded automatically by `.bashrc` when the file exists.

The helper uses Universal Ctags to parse C++ source code and produce JSON
records. These records are processed with `jq` to provide deterministic
sorting and colorized, human-readable terminal output without creating a
persistent `tags` file.

By default, symbols are sorted alphabetically by name:

```bash
cppsymbols file.cpp
cppsymbols include/foo.hpp src/foo.cpp
cppsymbols src/
```

The sort order can also be selected explicitly:

```bash
cppsymbols --by-name src/
cppsymbols --by-location src/
```

`--by-name` sorts by symbol name, followed by file and line number.
`--by-location` sorts by file name, line number, and symbol name.

Directories are searched recursively.

Two convenience wrappers provide paged output through `less` while preserving
ANSI colors:

```bash
cppsyms src/
cppsymsloc src/
```

`cppsyms` sorts symbols by name, while `cppsymsloc` sorts them by source
location.

The helper currently reports C++ classes and functions/methods. All supplied
files are explicitly interpreted as C++, so the helper is intended for C++
source files and source trees rather than mixed-language directories.

The helper requires both Universal Ctags and `jq` to be installed and
available in `PATH`.

The Bash configuration also provides a `copy` helper for copying text to the
host terminal's system clipboard:

```bash
copy "hello world"
printf '%s' "hello world" | copy
cat file.txt | copy
```

When arguments are supplied, `copy` copies them without adding a trailing
newline. When standard input is used, the input is preserved exactly, including
any trailing newline. For example:

```bash
echo "hello" | copy
```

copies the newline written by `echo`, while:

```bash
printf '%s' "hello" | copy
```

does not.

The helper works both directly over SSH and from inside tmux. Outside tmux, it
encodes the input with Base64 and emits an OSC 52 escape sequence directly.
Inside tmux, it uses `tmux load-buffer -w` and lets tmux handle the OSC 52
clipboard operation.

In both cases, the OSC 52 sequence travels through the terminal connection to
the local terminal emulator, which places the contents in the host system
clipboard. The local terminal emulator must support OSC 52 clipboard
operations.

Larger shell helpers are kept outside `.bashrc` so that the main interactive shell configuration remains easy to read and maintain. Additional substantial helpers can be added under `~/.config/bash/functions/` as they become useful.

Machine-specific paths should be placed in `~/.bashrc.local` rather than the tracked `.bashrc`. For example, a manually installed Neovim on a Raspberry Pi can be added with:

```bash
export PATH="/opt/nvim-linux-arm64/bin:$PATH"
```

Keeping machine-specific configuration outside the tracked `.bashrc` allows
the main Bash configuration to remain portable across different Linux
machines.

Additional aliases, functions, or shell behavior should be added only when
they solve an actual problem or improve an established workflow.

When logging in through SSH, Bash automatically attaches to the most
recently active tmux session. If no tmux session exists, a new one is
created.

This behavior only applies to interactive SSH sessions when tmux is
installed and the shell is not already running inside tmux. Exiting tmux
also ends the SSH session.

### Bat

`bat/.config/bat/config` contains configuration for `bat`, a
syntax-highlighting file viewer.

On Debian and Ubuntu, the executable may be installed as `batcat`. The
Bash configuration provides a `bat` alias when `batcat` is installed but
`bat` is not available.

### Bin

The `bin` package contains personal command-line utilities installed under
`~/.local/bin/`.

It currently provides `bz`, a small Bash client for Bugzilla's REST API.
`bz` can display bug details, comments, and change history; search for bugs;
and print the corresponding Bugzilla web URL.

The command requires Bash 4 or later, `curl`, and `jq`. Bugzilla connection
settings are read from:

```text
~/.config/bz/config
```

For configuration, authentication, commands, search options, and usage
examples, see [`bin/README.md`](bin/README.md).

### Git

`git/.gitconfig` contains:

-   Git user identity
-   Vim as the default Git editor
-   `main` as the default initial branch
-   Automatic upstream configuration for new branches
-   Automatic pruning of remote-tracking branches that no longer exist
    on the remote
-   Frequently used Git aliases

`git/.gitattributes` contains:

-   Line-ending normalization for text files

### SSH

`ssh/.ssh/config` contains:

-   Connection keepalive settings
-   SSH agent integration
-   Support for machine-specific configuration through
    `~/.ssh/config.local`

Private keys are not managed by this repository.

### tmux

`tmux/.tmux.conf` contains terminal multiplexer configuration, including:

* Mouse support for selecting panes, resizing panes, selecting windows, and scrolling
* System clipboard integration
* Extended per-pane scrollback history
* Windows and panes numbered from 1
* Automatic window renumbering
* New panes opened in the current pane's working directory
* Reduced Escape-key delay for better Vim and Neovim responsiveness
* Terminal focus-event reporting
* Vim-style copy-mode navigation
* Status-bar configuration
* A `Prefix + r` shortcut for reloading the configuration without restarting tmux

The configuration uses [TPM](https://github.com/tmux-plugins/tpm), the Tmux
Plugin Manager, to manage additional tmux functionality.

The following plugins are configured:

* `tmux-plugins/tmux-sensible` — provides a small collection of generally useful tmux defaults
* `tmux-plugins/tmux-resurrect` — saves and restores tmux sessions, windows, panes, working directories, pane contents, and shell history
* `tmux-plugins/tmux-continuum` — periodically saves the tmux environment and automatically restores the most recent environment when the tmux server starts

`tmux-resurrect` is configured to capture pane contents and shell command
history. Vim and Neovim processes are restored using their respective session
strategies rather than simply starting fresh editor processes.

`tmux-continuum` automatically saves the tmux environment periodically and
restores the latest saved environment when a new tmux server starts.

Together with the Bash configuration's automatic tmux attachment over SSH,
this provides a persistent remote shell environment: reconnecting through SSH
reattaches to an existing tmux session when possible, while tmux-resurrect and
tmux-continuum can reconstruct saved sessions after the tmux server or machine
has been restarted.

<a name="tmux-plugins"></a>
#### Installing tmux plugins

The tmux configuration uses TPM (Tmux Plugin Manager) to install and manage
plugins.

After installing the dotfiles on a new machine, install TPM with:

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

Start or reload tmux, then install the configured plugins with:

```text
Prefix + I
```

With tmux's default prefix, this means pressing:

```text
Ctrl-b, then Shift-i
```

TPM will install the plugins declared in `.tmux.conf`:

* `tmux-plugins/tmux-sensible`
* `tmux-plugins/tmux-resurrect`
* `tmux-plugins/tmux-continuum`

The plugin directories under `~/.tmux/plugins/` are installed and managed by
TPM and should not be committed to this dotfiles repository.

Useful TPM shortcuts include:

```text
Prefix + I          Install plugins
Prefix + U          Update plugins
Prefix + Alt-u      Remove plugins no longer declared in .tmux.conf
```

The tmux configuration itself can be reloaded at any time with:

```text
Prefix + r
```

With the default prefix:

```text
Ctrl-b, then r
```

`tmux-resurrect` also provides manual persistence shortcuts:

```text
Prefix + Ctrl-s     Save the current tmux environment
Prefix + Ctrl-r     Restore the most recently saved environment
```

Automatic periodic saving and startup restoration are handled by
`tmux-continuum`.

The tmux configuration enables system clipboard integration with:

```tmux
set -s set-clipboard on
```

This allows tmux and applications running inside tmux to communicate with the
outer terminal's system clipboard through OSC 52.

The Bash `copy` helper uses this integration when running inside tmux by passing
its input to `tmux load-buffer -w`. When Bash is running outside tmux, the
helper emits OSC 52 directly instead. This allows the same `copy` command to
work with both of these remote-shell configurations:

```text
local terminal → SSH → Bash
local terminal → SSH → tmux → Bash
```

The Vim configuration also uses OSC 52 when copying remote selections to the
local system clipboard.

In all cases, the terminal emulator on the local host must support OSC 52
clipboard operations.

### GDB

`gdb/.gdbinit` provides a small set of defaults for debugging C and C++
programs with GDB.

The configuration includes:

- Disabled output pagination for easier terminal and tmux scrollback
- Pretty-printing of structures, classes, arrays, and other compound values
- Array indexes when displaying array elements
- Dynamic C++ object type display when available
- Demangling of C++ names in normal and assembly output
- Persistent command history across GDB sessions
- A command history limit of 10,000 entries
- Ten-line source listings
- Confirmation prompts for potentially destructive operations

GDB command history is stored in:

```text
~/.gdb_history
```

Intel assembly syntax is documented in `.gdbinit` but remains disabled by
default:

```gdb
#set disassembly-flavor intel
```

Uncomment it if Intel syntax is preferred over GDB's default AT&T syntax.

The configuration deliberately remains small and relies on GDB's standard
functionality rather than introducing debugger frameworks or machine-specific
Python configuration.

### Vim

`vim/.vimrc` provides a lightweight terminal-oriented Vim configuration for
general editing, including use over SSH and inside tmux.

The configuration includes:

- Filetype detection, syntax highlighting, and indentation
- Search, completion, whitespace, and scrolling behavior
- Tab-page management and navigation
- Custom editing and save mappings
- System clipboard and OSC 52 remote clipboard support
- Interactive colorscheme selection
- Persistent undo
- C/C++-specific indentation
- Support for machine-specific settings through `~/.vimrc.local`

For installation requirements, configuration details, mappings, clipboard
behavior, colorscheme selection, and usage, see
[`vim/README.md`](vim/README.md).

## Adding New Configuration

When adding another configuration file, create a new Stow package whose
contents mirror the path relative to the home directory.

For example, to manage:

```text
~/.inputrc
```

create:

```text
dotfiles/
└── readline/
    └── .inputrc
```

Then install it with:

```bash
stow --no-folding readline
```

For an application using `~/.config/`, mirror that directory structure.

For example:

```text
~/.config/example/config
```

would become:

```text
dotfiles/
└── example/
    └── .config/
        └── example/
            └── config
```

and could then be installed with:

```bash
stow --no-folding example
```

If a package requires substantial package-specific documentation, add a
`README.md` inside the package and add it to that package's
`.stow-local-ignore` so that Stow does not create a corresponding symlink in
the home directory.

Small configurations should remain documented in the main repository README
rather than receiving a separate package README.

## Tools

This repository configures or makes use of the following command-line
tools:

* Bash — interactive shell
* bash-completion — programmable, command-aware completion for Bash
* GDB — debugger for C and C++ programs
* Git — version control
* OpenSSH — SSH client
* tmux — terminal multiplexer
* TPM — plugin manager for tmux
* tmux-sensible — sensible baseline defaults for tmux
* tmux-resurrect — tmux session persistence and restoration
* tmux-continuum — automatic periodic saving and restoration of tmux sessions
* Vim — terminal text editor with tab-page, clipboard, OSC 52, colorscheme,
  persistent-undo, and C/C++ editing configuration
* Universal Ctags — source-code indexing and C/C++ symbol discovery used by the `cppsymbols` Bash helper
* `bz` — personal Bugzilla REST API command-line client
* `jq` — JSON processing used by `cppsymbols` and `bz`
* GNU Stow — dotfile symlink management
* bat — syntax-highlighting file viewer
* Git LFS — large-file support for Git
* Screenfetch — Raspbian ASCII artwork for the login banner
* figlet — large machine-name heading in the login banner
* lolcat — optional color for the figlet heading
* `curl` — HTTP client used by `bz` and by public-IP and weather lookups in the login banner
* Raspberry Pi `vcgencmd` — CPU temperature, clock, and throttling information

The repository manages configuration for these tools but does not install them.
See the **Install optional dependencies** section for the dependencies used by
each part of the configuration. Package names and installation methods may
differ between Linux distributions.

## Possible Future Additions

Configuration that may be useful to manage in the future includes:

-   `.profile` --- login environment configuration
-   `.inputrc` --- GNU Readline configuration
-   `~/.config/systemd/user/` --- user-level systemd services
-   Terminal emulator configuration
-   Other application configuration under `~/.config/`

These should only be added when they are actually needed.

## Philosophy

Keep the configuration small, understandable, and intentional.

Every setting in this repository should have a clear purpose. New
configuration should be added when it solves a real problem or improves
an established workflow, rather than simply because it is a commonly
recommended setting.
