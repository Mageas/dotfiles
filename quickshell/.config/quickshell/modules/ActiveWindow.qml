import QtQuick
import Quickshell
import Quickshell.Hyprland
import ".." // Theme, Motion

// The focused window's title. Swapping titles crossfades and lifts rather than
// snapping, and the whole module collapses to nothing when the desktop is bare.
Item {
    id: root

    required property ShellScreen screen

    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.screen)
    readonly property var toplevel: Hyprland.activeToplevel

    // Only speak for this screen — each monitor's bar shows its own focus.
    readonly property string title: {
        if (!toplevel || toplevel.monitor !== root.monitor)
            return "";
        return toplevel.title ?? "";
    }

    property string shown: ""

    onTitleChanged: swap.restart()

    implicitWidth: title === "" ? 0 : Math.min(label.implicitWidth + 24, 380)
    implicitHeight: Theme.barHeight - Theme.islandPadding * 2
    opacity: title === "" ? 0 : 1
    clip: true

    Behavior on implicitWidth {
        NumberAnimation {
            duration: Motion.normal
            easing.type: Easing.Bezier
            easing.bezierCurve: Motion.emphasized
        }
    }
    Behavior on opacity {
        NumberAnimation {
            duration: Motion.fast
        }
    }

    Text {
        id: label

        anchors.centerIn: parent
        width: Math.min(implicitWidth, root.width - 24)
        elide: Text.ElideRight
        text: root.shown
        color: Theme.textMuted
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontNormal
    }

    SequentialAnimation {
        id: swap

        ParallelAnimation {
            NumberAnimation {
                target: label
                property: "opacity"
                to: 0
                duration: Motion.instant
            }
            NumberAnimation {
                target: label
                property: "anchors.verticalCenterOffset"
                to: -6
                duration: Motion.instant
            }
        }
        ScriptAction {
            script: root.shown = root.title
        }
        PropertyAction {
            target: label
            property: "anchors.verticalCenterOffset"
            value: 6
        }
        ParallelAnimation {
            NumberAnimation {
                target: label
                property: "opacity"
                to: 1
                duration: Motion.normal
            }
            NumberAnimation {
                target: label
                property: "anchors.verticalCenterOffset"
                to: 0
                duration: Motion.normal
                easing.type: Easing.Bezier
                easing.bezierCurve: Motion.emphasized
            }
        }
    }
}
