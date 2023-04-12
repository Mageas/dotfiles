#!/bin/env sh

# PATH
export PATH=$PATH:$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.emacs.d/bin

# Render java applications
export _JAVA_AWT_WM_NONREPARENTING=1

# Set the resolution and the refresh rate of the screens
if [ -x "$(command -v xrandr)" ]; then
    xrandr --output DisplayPort-0 --mode "2560x1440" --pos "1920x0" --rate 240 --primary --output DisplayPort-1 --mode "1920x1080" --pos "0x180" --rate 165
fi

# Load Xresources
if [[ -f ~/.config/Xresources ]]; then
    xrdb -merge -I$HOME ~/.config/Xresources
fi

# Disable the screen saver
if [ -x "$(command -v xset)" ]; then
    xset s off -dpms
fi

if [ -x "$(command -v /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1)" ]; then
    /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
fi

# Start the compositor
if [ -x "$(command -v picom)" ]; then
    picom &
fi

# Set the wallpaper
if [ -x "$(command -v feh)" ]; then
    feh --bg-fill /home/$USER/.config/wallpaper/wallpaper.jpg &
fi

# Packages
if [ -x "$(command -v statusbar)" ]; then
    statusbar &
fi

if [ -x "$(command -v dunst)" ]; then
    dunst &
fi

if [ -x "$(command -v redshift)" ]; then
    redshift &
fi

if [ -x "$(command -v sxhkd)" ]; then
    sxhkd &
fi

if [ -x "$(command -v emacs)" ]; then
    emacs --daemon &
fi

# Applications
if [ -x "$(command -v firefox)" ]; then
    firefox &
fi

if [ -x "$(command -v discord)" ]; then
    discord &
fi

flatpak run im.riot.Riot &
