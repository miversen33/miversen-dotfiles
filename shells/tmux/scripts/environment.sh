#!/bin/bash
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    echo "󰒋 "
elif [ -f /.dockerenv ] || grep -q docker /proc/1/cgroup 2>/dev/null; then
    echo " "
else
    echo "󰋜 "
fi
