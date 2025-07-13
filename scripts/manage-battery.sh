#!/bin/bash

BATTERY_PATH="/sys/class/power_supply/BAT0"
LOW_BATTERY_THRESHOLD=30
IDLE_OVERRIDE_FILE="/tmp/.miversen-hypridle-power-override"

# Check if hypridle is currently managing power profiles
if [ -f "$IDLE_OVERRIDE_FILE" ]; then
    logger "Battery event detected but hypridle is managing power profile - skipping"
    exit 0
fi

# Check if battery exists
if [ ! -d "$BATTERY_PATH" ]; then
    logger "Battery not found at $BATTERY_PATH"
    exit 1
fi

# Get battery info
CAPACITY=$(cat "$BATTERY_PATH/capacity" 2>/dev/null || echo "0")
STATUS=$(cat "$BATTERY_PATH/status" 2>/dev/null || echo "Unknown")

# Determine power profile
if [ "$CAPACITY" -lt "$LOW_BATTERY_THRESHOLD" ]; then
    # Low battery - use power-saver regardless of charging status
    powerprofilesctl set power-saver
    logger "Battery low ($CAPACITY%) - switching to power-saver profile"
elif [ "$STATUS" = "Charging" ]; then
    # Charging and above low battery - use performance
    powerprofilesctl set performance
    logger "Battery charging ($CAPACITY%) - switching to performance profile"
else
    # Not charging, above low battery - use balanced
    powerprofilesctl set balanced
    logger "Battery on battery ($CAPACITY%) - switching to balanced profile"
fi
