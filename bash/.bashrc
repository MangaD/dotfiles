# =============================================================================
# Interactive shell
# =============================================================================

# Stop processing this file when Bash is not running interactively.
#
# .bashrc is intended for interactive shell configuration. This prevents
# prompts, aliases, and other interactive settings from affecting scripts or
# non-interactive Bash sessions.
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
# The leading-space behavior only works when `ignorespace` is enabled through
# `ignoreboth`, as configured here.
HISTCONTROL=ignoreboth

# Append to the history file instead of overwriting it when the shell exits.
#
# This is useful when several terminal sessions are open at the same time.
shopt -s histappend


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
# Tool compatibility
# =============================================================================

# Debian and Ubuntu package `bat` under the executable name `batcat`, while
# other distributions commonly provide it as `bat`.
#
# If `bat` does not already exist but `batcat` does, provide the conventional
# `bat` command as an alias. This keeps the same command usable across Linux
# distributions without overriding a native `bat` executable.
if ! command -v bat >/dev/null 2>&1 && command -v batcat >/dev/null 2>&1; then
    alias bat='batcat'
fi


# =============================================================================
# Machine-specific configuration
# =============================================================================

# Load settings that should not be stored in the public dotfiles repository.
#
# ~/.bashrc.local can contain machine-specific paths, private environment
# variables, work-related aliases, or other local configuration.
if [[ -f ~/.bashrc.local ]]; then
    source ~/.bashrc.local
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