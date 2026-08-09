# =============================================================================
# Bash login shell
# =============================================================================

# This file is read by Bash login shells.
#
# SSH sessions commonly start a login shell, so login-specific initialization
# and the system-information banner are handled here.
#
# Normal interactive shell configuration remains in ~/.bashrc and is sourced
# at the end of this file.
#
# The banner is generated only for interactive shells so that non-interactive
# uses of SSH, such as remote commands, are not polluted with extra output.


if [[ $- == *i* ]]; then

    # =========================================================================
    # Operating system
    # =========================================================================

    # Read the distribution name from /etc/os-release.
    #
    # PRETTY_NAME normally produces a value such as:
    #
    #     Debian GNU/Linux 13 (trixie)
    #
    # Fall back to uname if /etc/os-release is unavailable.
    if [[ -r /etc/os-release ]]; then
        . /etc/os-release
        os_name=${PRETTY_NAME:-${NAME:-Linux}}
    else
        os_name=$(uname -s)
    fi


    # =============================================================================
    # Shell
    # =============================================================================

    # Determine the shell process currently executing this login environment.
    #
    # `$SHELL` contains the user's configured login shell, but it does not
    # necessarily identify the shell that is currently running. Instead, inspect
    # the current process using `ps`.
    shell_name=$(
        ps -p $$ -o comm= 2>/dev/null
    )

    # Remove a possible leading "-" used to identify login shells.
    shell_name=${shell_name#-}

    # Fall back to the configured login shell if the current process could not be
    # determined.
    if [[ -z "$shell_name" ]]; then
        shell_name=${SHELL##*/}
    fi

    if [[ -z "$shell_name" ]]; then
        shell_name="unknown"
    fi


    # -----------------------------------------------------------------------------
    # Shell version
    # -----------------------------------------------------------------------------

    # Obtain the version from the shell that is actually running.
    #
    # Use shell-specific variables where available because they avoid spawning
    # another shell merely to determine its version.
    case "$shell_name" in
        bash)
            shell_version=${BASH_VERSION:-}
            ;;

        zsh)
            shell_version=${ZSH_VERSION:-}
            ;;

        ksh|ksh93|mksh)
            shell_version=${KSH_VERSION:-}
            ;;

        fish)
            shell_version=$(
                fish --version 2>/dev/null \
                    | awk '{print $NF}'
            )
            ;;

        *)
            # For other shells, try the conventional --version option and extract
            # the first line. Not every shell supports this, so failure is harmless.
            shell_version=$(
                "$shell_name" --version 2>/dev/null \
                    | head -n 1
            )
            ;;
    esac


    # Remove common build/platform information appended in parentheses.
    #
    # For example:
    #
    #     5.2.37(1)-release
    #
    # becomes:
    #
    #     5.2.37
    if [[ "$shell_name" == "bash" && -n "$shell_version" ]]; then
        shell_version=${shell_version%%(*}
    fi


    # Build the value displayed in the diagnostics.
    #
    # Examples:
    #
    #     bash 5.2.37
    #     zsh 5.9
    #     fish 4.0.2
    #
    # If the version cannot be determined, display only the shell name.
    if [[ -n "$shell_version" ]]; then
        shell_display="${shell_name} ${shell_version}"
    else
        shell_display="$shell_name"
    fi


    # =============================================================================
    # CPU
    # =============================================================================

    # Read CPU vendor and model from lscpu.
    #
    # On a Raspberry Pi 4 this should normally produce values similar to:
    #
    #     Vendor ID:     ARM
    #     Model name:    Cortex-A72
    cpu_vendor=$(
        lscpu 2>/dev/null \
            | awk -F ':' '
                /^Vendor ID:/ {
                    gsub(/^[ \t]+/, "", $2)
                    print $2
                    exit
                }
            '
    )

    cpu_model=$(
        lscpu 2>/dev/null \
            | awk -F ':' '
                /^Model name:/ {
                    gsub(/^[ \t]+/, "", $2)
                    print $2
                    exit
                }
            '
    )

    if [[ -z "$cpu_vendor" ]]; then
        cpu_vendor="ARM"
    fi

    # Some Raspberry Pi kernels do not expose a useful model name. Fall back to
    # the known CPU core when the machine identifies itself as a Raspberry Pi 4.
    if [[ -z "$cpu_model" || "$cpu_model" == "-" ]]; then
        device_model=""

        if [[ -r /proc/device-tree/model ]]; then
            device_model=$(
                tr -d '\0' < /proc/device-tree/model
            )
        fi

        case "$device_model" in
            *"Raspberry Pi 4"*)
                cpu_model="Cortex-A72"
                ;;
            *)
                cpu_model="N/A"
                ;;
        esac
    fi


    # Count logical CPU cores.
    if command -v nproc >/dev/null 2>&1; then
        cpu_cores=$(nproc)
    else
        cpu_cores=$(
            grep -c '^processor' /proc/cpuinfo 2>/dev/null
        )
    fi

    if [[ -z "$cpu_cores" || "$cpu_cores" == "0" ]]; then
        cpu_cores="N/A"
    fi


    # Use the maximum configured CPU frequency rather than the instantaneous
    # frequency, which may drop substantially while the Pi is idle.
    cpu_max_khz=""

    if [[ -r /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq ]]; then
        cpu_max_khz=$(
            cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq
        )
    elif [[ -r /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq ]]; then
        cpu_max_khz=$(
            cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
        )
    fi

    if [[ "$cpu_max_khz" =~ ^[0-9]+$ ]]; then
        cpu_ghz=$(
            awk -v khz="$cpu_max_khz" 'BEGIN {
                printf "%.1f", khz / 1000000
            }'
        )
    else
        cpu_ghz="N/A"
    fi


    # Build a compact Screenfetch-style CPU description.
    #
    # Example:
    #
    #     ARM Cortex-A72 @ 4x 1.5GHz
    cpu_name="${cpu_vendor} ${cpu_model}"

    if [[ "$cpu_cores" != "N/A" && "$cpu_ghz" != "N/A" ]]; then
        cpu_display="${cpu_name} @ ${cpu_cores}x ${cpu_ghz}GHz"
    elif [[ "$cpu_cores" != "N/A" ]]; then
        cpu_display="${cpu_name} @ ${cpu_cores} cores"
    else
        cpu_display="$cpu_name"
    fi


    # =========================================================================
    # Installed packages
    # =========================================================================

    # Count packages installed through Debian's package database.
    #
    # This corresponds closely to the package count displayed by tools such as
    # Screenfetch on Debian/Raspberry Pi OS.
    if command -v dpkg-query >/dev/null 2>&1; then
        package_count=$(
            dpkg-query \
                -W \
                -f='${db:Status-Abbrev}\n' \
                2>/dev/null \
                | grep -c '^ii '
        )
    else
        package_count="N/A"
    fi


    # =========================================================================
    # Uptime
    # =========================================================================

    # /proc/uptime contains the number of seconds the system has been running.
    # Discard the fractional part and convert the total into days, hours,
    # minutes, and seconds.
    read -r uptime_seconds _ < /proc/uptime

    up_seconds=${uptime_seconds%.*}

    secs=$((up_seconds % 60))
    mins=$((up_seconds / 60 % 60))
    hours=$((up_seconds / 3600 % 24))
    days=$((up_seconds / 86400))

    uptime_text=$(
        printf "%d days, %02dh%02dm%02ds" \
            "$days" "$hours" "$mins" "$secs"
    )


    # =============================================================================
    # Memory
    # =============================================================================

    # Read total and available memory from /proc/meminfo.
    #
    # Linux uses spare RAM for caches, so MemAvailable is more meaningful than
    # MemFree when estimating how much memory applications can still use.
    #
    # Used memory is calculated as:
    #
    #     total - available
    #
    # Values in /proc/meminfo are KiB and are converted to GiB.
    read -r total_mem_kib available_mem_kib < <(
        awk '
            /^MemTotal:/ {
                total = $2
            }

            /^MemAvailable:/ {
                available = $2
            }

            END {
                print total, available
            }
        ' /proc/meminfo
    )

    if [[ "$total_mem_kib" =~ ^[0-9]+$ \
        && "$available_mem_kib" =~ ^[0-9]+$ ]]
    then
        used_mem_kib=$((total_mem_kib - available_mem_kib))

        used_mem=$(
            awk -v kib="$used_mem_kib" 'BEGIN {
                printf "%.2f GB", kib / 1024 / 1024
            }'
        )

        available_mem=$(
            awk -v kib="$available_mem_kib" 'BEGIN {
                printf "%.2f GB", kib / 1024 / 1024
            }'
        )

        total_mem=$(
            awk -v kib="$total_mem_kib" 'BEGIN {
                printf "%.2f GB", kib / 1024 / 1024
            }'
        )
    else
        used_mem="N/A"
        available_mem="N/A"
        total_mem="N/A"
    fi


    # =========================================================================
    # Disk usage
    # =========================================================================

    # Show usage of the root filesystem.
    #
    # Example:
    #
    #     18G / 29G (63%)
    disk_usage=$(
        df -h / 2>/dev/null \
            | awk 'NR == 2 {
                print $3 " / " $2 " (" $5 ")"
            }'
    )

    if [[ -z "$disk_usage" ]]; then
        disk_usage="N/A"
    fi


    # =========================================================================
    # CPU temperature
    # =========================================================================

    # vcgencmd is provided by Raspberry Pi OS and can report the SoC
    # temperature.
    #
    # If the command is unavailable, display N/A rather than producing an error
    # during login.
    if command -v vcgencmd >/dev/null 2>&1; then
        cpu_temp=$(
            vcgencmd measure_temp 2>/dev/null \
                | sed -En 's/temp=(.*)/\1/p'
        )

        if [[ -z "$cpu_temp" ]]; then
            cpu_temp="N/A"
        fi
    else
        cpu_temp="N/A"
    fi


    # =========================================================================
    # Raspberry Pi throttling status
    # =========================================================================

    # Raspberry Pi firmware records current and historical power/thermal
    # throttling conditions as a bitmask returned by:
    #
    #     vcgencmd get_throttled
    #
    # Important bits include:
    #
    #      0    Under-voltage currently detected
    #      1    ARM frequency currently capped
    #      2    System currently throttled
    #      3    Soft temperature limit currently active
    #
    #     16    Under-voltage has occurred since boot
    #     17    ARM frequency capping has occurred since boot
    #     18    Throttling has occurred since boot
    #     19    Soft temperature limit has occurred since boot
    #
    # A value of 0x0 means that none of these conditions are present.
    if command -v vcgencmd >/dev/null 2>&1; then
        throttled_raw=$(
            vcgencmd get_throttled 2>/dev/null \
                | cut -d= -f2
        )

        if [[ "$throttled_raw" =~ ^0x[0-9A-Fa-f]+$ ]]; then
            throttled_value=$((throttled_raw))

            if (( throttled_value == 0 )); then
                throttled_status="OK (0x0)"
            else
                throttled_messages=()

                if (( throttled_value & (1 << 0) )); then
                    throttled_messages+=("Under-voltage detected")
                fi

                if (( throttled_value & (1 << 1) )); then
                    throttled_messages+=("CPU frequency capped")
                fi

                if (( throttled_value & (1 << 2) )); then
                    throttled_messages+=("Currently throttled")
                fi

                if (( throttled_value & (1 << 3) )); then
                    throttled_messages+=("Temperature limit active")
                fi

                if (( throttled_value & (1 << 16) )); then
                    throttled_messages+=("Under-voltage has occurred")
                fi

                if (( throttled_value & (1 << 17) )); then
                    throttled_messages+=(
                        "CPU frequency capping has occurred"
                    )
                fi

                if (( throttled_value & (1 << 18) )); then
                    throttled_messages+=("Throttling has occurred")
                fi

                if (( throttled_value & (1 << 19) )); then
                    throttled_messages+=(
                        "Temperature limiting has occurred"
                    )
                fi

                throttled_status=$(
                    IFS=", "
                    echo "${throttled_messages[*]} ($throttled_raw)"
                )
            fi
        else
            throttled_status="N/A"
        fi
    else
        throttled_status="N/A"
    fi


    # =========================================================================
    # Load averages
    # =========================================================================

    # /proc/loadavg contains the 1, 5, and 15 minute system load averages.
    read -r load_one load_five load_fifteen _ < /proc/loadavg


    # =========================================================================
    # Running processes
    # =========================================================================

    # Count currently running process entries.
    process_count=$(
        ps -e --no-headers 2>/dev/null \
            | wc -l
    )

    process_count=${process_count//[[:space:]]/}

    if [[ -z "$process_count" ]]; then
        process_count="N/A"
    fi


    # =========================================================================
    # Network information
    # =========================================================================


    # -------------------------------------------------------------------------
    # Wi-Fi IP address
    # -------------------------------------------------------------------------

    # Obtain the IPv4 address assigned specifically to wlan0.
    #
    # If Wi-Fi is disconnected or the interface does not exist, display N/A.
    wifi_ip=$(
        ip -4 -o addr show dev wlan0 2>/dev/null \
            | awk '{print $4}' \
            | cut -d/ -f1 \
            | head -n 1
    )

    if [[ -z "$wifi_ip" ]]; then
        wifi_ip="N/A"
    fi


    # -------------------------------------------------------------------------
    # Ethernet IP address
    # -------------------------------------------------------------------------

    # Obtain the IPv4 address assigned specifically to eth0.
    #
    # If Ethernet is disconnected or the interface does not exist, display N/A.
    ethernet_ip=$(
        ip -4 -o addr show dev eth0 2>/dev/null \
            | awk '{print $4}' \
            | cut -d/ -f1 \
            | head -n 1
    )

    if [[ -z "$ethernet_ip" ]]; then
        ethernet_ip="N/A"
    fi


    # -------------------------------------------------------------------------
    # Public IP address
    # -------------------------------------------------------------------------

    # Retrieve the public IPv4 address seen by the Internet.
    #
    # External network requests must never significantly delay login, so use a
    # short connection timeout and overall timeout. Failure is harmless.
    if command -v curl >/dev/null 2>&1; then
        public_ip=$(
            curl \
                --silent \
                --fail \
                --ipv4 \
                --connect-timeout 1 \
                --max-time 2 \
                https://ipecho.net/plain \
                2>/dev/null
        )
    else
        public_ip=""
    fi

    if [[ -z "$public_ip" ]]; then
        public_ip="N/A"
    fi


    # =========================================================================
    # Weather
    # =========================================================================

    # Retrieve a compact current-weather summary for Lisbon using wttr.in.
    #
    # The one-line format produces output similar to:
    #
    #     Lisbon: ☀️ +24°C
    #
    # `m` requests metric units.
    #
    # Weather is purely informational, so failure must never interfere with or
    # noticeably delay an SSH login.
    if command -v curl >/dev/null 2>&1; then
        weather=$(
            curl \
                --silent \
                --fail \
                --connect-timeout 1 \
                --max-time 2 \
                "https://wttr.in/Lisbon?m&format=%l:+%c+%t" \
                2>/dev/null
        )
    else
        weather=""
    fi

    if [[ -z "$weather" ]]; then
        weather="N/A"
    fi


    # =========================================================================
    # Available package updates
    # =========================================================================

    # Ask APT to simulate a distribution upgrade and count packages that would
    # be installed or upgraded.
    #
    # This command does not modify the system. Its result depends on the local
    # APT package lists, so run `sudo apt update` periodically to keep the count
    # current.
    if command -v apt-get >/dev/null 2>&1; then
        count_updates=$(
            apt-get -s dist-upgrade 2>/dev/null \
                | grep -c "^Inst"
        )
    else
        count_updates="N/A"
    fi


    # =========================================================================
    # Terminal formatting
    # =========================================================================

    # Use terminal colors only when tput is available and the terminal supports
    # them. Falling back to empty strings keeps the banner readable in simpler
    # terminal environments.
    if command -v tput >/dev/null 2>&1 \
        && [[ ${TERM:-dumb} != "dumb" ]]
    then
        reset=$(tput sgr0 2>/dev/null || true)
        bold=$(tput bold 2>/dev/null || true)

        red=$(tput setaf 1 2>/dev/null || true)
        green=$(tput setaf 2 2>/dev/null || true)
        yellow=$(tput setaf 3 2>/dev/null || true)
        magenta=$(tput setaf 5 2>/dev/null || true)
        cyan=$(tput setaf 6 2>/dev/null || true)
    else
        reset=""
        bold=""

        red=""
        green=""
        yellow=""
        magenta=""
        cyan=""
    fi


    # =========================================================================
    # Status colors
    # =========================================================================

    # Use color to communicate status rather than decorating every value:
    #
    #     green     healthy / normal
    #     yellow    something deserves attention
    #     red       a problem is present


    # -------------------------------------------------------------------------
    # Throttling
    # -------------------------------------------------------------------------

    if [[ "$throttled_status" == "OK (0x0)" ]]; then
        throttled_color="$green"
    else
        throttled_color="$red"
    fi


    # -------------------------------------------------------------------------
    # Package updates
    # -------------------------------------------------------------------------

    if [[ "$count_updates" =~ ^[0-9]+$ ]]; then
        if (( count_updates == 0 )); then
            updates_color="$green"
        else
            updates_color="$yellow"
        fi
    else
        updates_color="$reset"
    fi


    # =========================================================================
    # Machine heading
    # =========================================================================

    # Display the machine name as the main decorative heading.
    #
    # figlet provides the large text and lolcat adds color when both programs
    # are installed.
    if command -v figlet >/dev/null 2>&1; then
        if command -v lolcat >/dev/null 2>&1; then
            figlet "MangaD PI4" | lolcat
        else
            figlet "MangaD PI4"
        fi

        printf '\n'
    fi


    # =========================================================================
    # Diagnostic information
    # =========================================================================

    # Build the diagnostic panel as an array of lines.
    #
    # The panel is printed beside Screenfetch's Raspberry Pi logo below.
    diagnostics=(
        "${bold}${cyan}$(date +"%A, %e %B %Y, %r")${reset}"
        ""
        "${bold}${magenta}System${reset}"
        "  OS............. ${os_name}"
        "  Kernel......... $(uname -srmo)"
        "  Shell.......... ${shell_display}"
        "  Packages....... ${package_count}"
        "  Uptime......... ${uptime_text}"
        "  Memory......... ${used_mem} used / ${available_mem} available / ${total_mem} total"
        "  Disk........... ${disk_usage}"
        "  Load........... ${load_one}, ${load_five}, ${load_fifteen} (1, 5, 15 min)"
        "  Processes...... ${process_count}"
        "  Updates........ ${updates_color}${count_updates}${reset}"
        ""
        "${bold}${magenta}Network${reset}"
        "  Wi-Fi IP....... ${wifi_ip}"
        "  Ethernet IP.... ${ethernet_ip}"
        "  Public IP...... ${public_ip}"
        "  Weather........ ${weather}"
        ""
        "${bold}${magenta}Raspberry Pi${reset}"
        "  CPU............ ${cpu_display}"
        "  CPU Temp....... ${cpu_temp}"
        "  Throttling..... ${throttled_color}${throttled_status}${reset}"
    )


    # =========================================================================
    # Raspberry Pi logo
    # =========================================================================

    # Retrieve Screenfetch's large Raspbian ASCII logo.
    #
    # `-D Raspbian` forces the Raspbian artwork rather than relying on automatic
    # distribution detection.
    #
    # `-L` displays only the ASCII logo because this file generates its own
    # diagnostic information.
    logo=()

    if command -v screenfetch >/dev/null 2>&1; then
        while IFS= read -r line; do
            logo+=("$line")
        done < <(
            screenfetch -D Raspbian -L
        )
    fi


    # =========================================================================
    # Combined banner
    # =========================================================================

    # Display the Raspberry Pi logo on the left and diagnostics on the right.
    #
    # Screenfetch includes ANSI color escape sequences in its output. Those
    # sequences occupy bytes but no visible terminal columns, so ordinary
    # printf field widths cannot be used to align the diagnostics reliably.
    #
    # Calculate the widest visible logo line after removing ANSI escape
    # sequences, then pad each logo line manually.


    # -------------------------------------------------------------------------
    # Visible string length
    # -------------------------------------------------------------------------

    # Return the visible length of a string after removing common ANSI color
    # and formatting escape sequences.
    visible_length()
    {
        local text=$1
        local clean

        clean=$(
            printf '%s' "$text" \
                | sed $'s/\033\\[[0-9;]*[[:alpha:]]//g'
        )

        printf '%d' "${#clean}"
    }


    # -------------------------------------------------------------------------
    # Determine logo width
    # -------------------------------------------------------------------------

    logo_width=0

    for line in "${logo[@]}"; do
        width=$(visible_length "$line")

        if (( width > logo_width )); then
            logo_width=$width
        fi
    done

    # Leave several spaces between the logo and diagnostic panel.
    column_gap=4


    # -------------------------------------------------------------------------
    # Vertical alignment
    # -------------------------------------------------------------------------

    logo_lines=${#logo[@]}
    diagnostic_lines=${#diagnostics[@]}

    if (( logo_lines > diagnostic_lines )); then
        total_lines=$logo_lines
        logo_offset=0
        diagnostic_offset=$(( (logo_lines - diagnostic_lines) / 2 ))
    else
        total_lines=$diagnostic_lines
        logo_offset=$(( (diagnostic_lines - logo_lines) / 2 ))
        diagnostic_offset=0
    fi


    # -------------------------------------------------------------------------
    # Print both columns
    # -------------------------------------------------------------------------

    for ((i = 0; i < total_lines; i++)); do
        logo_line=""
        diagnostic_line=""

        logo_index=$((i - logo_offset))
        diagnostic_index=$((i - diagnostic_offset))

        if (( logo_index >= 0 && logo_index < logo_lines )); then
            logo_line=${logo[$logo_index]}
        fi

        if (( diagnostic_index >= 0 \
            && diagnostic_index < diagnostic_lines ))
        then
            diagnostic_line=${diagnostics[$diagnostic_index]}
        fi

        # Determine how much padding is required after the visible portion of
        # the logo line.
        visible_logo_width=$(visible_length "$logo_line")
        padding=$((logo_width - visible_logo_width + column_gap))

        printf '%s%*s%b\n' \
            "$logo_line" \
            "$padding" \
            "" \
            "$diagnostic_line"
    done

    printf '\n'


    # =========================================================================
    # Warnings
    # =========================================================================


    # -------------------------------------------------------------------------
    # Raspberry Pi power / thermal warning
    # -------------------------------------------------------------------------

    # A non-zero throttling value means that a power or thermal condition is
    # currently present or has occurred since boot.
    if [[ "$throttled_status" != "OK (0x0)" \
        && "$throttled_status" != "N/A" ]]
    then
        printf '%s%sWarning:%s Raspberry Pi power/thermal issue detected.\n' \
            "$bold" \
            "$red" \
            "$reset"
    fi


    # -------------------------------------------------------------------------
    # Reboot requirement
    # -------------------------------------------------------------------------

    # Debian-based systems create this file when an installed update requires a
    # reboot.
    if [[ -f /var/run/reboot-required ]]; then
        printf '%s%s%s\n' \
            "$red" \
            "$(cat /var/run/reboot-required)" \
            "$reset"
    fi

fi


# =============================================================================
# Interactive Bash configuration
# =============================================================================

# Load the normal interactive Bash configuration.
#
# Bash login shells, including many SSH sessions, read ~/.bash_profile rather
# than ~/.bashrc directly.
#
# Sourcing ~/.bashrc here ensures that:
#
#   - shell history configuration is applied
#   - ~/.local/bin is added to PATH
#   - editor settings are applied
#   - command compatibility aliases are available
#   - machine-specific ~/.bashrc.local settings are loaded
#   - SSH sessions can automatically attach to tmux
#
# ~/.bashrc itself should contain an interactive-shell guard, so sourcing it
# here is safe even if this login shell is non-interactive.
if [[ -f "$HOME/.bashrc" ]]; then
    source "$HOME/.bashrc"
fi
