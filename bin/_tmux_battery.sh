#!/bin/bash

# Get battery info from pmset
battery_info=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
charging_status=$(pmset -g batt | grep -o "charging\|discharging\|charged")
time_remaining=$(pmset -g batt | grep -Eo "\d+:\d+ remaining")

# Determine battery icon and color based on level
if [ -n "$battery_info" ]; then
    if [ "$charging_status" = "charging" ]; then
        icon="⚡"
        color="colour10"  # green
    elif [ "$battery_info" -le 15 ]; then
        icon="🪫"
        color="colour1"   # red
    elif [ "$battery_info" -le 30 ]; then
        icon="🔋"
        color="colour3"   # yellow
    else
        icon="🔋"
        color="colour10"  # green
    fi

    # Format output
    if [ -n "$time_remaining" ]; then
        echo "$icon $battery_info% ($time_remaining)"
    else
        echo "$icon $battery_info%"
    fi
else
    echo "AC"
fi
