# =============================================================================
# C/C++ source inspection
# =============================================================================

# List classes and functions found in C++ source files using Universal Ctags.
#
# Usage:
#
#     cppsymbols [--by-name|--by-location] file.cpp
#     cppsymbols [--by-name|--by-location] include/foo.hpp src/foo.cpp
#     cppsymbols [--by-name|--by-location] src/
#
# By default, symbols are sorted alphabetically by symbol name.
#
# Sorting options:
#
#     --by-name       Sort by symbol name, then file and line number.
#     --by-location   Sort by file name, then line number and symbol name.
#
# When a directory is supplied, Ctags searches it recursively.
#
# The output is generated from Universal Ctags' JSON format and rendered as a
# human-readable, colorized list. No persistent `tags` file is created.
#
# Required tools:
#
#     ctags    Universal Ctags
#     jq       JSON parsing and formatting
#
# Convenience wrappers:
#
#     cppsyms      Sort by symbol name and page the output.
#     cppsymsloc   Sort by file location and page the output.


cppsymbols()
{
    # -------------------------------------------------------------------------
    # Dependencies
    # -------------------------------------------------------------------------

    # Universal Ctags performs the actual C++ source-code analysis.
    if ! command -v ctags >/dev/null 2>&1; then
        printf 'cppsymbols: Universal Ctags is not installed or not in PATH\n' >&2
        return 127
    fi

    # jq parses and sorts the JSON records emitted by Universal Ctags.
    if ! command -v jq >/dev/null 2>&1; then
        printf 'cppsymbols: jq is not installed or not in PATH\n' >&2
        return 127
    fi


    # -------------------------------------------------------------------------
    # Options
    # -------------------------------------------------------------------------

    # Sort alphabetically by symbol name unless another order is explicitly
    # requested.
    local sort_mode="name"

    case "${1:-}" in
        --by-name)
            sort_mode="name"
            shift
            ;;

        --by-location)
            sort_mode="location"
            shift
            ;;

        --help|-h)
            cat <<'EOF'
Usage:
  cppsymbols [--by-name|--by-location] <file-or-directory> [...]

Options:
  --by-name       Sort by symbol name (default)
  --by-location   Sort by file name, then line number
  -h, --help      Show this help

Examples:
  cppsymbols file.cpp
  cppsymbols src/
  cppsymbols --by-location include/ src/

Shortcuts:
  cppsyms         Sort by name and page with less
  cppsymsloc      Sort by location and page with less
EOF
            return 0
            ;;

        --*)
            printf 'cppsymbols: unknown option: %s\n' "$1" >&2
            printf 'Try "cppsymbols --help" for usage information.\n' >&2
            return 2
            ;;
    esac


    # -------------------------------------------------------------------------
    # Arguments
    # -------------------------------------------------------------------------

    # At least one source file or directory must be supplied.
    if (( $# == 0 )); then
        printf 'cppsymbols: no file or directory specified\n' >&2
        printf 'Try "cppsymbols --help" for usage information.\n' >&2
        return 2
    fi


    # -------------------------------------------------------------------------
    # Symbol extraction and formatting
    # -------------------------------------------------------------------------

    # Ask Universal Ctags to:
    #
    #   - interpret all supplied input as C++
    #   - emit only classes and functions/methods
    #   - include line numbers
    #   - recurse into directory arguments
    #   - emit JSON to standard output
    #
    # jq then:
    #
    #   - collects the JSON stream into an array
    #   - ignores non-tag metadata records
    #   - applies the requested deterministic sort order
    #   - renders classes and functions with distinct ANSI colors
    #
    # Sorting includes secondary fields so overloaded or same-named symbols
    # always appear in a predictable order.
    ctags \
        --language-force=C++ \
        --kinds-C++=cf \
        --output-format=json \
        --fields=+n \
        --recurse=yes \
        "$@" |
    jq -r -s --arg sort_mode "$sort_mode" '
        map(select(._type == "tag"))
        |
        if $sort_mode == "name" then
            sort_by(.name, .path, .line)
        else
            sort_by(.path, .line, .name)
        end
        |
        .[]
        |
        if .kind == "class" then
            "\u001b[1;35mCLASS\u001b[0m    "
            + "\u001b[1m\(.name)\u001b[0m    "
            + "\u001b[2m\(.path):\(.line)\u001b[0m"
        else
            "\u001b[1;36mFUNCTION\u001b[0m "
            + "\u001b[1m\(.name)\u001b[0m    "
            + "\u001b[2m\(.path):\(.line)\u001b[0m"
        end
    '
}


# =============================================================================
# Convenience wrappers
# =============================================================================

# Sort C++ symbols alphabetically by symbol name and display them in `less`.
#
# `-R` tells less to preserve ANSI color sequences while paging.
cppsyms()
{
    cppsymbols --by-name "$@" | less -R

    # In a pipeline Bash normally returns the status of the last command.
    # Return cppsymbols' status instead so missing dependencies, bad arguments,
    # or Ctags failures remain visible to callers.
    return "${PIPESTATUS[0]}"
}


# Sort C++ symbols by file name and line number and display them in `less`.
cppsymsloc()
{
    cppsymbols --by-location "$@" | less -R

    return "${PIPESTATUS[0]}"
}
