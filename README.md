# dotfiles

Personal Linux configuration files for Bash, Vim, Git, tmux, and SSH.

The configurations are organized into packages and managed using [GNU Stow](https://www.gnu.org/software/stow/).

## Contents

```text
dotfiles/
├── bash/
│   └── .bashrc
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

Each directory is a Stow package that mirrors the file's location relative to the home directory.

For example:

```text
bash/.bashrc       → ~/.bashrc
git/.gitconfig     → ~/.gitconfig
ssh/.ssh/config    → ~/.ssh/config
tmux/.tmux.conf    → ~/.tmux.conf
vim/.vimrc         → ~/.vimrc
```

## Installation

### 1. Clone the repository

```bash
git clone <repository-url> ~/dotfiles
cd ~/dotfiles
```

### 2. Install GNU Stow

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

### 3. Create the symlinks

Install all configurations:

```bash
stow bash git ssh tmux vim
```

Or install individual configurations:

```bash
stow bash
stow vim
```

By default, Stow creates the appropriate symbolic links in the parent directory (`$HOME` when the repository is located at `~/dotfiles`).

## Existing Configuration

Stow will not overwrite conflicting files automatically.

Before using Stow, existing configuration files should be backed up or moved into this repository.

For example:

```bash
mkdir -p ~/dotfiles/bash
mv ~/.bashrc ~/dotfiles/bash/
```

After moving the file:

```bash
cd ~/dotfiles
stow bash
```

The resulting setup will look like:

```text
~/.bashrc → ~/dotfiles/bash/.bashrc
```

The same process can be used for the other configuration files.

## Updating

Because the files in `$HOME` are symbolic links, configuration changes are made directly to the files stored in this repository.

Commit and push changes normally:

```bash
git add .
git commit -m "Update configuration"
git push
```

After cloning the repository onto another machine, running Stow recreates the required symbolic links.

## Removing Configuration

Remove the symbolic links for a package without deleting the files from this repository:

```bash
stow --delete bash
```

Recreate a package's links:

```bash
stow --restow bash
```

## SSH Configuration

Only SSH configuration is tracked. **Private keys and credentials should never be committed to this repository.**

Files such as the following should remain outside version control:

```text
~/.ssh/id_rsa
~/.ssh/id_ed25519
~/.ssh/*.pem
```

Machine-specific or sensitive SSH settings can be placed in a separate file:

```text
~/.ssh/config.local
```

and loaded from the tracked configuration with:

```sshconfig
Include ~/.ssh/config.local
```

This keeps hostnames, usernames, addresses, and other machine-specific information out of the repository when necessary.

## Future Additions

Other configuration files may be added as needed, including:

* `.bash_profile` — Bash login shell configuration
* `.profile` — login environment configuration
* `.inputrc` — GNU Readline configuration
* `~/.config/nvim/` — Neovim configuration
* `~/.config/systemd/user/` — user-level systemd services
* `~/.local/bin/` — personal scripts and commands
* Terminal emulator configuration
* Shell prompt configuration
* Other application configuration under `~/.config/`

Only configurations that are actively used need to be added.

## License

These files are primarily intended for personal use, but feel free to use or adapt anything that is useful.
