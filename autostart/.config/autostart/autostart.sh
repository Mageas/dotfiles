# Set the resolution and the refresh rate of the screens
if [ -x "$(command -v xrandr)" ]; then
    xrandr --output DisplayPort-0 --mode "2560x1440" --primary --output DisplayPort-1 --mode "1920x1080" --rate 165 --left-of DisplayPort-0
fi

# Load Xresources
if [[ -f ~/.config/Xresources ]]; then
    xrdb -merge -I$HOME ~/.config/Xresources
fi

# Disable the screen saver
if [ -x "$(command -v xset)" ]; then
    xset s off -dpms
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

if [ -x "$(command -v revolt)" ]; then
    revolt &
fi
