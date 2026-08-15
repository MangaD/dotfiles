# =============================================================================
# General behavior
# =============================================================================

# Disable GDB's built-in output pager.
#
# Normally, long output may pause with a prompt such as:
#
#     --Type <RET> for more, q to quit, c to continue without paging--
#
# Terminal environments such as tmux already provide scrollback, so allowing
# output to flow normally is generally more convenient.
set pagination off

# Do not display commands as GDB executes command files or user-defined
# commands.
#
# This keeps normal debugger sessions quieter. It can be enabled temporarily
# when debugging GDB configuration or command files.
set trace-commands off


# =============================================================================
# Output formatting
# =============================================================================

# Pretty-print structures, classes, arrays, and other compound values using
# multiple indented lines where appropriate.
#
# This generally makes complex C and C++ objects easier to inspect.
set print pretty on

# Display array indexes when printing array elements.
set print array-indexes on

# Use the actual derived type when printing C++ polymorphic objects when GDB
# can determine it.
set print object on

# Demangle C++ symbol names in normal debugger output.
set print demangle on

# Demangle C++ symbol names when displaying assembly instructions.
set print asm-demangle on


# =============================================================================
# Assembly
# =============================================================================

# Optional: use Intel assembly syntax instead of GDB's default AT&T syntax.
#
# Intel syntax is commonly written as:
#
#     instruction destination, source
#
# while AT&T syntax generally uses:
#
#     instruction source, destination
#
# Uncomment this setting if Intel syntax is preferred.
#set disassembly-flavor intel


# =============================================================================
# Source display
# =============================================================================

# Display ten source lines when using commands such as `list`.
set listsize 10


# =============================================================================
# Command history
# =============================================================================

# Preserve GDB command history between debugger sessions.
set history save on

# Store persistent command history in a dedicated file in the home directory.
set history filename ~/.gdb_history

# Keep up to 10,000 commands in GDB's history.
set history size 10000


# =============================================================================
# Confirmation
# =============================================================================

# Keep confirmation prompts enabled for operations where GDB would normally
# request confirmation.
#
# This provides protection against accidentally discarding debugger state or
# terminating a running program.
set confirm on
