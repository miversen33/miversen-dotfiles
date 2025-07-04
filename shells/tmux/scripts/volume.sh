#!/bin/bash

# Check if pactl is available
if ! command -v pactl &>/dev/null; then
  echo ""
  exit 0
fi

# Get default sink
sink=$(pactl get-default-sink 2>/dev/null)
if [ -z "$sink" ]; then
  echo ""
  exit 0
fi

# Check if audio is muted
is_muted=$(pactl get-sink-mute "$sink" | awk '{print $2}')
if [ "$is_muted" == "yes" ]; then
  echo " "
  exit 0
fi

# Get average volume (percent of all channels)
volume=$(pactl get-sink-volume "$sink" | grep -oP '\d+?(?=%)' | awk '{ total += $1; count++ } END { if (count > 0) print int(total / count) }')

volume_icon=""
# Output appropriate icon
if [ "$volume" -eq 0 ]; then
  volume_icon=" "
elif [ "$volume" -le 30 ]; then
  volume_icon=" "
elif [ "$volume" -le 60 ]; then
  volume_icon="󰕾 "
else
  volume_icon=" "
fi

echo "${volume_icon}"
