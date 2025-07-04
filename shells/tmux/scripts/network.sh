network_icon=""

if ! ip route | grep -q '^default'; then
    # We have no internet access at all
    echo "󰤮  "
    exit 0
fi

wifi_if=$(iw dev | awk '$1=="Interface"{print $2}')
if [[ -n "$wifi_if" && $(cat /sys/class/net/$wifi_if/operstate) == "up" ]]; then
    network_icon="  "
else
    network_icon="  "
fi

echo "${network_icon}"
