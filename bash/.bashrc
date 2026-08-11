# =============================================================================
# Interactive shell
# =============================================================================

# Stop processing this file when Bash is not running interactively.
#
# .bashrc is intended for interactive shell configuration. This prevents
# prompts, aliases, completion, and other interactive settings from affecting
# scripts or non-interactive Bash sessions.
case $- in
    *i*) ;;
      *) return ;;
esac


# =============================================================================
# History
# =============================================================================

# Keep more commands available in the current shell session.
HISTSIZE=10000

# Keep more commands in ~/.bash_history across shell sessions.
HISTFILESIZE=20000

# Ignore consecutive duplicate commands and commands beginning with a space.
#
# `ignoreboth` is equivalent to:
#
#     ignorespace:ignoredups
HISTCONTROL=ignoreboth

# Append to the history file instead of overwriting it when the shell exits.
#
# This is useful when several terminal sessions are open at the same time.
shopt -s histappend


# =============================================================================
# Terminal behavior
# =============================================================================

# Recheck the terminal dimensions after each command.
#
# This keeps Bash's LINES and COLUMNS variables synchronized when the terminal
# is resized, including when working through SSH or tmux.
shopt -s checkwinsize

# Recursive globbing with `**` is available in Bash but intentionally disabled.
#
# When enabled, patterns such as:
#
#     **/*.cpp
#
# recursively match files in subdirectories.
#
# Enable later if this becomes useful.
# shopt -s globstar


# =============================================================================
# Default editor
# =============================================================================

# Use Vim as the default terminal editor.
#
# Many command-line programs consult one or both of these variables when they
# need to open an editor.
export EDITOR=vim
export VISUAL=vim


# =============================================================================
# User executables
# =============================================================================

