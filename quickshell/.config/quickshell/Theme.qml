pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Design tokens for the whole shell.
//
// Colours are the Material 3 roles matugen writes to `styles/colors.json`
// (see ~/.config/matugen/config.toml). The file is watched, so changing the
// wallpaper recolours the bar live — no reload, no signal.
Singleton {
    id: root

    // ── type ──────────────────────────────────────────────────────────────
    readonly property string fontFamily: "SF Pro Text"
    readonly property string fontFamilyMono: "JetBrainsMono Nerd Font Propo"
    readonly property string iconFamily: "JetBrainsMono Nerd Font Propo"

    readonly property int fontTiny: 10
    readonly property int fontSmall: 11
    readonly property int fontNormal: 13
    readonly property int fontLarge: 15
    readonly property int iconNormal: 15
    readonly property int iconLarge: 18

    // ── metrics ───────────────────────────────────────────────────────────
    readonly property int barHeight: 38
    readonly property int barMarginTop: 8
    readonly property int barMarginSide: 12

    // Hyprland lays its own gaps_out below the reserved zone, which left twice
    // as much room under the bar as beside the windows. Measured against
    // gaps_out = 10, trimming 8 makes the gap under the bar match the edges.
    readonly property int exclusiveTrim: 8
    readonly property int islandGap: 8
    readonly property int islandPadding: 5
    readonly property int modulePadding: 11
    readonly property int moduleGap: 2

    readonly property int radiusFull: barHeight / 2
    readonly property int radiusModule: 14
    readonly property int radiusPanel: 20
    readonly property int radiusSmall: 8

    readonly property real islandAlpha: 0.88

    // ── palette ───────────────────────────────────────────────────────────
    property var palette: ({})

    function swatch(name, fallback) {
        return root.palette[name] !== undefined ? root.palette[name] : fallback;
    }

    // Same colour with a different alpha — the workhorse for hover states.
    function alpha(c, a) {
        return Qt.rgba(c.r, c.g, c.b, a);
    }

    // Material's "on-" roles are renamed: a QML property called `onSurface`
    // collides with the change handler generated for `surface` and silently
    // resolves to black.
    //
    // The fallbacks are Catppuccin Mocha, the same palette `theme-reset` writes
    // to the colour file — so the bar looks right even before matugen has ever
    // run, and identical either way.
    readonly property color primary: swatch("primary", "#cba6f7")
    readonly property color textOnPrimary: swatch("on_primary", "#11111b")
    readonly property color primaryContainer: swatch("primary_container", "#403652")
    readonly property color textPrimaryContainer: swatch("on_primary_container", "#ccb9f6")

    readonly property color secondary: swatch("secondary", "#89b4fa")
    readonly property color secondaryContainer: swatch("secondary_container", "#2f3a53")
    readonly property color textSecondaryContainer: swatch("on_secondary_container", "#a4c2f8")

    readonly property color tertiary: swatch("tertiary", "#f5c2e7")
    readonly property color tertiaryContainer: swatch("tertiary_container", "#4a3d4e")
    readonly property color textTertiaryContainer: swatch("on_tertiary_container", "#e5caec")

    readonly property color error: swatch("error", "#f38ba8")
    readonly property color textOnError: swatch("on_error", "#11111b")

    readonly property color surface: swatch("surface", "#1e1e2e")
    readonly property color surfaceDim: swatch("surface_dim", "#11111b")
    readonly property color surfaceBright: swatch("surface_bright", "#585b70")
    readonly property color surfaceLowest: swatch("surface_container_lowest", "#11111b")
    readonly property color surfaceLow: swatch("surface_container_low", "#181825")
    readonly property color surfaceContainer: swatch("surface_container", "#1e1e2e")
    readonly property color surfaceHigh: swatch("surface_container_high", "#313244")
    readonly property color surfaceHighest: swatch("surface_container_highest", "#45475a")

    readonly property color text: swatch("on_surface", "#cdd6f4")
    readonly property color textMuted: swatch("on_surface_variant", "#bac2de")
    readonly property color outline: swatch("outline", "#6c7086")
    readonly property color outlineVariant: swatch("outline_variant", "#45475a")
    readonly property color shadow: swatch("shadow", "#000000")

    FileView {
        path: Quickshell.shellPath("styles/colors.json")
        watchChanges: true
        printErrors: false

        onFileChanged: reload()
        onLoaded: {
            try {
                root.palette = JSON.parse(text());
            } catch (e) {
                root.palette = ({});
            }
        }
        onLoadFailed: root.palette = ({})
    }
}
