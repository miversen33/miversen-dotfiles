#!/bin/bash
if command -v pmset >/dev/null 2>&1; then
    battery=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
elif command -v acpi >/dev/null 2>&1; then
    battery=$(acpi -b | grep -P -o "[0-9]+(?=%)")
elif [ -f /sys/class/power_supply/BAT0/capacity ]; then
    battery=$(cat /sys/class/power_supply/BAT0/capacity)
elif [ -f /sys/class/power_supply/BAT1/capacity ]; then
    battery=$(cat /sys/class/power_supply/BAT1/capacity)
else
    echo "󰂑"; exit 0
fi

battery=${battery:-0}
if [ "$battery" -ge 90 ]; then echo "󰁹"
elif [ "$battery" -ge 80 ]; then echo "󰂂"
elif [ "$battery" -ge 70 ]; then echo "󰂁"
elif [ "$battery" -ge 60 ]; then echo "󰂀"
elif [ "$battery" -ge 50 ]; then echo "󰁿"
elif [ "$battery" -ge 40 ]; then echo "󰁾"
elif [ "$battery" -ge 30 ]; then echo "󰁽"
elif [ "$battery" -ge 20 ]; then echo "󰁼"
elif [ "$battery" -ge 10 ]; then echo "󰁻"
else echo "󰁺"
fi
