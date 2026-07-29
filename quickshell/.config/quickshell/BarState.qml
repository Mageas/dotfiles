pragma Singleton

import Quickshell

// Shared bar chrome state: whether the bar is tucked away, and the volume the
// OSD is currently reacting to.
Singleton {
    id: root

    property bool hidden: false

    function toggle() {
        root.hidden = !root.hidden;
    }
}
