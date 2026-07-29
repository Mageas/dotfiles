pragma Singleton

import Quickshell
import Quickshell.Io

// Launcher visibility, plus how often each application has been started.
//
// The tally is what orders the list: with an empty search the most-used app is
// first, and within a group of equally good text matches the one you reach for
// most wins. It survives restarts in the shell's state directory.
Singleton {
    id: root

    property bool open: false
    property var usage: ({})

    function show() {
        root.open = true;
    }

    function close() {
        root.open = false;
    }

    function toggle() {
        root.open = !root.open;
    }

    // DesktopEntry exposes no stable id, so the exec line is the key: unique
    // per application and unchanged by locale or a renamed .desktop file.
    function keyFor(entry) {
        return entry?.execString ?? "";
    }

    function countFor(entry) {
        return root.usage[root.keyFor(entry)] ?? 0;
    }

    function bump(entry) {
        const key = root.keyFor(entry);
        if (key === "")
            return;

        // Reassign rather than mutate: QML only notices the whole property.
        const next = Object.assign({}, root.usage);
        next[key] = (next[key] ?? 0) + 1;
        root.usage = next;

        store.setText(JSON.stringify(next));
    }

    FileView {
        id: store

        path: Quickshell.statePath("launcher-usage.json")
        atomicWrites: true
        printErrors: false

        onLoaded: {
            try {
                root.usage = JSON.parse(text()) ?? ({});
            } catch (e) {
                root.usage = ({});
            }
        }
        onLoadFailed: root.usage = ({})
    }
}
