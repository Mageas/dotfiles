-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:
-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

hl.on("hyprland.start", function()
    -- The colour files are matugen build output, so they are absent on a fresh
    -- clone and every `@import` fails. Lay down Catppuccin Mocha for whatever is
    -- still missing, before anything reads them. Existing files are left alone.
    hl.exec_cmd("~/.local/bin/theme-reset --if-missing")

    hl.exec_cmd("qs -p ~/.config/quickshell/shell.qml")
    hl.exec_cmd("swaync")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("swww-daemon")
    hl.exec_cmd("easyeffects --gapplication-service")
    hl.exec_cmd("/usr/libexec/polkit-mate-authentication-agent-1")

    -- In `~/.config/Code/argv.json`, set `"password-store": "gnome-libsecret"` to avoid keyring issues with VSCode on Hyprland
    hl.exec_cmd("gnome-keyring-daemon --start --components=pkcs11,secrets,ssh")

    hl.exec_cmd("~/.local/bin/kDrive.AppImage")

    hl.exec_cmd("flatpak run com.brave.Browser", { workspace = "1 silent" })
end)
