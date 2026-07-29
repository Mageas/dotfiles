//@ pragma UseQApplication

import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import "modules"

ShellRoot {
    Variants {
        model: Quickshell.screens

        Bar {
            required property var modelData
            screen: modelData
        }
    }

    // Floating volume indicator, on whichever screen has focus.
    Osd {}

    // Wallpaper + palette picker, opened with Mod+T.
    WallpaperPicker {}

    // Application launcher, opened with Mod+P or the bar's logo.
    AppLauncher {}

    // `qs ipc call bar <fn>` — the panels and the bar itself are bound to keys
    // in ~/.config/hypr/binds.lua as well as being clickable.
    IpcHandler {
        target: "bar"

        function calendar(): void {
            Panels.toggle("calendar", Hyprland.focusedMonitor?.name ?? "");
        }

        function session(): void {
            Panels.toggle("session", Hyprland.focusedMonitor?.name ?? "");
        }

        function dismiss(): void {
            Panels.close();
        }

        function toggle(): void {
            BarState.toggle();
        }

        function reload(): void {
            Quickshell.reload(true);
        }

        function launcher(): void {
            LauncherState.toggle();
        }

        function wallpapers(): void {
            if (WallpaperStore.open)
                WallpaperStore.close();
            else
                WallpaperStore.show();
        }
    }
}
