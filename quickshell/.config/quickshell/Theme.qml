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
    readonly property color primary: swatch("primary", "#a2c9fe")
    readonly property color textOnPrimary: swatch("on_primary", "#00325a")
    readonly property color primaryContainer: swatch("primary_container", "#1d4875")
    readonly property color textPrimaryContainer: swatch("on_primary_container", "#d2e4ff")

    readonly property color secondary: swatch("secondary", "#bbc7db")
    readonly property color secondaryContainer: swatch("secondary_container", "#3c4858")
    readonly property color textSecondaryContainer: swatch("on_secondary_container", "#d7e3f8")

    readonly property color tertiary: swatch("tertiary", "#d8bde4")
    readonly property color tertiaryContainer: swatch("tertiary_container", "#533f5f")
    readonly property color textTertiaryContainer: swatch("on_tertiary_container", "#f4d9ff")

    readonly property color error: swatch("error", "#ffb4ab")
    readonly property color textOnError: swatch("on_error", "#690005")

    readonly property color surface: swatch("surface", "#111418")
    readonly property color surfaceDim: swatch("surface_dim", "#111418")
    readonly property color surfaceBright: swatch("surface_bright", "#37393e")
    readonly property color surfaceLowest: swatch("surface_container_lowest", "#0b0e13")
    readonly property color surfaceLow: swatch("surface_container_low", "#191c20")
    readonly property color surfaceContainer: swatch("surface_container", "#1d2024")
    readonly property color surfaceHigh: swatch("surface_container_high", "#272a2f")
    readonly property color surfaceHighest: swatch("surface_container_highest", "#32353a")

    readonly property color text: swatch("on_surface", "#e1e2e8")
    readonly property color textMuted: swatch("on_surface_variant", "#c3c6cf")
    readonly property color outline: swatch("outline", "#8d9199")
    readonly property color outlineVariant: swatch("outline_variant", "#43474e")
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
