# Script to show recent pacman installs, with some flexibility
#
# © Dale with Copilot365 - 4/1/21 - version 1.0
#
# Options:
# ========
#
# --pretty-date
# --reverse
# --lines <number>

#!/usr/bin/env bash

# Default values
PRETTY_DATE=false
REVERSE=false
LINES=10

# Parse flags
while [[ $# -gt 0 ]]; do
    case "$1" in
        --pretty-date) PRETTY_DATE=true ;;
        --reverse) REVERSE=true ;;
        --lines) LINES="$2"; shift ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
    shift
done

# Header
printf "\e[1;36mName\tVersion\tSize\tInstalled Date\e[0m\n"

pacman -Qi | awk -v pretty="$PRETTY_DATE" '
/^Name/{name=$3}
/^Version/{version=$3}
/^Installed Size/{size=$4" "$5}
/^Install Date/{
    date_str = $4" "$5" "$6" "$7" "$8" "$9
    cmd_epoch = "date -d \""date_str"\" +%s"
    cmd_fmt   = "date -d \""date_str"\" +\"%Y-%m-%d %H:%M\""
    if ((cmd_epoch | getline epoch) > 0) {
        close(cmd_epoch)
        if (pretty == "true") {
            cmd_fmt | getline nice_date
            close(cmd_fmt)
            print epoch, name, version, size, nice_date
        } else {
            print epoch, name, version, size, date_str
        }
    }
}
' | sort $( $REVERSE && echo "-n" || echo "-nr" ) | head -n "$LINES" | awk -v pretty="$PRETTY_DATE" '
{
    if (pretty == "true") {
        # Colour Installed Date green
        printf "%-20s %-15s %-12s \033[0;32m%s\033[0m\n", $2, $3, $4, $5" "$6
    } else {
        printf "%-20s %-15s %-12s %s\n", $2, $3, $4, $5" "$6" "$7" "$8" "$9" "$10
    }
}
' | column -t
