pragma Singleton

import Quickshell
import Quickshell.Io

// The wallpaper library, and the palette each one would produce.
//
// `matugen --dry-run` costs about 60ms per image and applies nothing, so every
// wallpaper's palette is computed up front and shown as swatches in the picker.
// Choosing a wallpaper is then a decision about the whole colour scheme rather
// than a guess from a thumbnail.
Singleton {
    id: root

    readonly property string directory: Quickshell.env("MGS_WALLPAPER_PATH") || (Quickshell.env("HOME") + "/.local/wallpapers")

    property bool open: false
    property bool applying: false
    property string current: ""
    property var entries: []

    function show() {
        scan.running = true;
        currentQuery.running = true;
        root.open = true;
    }

    function close() {
        root.open = false;
    }

    function apply(path) {
        if (root.applying)
            return;
        root.applying = true;
        applyProcess.command = ["walset-backend", path];
        applyProcess.running = true;
    }

    // One shell pass over the library: each line is `path<TAB>{palette}`, so a
    // single process covers both the listing and every preview.
    Process {
        id: scan

        command: ["/bin/sh", "-c", `find -L '${root.directory}' -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \\) | sort | while read -r f; do printf '%s\\t' "$f"; matugen image "$f" --dry-run --json hex -q 2>/dev/null | jq -c '.colors | {primary: .primary.default, secondary: .secondary.default, tertiary: .tertiary.default}' 2>/dev/null || echo '{}'; done`]

        stdout: StdioCollector {
            onStreamFinished: {
                const out = [];
                for (const line of text.split("\n")) {
                    const tab = line.indexOf("\t");
                    if (tab === -1)
                        continue;
                    const path = line.slice(0, tab);
                    let palette = {};
                    try {
                        palette = JSON.parse(line.slice(tab + 1));
                    } catch (e) {}
                    const file = path.split("/").pop();
                    out.push({
                        path: path,
                        file: file,
                        name: file.replace(/\.[^.]+$/, "").replace(/[-_]/g, " "),
                        palette: palette
                    });
                }
                root.entries = out;
            }
        }
    }

    // Which one is on screen right now, so the picker can mark it. swww
    // reports the resolved path while the library is a directory of symlinks,
    // so the comparison is on the file name.
    Process {
        id: currentQuery

        command: ["/bin/sh", "-c", "swww query | head -1 | sed 's/.*image: //' | xargs -r basename"]

        stdout: StdioCollector {
            onStreamFinished: root.current = text.trim()
        }
    }

    Process {
        id: applyProcess

        onExited: {
            root.applying = false;
            root.open = false;
            currentQuery.running = true;
        }
    }
}
