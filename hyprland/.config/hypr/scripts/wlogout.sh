#!/usr/bin/env bash

# Fixed size of wlogout menu in pixels
wlogout_height=280
wlogout_width=1455

# Check if wlogout is already running
if pgrep -x "wlogout" > /dev/null; then
    pkill -x "wlogout"
    exit 0
fi

# Detect monitor resolution and scaling factor
screen_height=$(hyprctl -j monitors | jq -r '.[] | select(.focused==true) | .height / .scale' | awk -F'.' '{print $1}')
screen_width=$(hyprctl -j monitors | jq -r '.[] | select(.focused==true) | .width / .scale' | awk -F'.' '{print $1}')
hypr_scale=$(hyprctl -j monitors | jq -r '.[] | select(.focused==true) | .scale')

# Calculate margins to center horizontally and vertically
margin_vertical=$(awk "BEGIN {printf \"%.0f\", ($screen_height - $wlogout_height) / 2}")
margin_horizontal=$(awk "BEGIN {printf \"%.0f\", ($screen_width - $wlogout_width) / 2}")

wlogout -C ${HOME}/.config/wlogout/style.css \
        -l ${HOME}/.config/wlogout/layout \
        --protocol layer-shell \
        -b 5 \
        -T $margin_vertical \
        -B $margin_vertical \
        -L $margin_horizontal \
        -R $margin_horizontal &
