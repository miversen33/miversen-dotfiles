#!/bin/bash

BATTERY_PATH="/sys/class/power_supply/BAT0"
STATUS=$(cat "$BATTERY_PATH/status" 2>/dev/null || echo "Unknown")

# Log the decision for debugging
logger "hypridle: Power status is $STATUS"

# Only sleep if on battery power
if [ "$STATUS" != "Charging" ]; then
    logger "hypridle: On battery - initiating hybrid sleep"
    systemctl hybrid-sleep
else
    logger "hypridle: Plugged in - skipping sleep"
fi
