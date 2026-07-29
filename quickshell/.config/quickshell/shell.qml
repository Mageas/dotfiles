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
    }
}
