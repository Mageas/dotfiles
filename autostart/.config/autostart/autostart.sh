# Screen - CVT
xrandr --output DP-0 --mode "2560x1440" --primary --output DP-4 --mode "1920x1080" --rate 165 --left-of DP-0

# Xresources
[[ -f ~/.config/Xresources ]] && xrdb -merge -I$HOME ~/.config/Xresources

# Compositor
picom &

# Screen saver
xset s off -dpms

# Status bar
statusbar &

# Dunst
/usr/bin/dunst &

# Wallpaper
feh --bg-fill /home/$USER/.config/wallpaper/wallpaper.jpg &

# Redshift
redshift &

# Sxhkd
sxhkd &

# Doom
/usr/bin/emacs --daemon &

# Applications
firefox &
discord &
revolt &
