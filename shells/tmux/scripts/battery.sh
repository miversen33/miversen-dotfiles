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
    echo ""; exit 0
fi

battery=${battery:-0}
battery_icon="󰁺"
charging_icon="󱐋"
if [ "$battery" -ge 90 ]; then battery_icon="󰁹"
elif [ "$battery" -ge 80 ]; then battery_icon="󰂂"
elif [ "$battery" -ge 70 ]; then battery_icon="󰂁"
elif [ "$battery" -ge 60 ]; then battery_icon="󰂀"
elif [ "$battery" -ge 50 ]; then battery_icon="󰁿"
elif [ "$battery" -ge 40 ]; then battery_icon="󰁾"
elif [ "$battery" -ge 30 ]; then battery_icon="󰁽"
elif [ "$battery" -ge 20 ]; then battery_icon="󰁼"
elif [ "$battery" -ge 10 ]; then battery_icon="󰁻"
else battery_icon="󰁺"
fi
charging_state=$(cat /sys/class/power_supply/BAT0/status)
if [ "${charging_state}" == "Charging" ]; then
    charging_icon="󱐋"
fi

echo "${battery_icon}${charging_icon}"
