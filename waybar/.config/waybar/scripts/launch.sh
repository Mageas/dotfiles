#!/bin/bash

# Reload Waybar
killall -9 waybar
waybar &

# Reload SwayNC
swaync-client -rs -R
