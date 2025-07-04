#!/bin/bash
# ~/.dotfiles/hyprland/scripts/migrate_laptop_to_workspace_on_close.sh

function get_laptop_id(){
    local laptop_model="Sharp"
    hyprctl monitors all -j | jq -r --argjson model "\"${laptop_model}\"" '[.[] | select(.description | contains($model))][0].id'
}

function get_first_external_id(){
    local laptop_id=$(get_laptop_id)
    hyprctl monitors all -j | jq -r --argjson id "${laptop_id}" '[.[] | select(.disabled == false and .id != $id)][0].id'
}

function migrate_workspaces(){
    local target_monitor_id="$1"
    local source_monitor_id="$2" # can be null in which case we move _all_ workspaces to target

    if [ -z ${source_monitor_id} ]; then
        hyprctl clients -j | jq -r --argjson id "\"${laptop_monitor_id}\"" '[ .[] | select(.monitor != $id) ][].workspace.id' | uniq | while read -r workspace; do
            hyprctl dispatch moveworkspacetomonitor "${workspace}" "${target_monitor_id}"
        done
    else
        hyprctl clients -j | jq -r --argjson id "\"${source_monitor_id}\"" '.[].monitor = $id | .[].workspace.id' | uniq | while read -r workspace; do
            hyprctl dispatch moveworkspacetomonitor "${workspace}" "${target_monitor_id}"
        done
    fi
}

function lid_close(){
    local laptop_monitor_id=$(get_laptop_id)
    local target_monitor_id=$(get_first_external_id)
    local laptop_name=$(hyprctl monitors all -j | jq -r --argjson id "${laptop_monitor_id}" ' .[] | select(.id == $id).name')
    local target_monitor=$(hyprctl monitors all -j | jq -r --argjson id "${target_monitor_id}" ' .[] | select(.id == $id).name')
    local laptop_active_workspace=$(hyprctl monitors all -j | jq -r --argjson id "${laptop_monitor_id}" ' .[] | select(.id == $id).activeWorkspace.id')

    migrate_workspaces "${target_monitor_id}" "${laptop_monitor_id}"

    hyprctl dispatch focusmonitor "${target_monitor}"
    hyprctl dispatch workspace "${laptop_active_workspace}"
    hyprctl keyword monitor "${laptop_name},disable"
}

function lid_open(){
    local laptop_monitor_id=$(get_laptop_id)
    local laptop_name=$(hyprctl monitors all -j | jq -r --argjson id "${laptop_monitor_id}" ' .[] | select(.id == $id).name')

    hyprctl keyword monitor "${laptop_name},enable"
}

function disconnect_from_dock(){
    local laptop_monitor_id=$(get_laptop_id)
    lid_open

    migrate_workspaces "${laptop_monitor_id}"
}

function default(){
    echo "miversen33 hyprland lid toggle script"
    echo
    echo "passed closed to run lid closed handling"
    echo "and opened to run lid opened handling"
}

case "$1" in
    closed)
        lid_close
        ;;
    opened)
        lid_open
        ;;
    disconnected)
        disconnect_from_dock
        ;;
    *)
        default
        ;;
esac


