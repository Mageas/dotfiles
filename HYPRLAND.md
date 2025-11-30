## Hyprland

Complete Hyprland window manager setup with Waybar, Rofi, and various utilities.

---

### Dependencies

```
hyprland, waybar, rofi, hypridle, hyprlock, swww, matugen, hyprpicker, hyprshot, nm-connection-editor, pavucontrol, easyeffects, jetbrains-mono-fonts, wlogout, mate-polkit
```

```
swaync, pamixer, pipewire, xdg-desktop-portal-hyprland, qt5-qtwayland, qt6-qtwayland, nwg-look, swww, waybar, udiskie, kvantum, hypridle, hyprlock, hyprpicker, wl-clipboard, mate-polkit, adw-gtk3-theme
```

---

### VSCode for Wayland

To launch VSCode in Wayland mode, copy and modify the desktop file:
```BASH
cp /usr/share/applications/code.desktop ~/.local/share/applications/
```

Then, edit the `Exec` line in `~/.local/share/applications/code.desktop`:
```DESKTOP
Exec=/usr/share/code/code --enable-features=UseOzonePlatform,WaylandWindowDecorations --ozone-platform-hint=auto --unity-launch %F
```

---

### In `nwg-look`

- For **Font antialiasing**, set the value to `"rgba"`.

---

### Installing selectdefaultapplication

Dependencies: `git`, `qt5-qtbase-devel`, `make`, `gcc-c++`

```BASH
git clone https://github.com/sandsmark/selectdefaultapplication.git
cd selectdefaultapplication

qmake-qt5
make

sudo cp selectdefaultapplication /usr/local/bin/
sudo cp selectdefaultapplication.desktop /usr/share/applications/

sudo mkdir -p /usr/share/pixmaps
sudo cp selectdefaultapplication.png /usr/share/pixmaps/
sudo update-desktop-database /usr/share/applications/
```

---

### Rofi themes and fonts

Require themes and fonts for Rofi (see the **[Setup](#setup)** section).

---

### Configuration files

- `hyprland.conf` – Main settings, animations, visual effects  
- `binds.conf` – Keybindings  
- `programs.conf` – Application settings  
- `startup.conf` – Autostart programs  
- `window_rules.conf` – Window rules  
- `workspaces.conf` – Workspace setup  
- `hypridle.conf` – Idle management (screen lock, DPMS)  

---

### Setup

**Install Rofi themes:**

```BASH
cd /tmp
git clone --depth=1 https://github.com/adi1090x/rofi.git
mkdir -p ~/.local/share/fonts
cp rofi/fonts/*.ttf ~/.local/share/fonts/
```

**Generate the first color scheme:**

```BASH
matugen image ~/.local/wallpapers/blue-forest.png
```

**Configure VSCode keyring:**

In `~/.config/Code/argv.json`, add:
```
"password-store": "gnome-libsecret"
```

<!-- https://github.com/vinceliuice/Graphite-gtk-theme
```sh
./install.sh -l --tweaks darker rimless normal

gsettings set org.gnome.desktop.interface gtk-theme "Graphite-dark"
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
```

https://github.com/vinceliuice/Graphite-kde-theme
```sh
./install.sh --rimless

# Install from kvantum
```

In `~/.config/gtk-4.0/gtk.css` and `~/.config/gtk-3.0/gtk.css`, add these lines :
```css
@import 'colors/matugen.css';
``` -->