# dotfiles

Personal Linux configuration files for Bash, Git, SSH, tmux, and Vim.

The configurations are organized into packages and managed using [GNU Stow](https://www.gnu.org/software/stow/).

## Contents

```text
dotfiles/
├── .gitignore
├── README.md
├── bash/
│   └── .bashrc
├── bat/
│   └── .config/
│       └── bat/
│           └── config
├── git/
│   └── .gitconfig
├── ssh/
│   └── .ssh/
│       └── config
├── tmux/
│   └── .tmux.conf
└── vim/
    └── .vimrc
```

Each directory is a GNU Stow package whose contents mirror their location relative to the home directory.

For example:

```text
bash/.bashrc       → ~/.bashrc
git/.gitconfig     → ~/.gitconfig
ssh/.ssh/config    → ~/.ssh/config
tmux/.tmux.conf    → ~/.tmux.conf
vim/.vimrc         → ~/.vimrc
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

### 2. Clone the repository

Clone the repository into the home directory:

```bash
git clone <repository-url> ~/dotfiles
cd ~/dotfiles
```

Replace `<repository-url>` with the URL of this repository.

### 3. Handle existing configuration

GNU Stow will not overwrite conflicting files automatically.

If configuration files already exist, move them into the corresponding package in this repository before creating the symbolic links.

For example, for an existing `.bashrc`:

```bash
mv ~/.bashrc ~/dotfiles/bash/.bashrc
```

Do the same for any other configuration that should be managed by this repository.

Be especially careful with `~/.ssh/`: only the SSH configuration belongs in this repository. Private keys and other SSH files should remain in `~/.ssh/`.

### 4. Create the symbolic links

Install all packages:

```bash
stow --no-folding bash bat git ssh tmux vim
```

Or install packages individually:

```bash
stow --no-folding bash
stow --no-folding git
```

`--no-folding` makes Stow create links for the individual managed files and directories rather than replacing an entire directory with a symbolic link.

This is particularly useful for directories such as `~/.ssh/`, which contain files that are intentionally not managed by this repository.

After installation, the configuration files in the home directory will point to the files in this repository:

```text
~/.bashrc       → ~/dotfiles/bash/.bashrc
~/.gitconfig    → ~/dotfiles/git/.gitconfig
~/.ssh/config   → ~/dotfiles/ssh/.ssh/config
~/.tmux.conf    → ~/dotfiles/tmux/.tmux.conf
~/.vimrc        → ~/dotfiles/vim/.vimrc
```

## Updating

Because the files in the home directory are symbolic links, editing them also edits the files stored in this repository.

Changes can therefore be committed normally:

```bash
cd ~/dotfiles

git status
git add .
git commit -m "Update configuration"
git push
```

When the repository is cloned onto another machine, running Stow recreates the required symbolic links.

## Removing Configuration

Remove the symbolic links for a package without deleting its files from the repository:

```bash
stow --delete --no-folding bash
```

Recreate the links for a package:

```bash
stow --restow --no-folding bash
```

This can be useful after changing the structure of a package.

## Machine-Specific Configuration

Some configuration should apply only to a particular machine or should not be stored in a public repository.

Files ending in `.local` are ignored by Git and can be used for this purpose.

### Bash

The tracked `.bashrc` automatically loads:

```text
~/.bashrc.local
```

when the file exists.

This file can contain machine-specific paths, environment variables, aliases, or other settings that should not be shared between machines.

For example:

```bash
export SOME_LOCAL_PATH="$HOME/something"
alias local-command='...'
```

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

Hostnames, usernames, and IP addresses are not inherently secrets and may be placed in the tracked configuration when appropriate. `config.local` is useful when those details are private or specific to one machine.

## Sensitive Information

Credentials and secrets must never be committed to this repository.

In particular, do not commit:

* SSH private keys
* Passwords
* API keys
* Access tokens
* Authentication credentials
* Private certificates

SSH private keys such as:

```text
~/.ssh/id_rsa
~/.ssh/id_ed25519
```

must remain outside the repository.

Public SSH keys are not secret, but they are also not managed by this repository.

The repository is intended to manage **configuration**, not credentials.

## Configuration Overview

### Bash

`bash/.bashrc` contains interactive Bash configuration, including:

* Shell history settings
* Persistent history behavior
* Vim as the default terminal editor
* Compatibility aliases for tools whose command names differ between distributions
* Automatic attachment to the most recently active tmux session when logging in through SSH
* Support for machine-specific settings through `~/.bashrc.local`

Additional aliases or shell behavior should be added only when they are actually useful.

When logging in through SSH, Bash automatically attaches to the most recently
active tmux session. If no tmux session exists, a new one is created.

This behavior only applies to interactive SSH sessions when tmux is installed
and the shell is not already running inside tmux. Exiting tmux also ends the
SSH session.

### Bat

`bat/.config/bat/config` contains configuration for `bat`, a syntax-highlighting
file viewer.

On Debian and Ubuntu, the executable may be installed as `batcat`. The Bash
configuration provides a `bat` alias when `batcat` is installed but `bat` is
not available.

### Git

`git/.gitconfig` contains:

* Git user identity
* Vim as the default Git editor
* `main` as the default initial branch
* Automatic upstream configuration for new branches
* Frequently used Git aliases

### SSH

`ssh/.ssh/config` contains:

* Connection keepalive settings
* SSH agent integration
* Support for machine-specific configuration through `~/.ssh/config.local`

Private keys are not managed by this repository.

### tmux

`tmux/.tmux.conf` contains terminal multiplexer configuration, including:

* Mouse support
* Clipboard integration
* Extended scrollback history
* Window and pane numbering
* Automatic window renumbering
* Pane behavior
* Improved responsiveness
* Vim-style copy-mode navigation
* Configuration reloading

### Vim

`vim/.vimrc` contains editor configuration, including:

* Filetype detection and indentation
* Syntax highlighting
* Search behavior
* Tab and indentation settings
* Visible whitespace
* Persistent undo
* Completion behavior
* Scrolling behavior
* C/C++ indentation
* Terminal color support
* Line-number and whitespace highlighting

Historical settings that are currently disabled are kept commented out for reference.

## Adding New Configuration

When adding another configuration file, create a new Stow package whose contents mirror the path relative to the home directory.

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

## Tools

This repository configures or makes use of the following command-line tools:

- Bash — interactive shell
- Git — version control
- OpenSSH — SSH client
- tmux — terminal multiplexer
- Vim — text editor
- GNU Stow — dotfile symlink management
- bat — syntax-highlighting file viewer
- Git LFS — large-file support for Git

The repository manages configuration for these tools, but does not install
them. Package names and installation methods may differ between Linux
distributions.

## Possible Future Additions

Configuration that may be useful to manage in the future includes:

* `.bash_profile` — Bash login-shell configuration
* `.profile` — login environment configuration
* `.inputrc` — GNU Readline configuration
* `~/.local/bin/` — personal scripts and commands
* `~/.config/systemd/user/` — user-level systemd services
* Terminal emulator configuration
* Other application configuration under `~/.config/`

These should only be added when they are actually needed.

## Philosophy

Keep the configuration small, understandable, and intentional.

Every setting in this repository should have a clear purpose. New configuration should be added when it solves a real problem or improves an established workflow, rather than simply because it is a commonly recommended setting.
