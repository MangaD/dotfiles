# Personal Commands

This package contains personal command-line utilities installed under `~/.local/bin/`.

The package is managed with [GNU Stow](https://www.gnu.org/software/stow/) and currently provides `bz`, a small terminal client for Bugzilla's REST API.

## Contents

```text
bin/
├── .stow-local-ignore
├── .local/
│   └── bin/
│       └── bz
└── README.md
```

When the package is installed with Stow:

```text
bin/.local/bin/bz → ~/.local/bin/bz
```

The repository's Bash configuration adds `~/.local/bin` to `PATH` when that directory exists, allowing the command to be invoked directly as `bz`.

## Installation

From the root of the dotfiles repository:

```bash
stow --no-folding bin
```

Verify that the command is available:

```bash
command -v bz
bz --version
```

The package's `README.md` is repository documentation and is excluded from Stow through `.stow-local-ignore`.

## `bz`

`bz` is a small Bash command-line client for Bugzilla's REST API.

It provides commands for:

* Displaying bug details
* Displaying bug comments
* Displaying bug change history
* Searching for bugs
* Printing the web URL for a bug

## Requirements

API operations require:

* Bash 4 or later
* `curl`
* `jq`

On Debian and Ubuntu:

```bash
sudo apt install curl jq
```

`bz help` and `bz version` do not require Bugzilla configuration or network access.

`bz url` requires a configured Bugzilla base URL but does not contact the server.

## Configuration

`bz` reads its configuration from:

```text
~/.config/bz/config
```

Create the configuration directory and file with:

```bash
mkdir -p ~/.config/bz
$EDITOR ~/.config/bz/config
```

A minimal configuration contains the Bugzilla base URL:

```bash
BASE_URL="https://bugs.example.com"
```

A trailing `/` is optional; `bz` removes it when loading the configuration.

For a Bugzilla instance requiring authentication, an API key can also be configured:

```bash
BASE_URL="https://bugs.example.com"
API_KEY="your-api-key"
```

### Credentials

The configuration file may contain an API key and must not be committed to this dotfiles repository.

It intentionally remains outside the `bin` Stow package.

When the file contains credentials, restrict its permissions:

```bash
chmod 600 ~/.config/bz/config
```

The configuration file is sourced as Bash code, so it should only be writable by trusted users.

## Environment Variables

The following variables are supported:

```text
BASE_URL    Bugzilla base URL
API_KEY     Optional Bugzilla API key
COLOR       Output formatting: auto, always, or never
NO_COLOR    Disable formatting when non-empty
```

Values supplied through the environment can be used without placing them in the configuration file:

```bash
BASE_URL="https://bugs.example.com" bz 77165
```

The configuration file may also set these variables.

### Color and Terminal Formatting

The default color mode is:

```bash
COLOR="auto"
```

The supported values are:

```text
auto      Enable terminal formatting when stdout is a terminal
always    Always emit terminal formatting
never     Never emit terminal formatting
```

Although the setting is named `COLOR`, the current output primarily uses ANSI formatting for bold headings.

With `COLOR="auto"`, formatting is disabled when output is piped or redirected because stdout is no longer a terminal.

For example:

```bash
bz comments 77165 | less -R
```

will not preserve bold headings when `COLOR="auto"` is used.

If `bz` is normally used interactively or through `less -R`, the configuration can instead contain:

```bash
COLOR="always"
```

Then formatting is preserved through the pager:

```bash
bz 77165 | less -R
bz comments 77165 | less -R
bz history 77165 | less -R
```

The `-R` option tells `less` to display ANSI color and formatting sequences.

When `COLOR="always"` is configured, redirected output will also contain those sequences. Disable formatting when plain-text output is required:

```bash
COLOR=never bz 77165 > bug.txt
```

or:

```bash
NO_COLOR=1 bz 77165 > bug.txt
```

`NO_COLOR` overrides the configured `COLOR` value whenever it is non-empty.

## Usage

General syntax:

```text
bz BUG
bz comments BUG
bz history BUG
bz search [OPTIONS] [TEXT]
bz url BUG
bz version
bz help
```

Display the built-in help with:

```bash
bz help
```

or:

```bash
bz --help
```

## Displaying a Bug

Pass a numeric Bugzilla bug ID directly:

```bash
bz 77165
```

The output includes available information such as:

* Status and resolution
* Alias
* Product and component
* Classification and version
* Platform and operating system
* Priority and severity
* Assignee
* Reporter
* QA contact
* CC list
* Dependencies and blocked bugs
* Duplicate information
* Related URLs
* Keywords
* Whiteboard
* Target milestone
* Deadline
* Time-tracking information when available
* Flags
* Creation and modification timestamps
* Description

Time-tracking fields are displayed only when Bugzilla returns them. Their availability may depend on the permissions of the authenticated user.

Bug IDs must consist entirely of decimal digits.

For example:

```bash
bz 77165
```

is valid, while:

```text
bz 77165abc
```

is rejected as an invalid bug ID.

## Comments

Display the comments for a bug with:

```bash
bz comments 77165
```

Each comment contains a bold heading with its comment number, author, and timestamp, followed by the comment text:

```text
#1  user@example.com  2026-08-20T12:30:00Z

Comment text...

────────────────────────────────────────────────────────────
```

Multiline comment text is preserved.

Private comments are marked with:

```text
[PRIVATE]
```

Whether private comments are returned depends on the permissions associated with the configured Bugzilla API key.

For paged output while preserving formatting:

```bash
bz comments 77165 | less -R
```

This requires `COLOR="always"` or an equivalent per-command override:

```bash
COLOR=always bz comments 77165 | less -R
```

## History

Display the change history for a bug with:

```bash
bz history 77165
```

Each history entry contains a bold heading with the timestamp and user, followed by the fields that changed:

```text
2026-08-20T12:30:00Z  user@example.com
  status: NEW -> ASSIGNED
  assigned_to: old@example.com -> new@example.com
```

For paged output while preserving formatting:

```bash
bz history 77165 | less -R
```

As with comments, this requires formatting to remain enabled through the pipe.

## Search

Search Bugzilla with:

```text
bz search [OPTIONS] [TEXT]
```

A simple summary search:

```bash
bz search firefox
```

Quote searches containing spaces:

```bash
bz search "network error"
```

Only one search-text argument is accepted. Unquoted multiword searches are rejected rather than silently discarding arguments.

For example, use:

```bash
bz search "network connection failure"
```

rather than:

```text
bz search network connection failure
```

### Search Options

The following filters are supported:

```text
--status STATUS
--product PRODUCT
--component COMPONENT
--priority PRIORITY
--severity SEVERITY
--version VERSION
--platform PLATFORM
--os OS
--assignee EMAIL
--limit N
```

The default result limit is 50.

`--limit` must be a positive integer.

Display search-specific help with:

```bash
bz search --help
```

### Search Examples

Search by status:

```bash
bz search --status NEW
```

Search by product:

```bash
bz search --product Firefox
```

Search by product and component:

```bash
bz search --product Firefox --component General
```

Search by priority:

```bash
bz search --priority P1
```

Search by severity:

```bash
bz search --severity critical
```

Search by version:

```bash
bz search --version 1.0
```

Search by platform:

```bash
bz search --platform ARM
```

Search by operating system:

```bash
bz search --os Linux
```

Search by assignee:

```bash
bz search --assignee user@example.com
```

Combine filters:

```bash
bz search --status NEW --product Firefox --component General
```

Combine text and filters:

```bash
bz search --status NEW --product Firefox "network error"
```

Limit the number of results:

```bash
bz search --limit 20 firefox
```

## Bug URL

Print the normal Bugzilla web URL for a bug:

```bash
bz url 77165
```

For a configured base URL of:

```text
https://bugs.example.com
```

the command prints:

```text
https://bugs.example.com/show_bug.cgi?id=77165
```

This command does not contact the Bugzilla server and therefore does not require `curl` or `jq`.

It does require `BASE_URL` to be configured.

## Version

Display the installed version with:

```bash
bz version
```

or:

```bash
bz --version
```

The version command does not require Bugzilla configuration, `curl`, `jq`, or network access.

## Error Handling

`bz` checks for several common errors before or while performing a request.

These include:

* Missing `curl` or `jq`
* Missing `BASE_URL`
* Invalid Bugzilla base URLs
* Invalid bug IDs
* Invalid `COLOR` values
* Invalid search options
* Invalid `--limit` values
* Network failures
* HTTP errors
* Bugzilla API errors
* Invalid JSON returned by the server

When Bugzilla returns a structured API error, `bz` attempts to display the Bugzilla error code and message rather than replacing it with a generic HTTP failure.

## API Access

`bz` communicates with the configured Bugzilla instance through its REST API under:

```text
BASE_URL/rest/
```

The commands use the following API resources:

```text
bz BUG          /rest/bug/BUG
bz comments     /rest/bug/BUG/comment
bz history      /rest/bug/BUG/history
bz search       /rest/bug
```

When `API_KEY` is configured, it is supplied to Bugzilla as the `api_key` request parameter.

The fields and bugs available to `bz` depend on the Bugzilla instance and the permissions associated with the configured API key.

## Removing the Package

Remove the managed symbolic links without deleting files from the repository:

```bash
stow --delete --no-folding bin
```

Recreate the links after changing the package structure:

```bash
stow --restow --no-folding bin
```

## Adding Commands

Additional personal commands can be added under:

```text
bin/.local/bin/
```

For example:

```text
bin/
└── .local/
    └── bin/
        ├── bz
        └── example
```

Make executable scripts executable before committing them:

```bash
chmod +x bin/.local/bin/example
```

Restow the package if necessary:

```bash
stow --restow --no-folding bin
```

Commands in this package should be portable across the machines managed by this dotfiles repository.

Machine-specific scripts, configuration, credentials, API keys, and other secrets should remain outside the tracked package.
