import QtQuick
import Quickshell
import ".." // Theme, Motion

ModuleButton {
    id: root

    icon: "\ue7d9"
    tooltipText: "Applications"
    foreground: hovered ? Theme.primary : Theme.textMuted
    padding: 12

    // A full, slow turn under the cursor — the one purely frivolous thing here.
    iconRotation: hovered ? 360 : 0

    Behavior on iconRotation {
        NumberAnimation {
            duration: Motion.lazy
            easing.type: Easing.Bezier
            easing.bezierCurve: Motion.emphasized
        }
    }

    onClicked: Quickshell.execDetached(["/bin/sh", "-c", Quickshell.env("HOME") + "/.config/rofi/launchers/type-1/launcher.sh"])
}