# Add the standard per-user executable directory to PATH when it exists.
#
# ~/.local/bin is commonly used for programs installed manually for the current
# user. Keeping them here avoids requiring root privileges and keeps
# user-installed software separate from system packages.
#
# Placing it before the existing PATH also means a user-installed version of a
# program takes precedence over a system-wide version with the same name.
if [[ -d "$HOME/.local/bin" ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi


# =============================================================================
# Prompt
# =============================================================================

# Use a colored prompt when the terminal supports ANSI colors.
#
# The prompt displays:
#
#     user@host:current-directory $
#
# with:
#
#     user@host          green
#     current-directory  blue
#
# If color support cannot be detected, fall back to a plain prompt.
if command -v tput >/dev/null 2>&1 \
    && tput setaf 1 >/dev/null 2>&1
then
    PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='\u@\h:\w\$ '
fi


# -----------------------------------------------------------------------------
# Terminal title
# -----------------------------------------------------------------------------

# Set the terminal window title to:
#
#     user@host: current-directory
#
# for terminals that understand xterm-compatible title sequences.
case "$TERM" in
    xterm*|rxvt*)
        PS1="\[\e]0;\u@\h: \w\a\]$PS1"
        ;;
esac


# =============================================================================
# Colored command output
# =============================================================================

# Enable GNU coreutils color definitions when available.
#
# If ~/.dircolors exists, use the user's custom color configuration.
# Otherwise, use the system defaults.
if command -v dircolors >/dev/null 2>&1; then
    if [[ -r "$HOME/.dircolors" ]]; then
        eval "$(dircolors -b "$HOME/.dircolors")"
    else
        eval "$(dircolors -b)"
    fi

    # Colorize directory listings when output is written to a terminal.
    alias ls='ls --color=auto'

    # Colorize matching text in grep output.
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi


# =============================================================================
# Programmable completion
# =============================================================================

# Enable command-aware Tab completion when the bash-completion package is
# installed.
#
# This provides richer completion for many commands, including Git, SSH,
# systemd, package managers, and other command-line tools.
#
# Skip this when Bash is running in POSIX mode.
if ! shopt -oq posix; then
    if [[ -r /usr/share/bash-completion/bash_completion ]]; then
        source /usr/share/bash-completion/bash_completion
    elif [[ -r /etc/bash_completion ]]; then
        source /etc/bash_completion
    fi
fi


# =============================================================================
# Tool compatibility
# =============================================================================

# Debian and Ubuntu package `bat` under the executable name `batcat`, while
# other distributions commonly provide it as `bat`.
#
# If `bat` does not already exist but `batcat` does, provide the conventional
# `bat` command as an alias. This keeps the same command usable across Linux
# distributions without overriding a native `bat` executable.
if ! command -v bat >/dev/null 2>&1 \
    && command -v batcat >/dev/null 2>&1
then
    alias bat='batcat'
fi


# =============================================================================
# C/C++ source inspection
# =============================================================================

# List classes and functions found in C++ source files using Universal Ctags.
#
# Usage:
#
#     cppsymbols file.cpp
#     cppsymbols include/foo.hpp src/foo.cpp
#     cppsymbols src/
#
# When a directory is supplied, ctags searches it recursively.
#
# The output is printed as a human-readable cross-reference rather than
# creating a persistent `tags` file.
#
# This requires Universal Ctags to be installed and available as `ctags`.
cppsymbols()
{
    # Make the failure explicit rather than producing a confusing shell error
    # if ctags is not installed.
    if ! command -v ctags >/dev/null 2>&1; then
        printf 'cppsymbols: ctags is not installed\n' >&2
        return 127
    fi

    # At least one file or directory must be supplied.
    if (( $# == 0 )); then
        printf 'Usage: cppsymbols <file-or-directory> [...]\n' >&2
        return 2
    fi

    ctags \
        --languages=C++ \
        --kinds-C++=cf \
        --output-format=xref \
        --sort=yes \
        --recurse=yes \
        "$@"
}


# =============================================================================
# Machine-specific configuration
# =============================================================================

# Load settings that should not be stored in the public dotfiles repository.
#
# ~/.bashrc.local can contain:
#
#   - machine-specific PATH entries
#   - private environment variables
#   - work-related aliases
#   - hardware-specific settings
#   - other local configuration
#
# For example, the Raspberry Pi's manually installed Neovim can be configured
# there with:
#
#     export PATH="/opt/nvim-linux-arm64/bin:$PATH"
#
# Keeping such paths outside the tracked .bashrc makes this file portable
# between different Linux machines.
if [[ -f "$HOME/.bashrc.local" ]]; then
    source "$HOME/.bashrc.local"
fi


# =============================================================================
# tmux over SSH
# =============================================================================

# Automatically attach to the most recently active tmux session when logging in
# through SSH.
#
# This only runs when:
#
#   - The shell was started through SSH.
#   - tmux is installed.
#   - We are not already inside a tmux session.
#
# If one or more tmux sessions already exist, the session with the most recent
# activity is selected and attached.
#
# If no tmux session exists, a new one is created.
#
# `exec` replaces the current Bash process with tmux. When the tmux session is
# eventually exited, the SSH connection therefore closes rather than leaving
# an additional Bash shell behind.
if [[ -n "$SSH_CONNECTION" ]] \
    && [[ -z "$TMUX" ]] \
    && command -v tmux >/dev/null 2>&1
then
    # Find the most recently active tmux session.
    #
    # `session_activity` is a timestamp maintained by tmux.
    # `sort -nr` orders sessions from newest to oldest.
    # `head -n 1` selects the most recently active session.
    last_session="$(
        tmux list-sessions -F '#{session_activity} #{session_name}' 2>/dev/null \
            | sort -nr \
            | head -n 1 \
            | cut -d' ' -f2-
    )"

    if [[ -n "$last_session" ]]; then
        # Reattach to the most recently active existing session.
        exec tmux attach-session -t "$last_session"
    else
        # No tmux server/session exists yet, so create a new session.
        exec tmux new-session
    fi
fi
