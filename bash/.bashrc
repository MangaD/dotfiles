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
# Machine-specific configuration
# =============================================================================

# Load settings that should not be stored in the public dotfiles repository.
#
# ~/.bashrc.local can contain machine-specific paths, private environment
# variables, work-related aliases, or other local configuration.
if [[ -f ~/.bashrc.local ]]; then
    source ~/.bashrc.local
fi
