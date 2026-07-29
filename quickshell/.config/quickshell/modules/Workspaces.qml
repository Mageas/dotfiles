import QtQuick
import Quickshell
import Quickshell.Hyprland
import ".." // Theme, Motion

// Morphing workspace pills. Rather than sliding a separate indicator around,
// each pill animates its own width and colour, so switching reads as the shape
// itself travelling: the focused one stretches open and shows its number while
// the one you left contracts back to a dot.
Item {
    id: root

    required property ShellScreen screen

    readonly property var persistent: ({
            "DP-1": [1, 2, 3, 4, 5],
            "DP-2": [9, 10]
        })

    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.screen)

    readonly property var entries: {
        const live = {};
        for (const ws of Hyprland.workspaces.values) {
            if (ws.monitor === root.monitor && ws.id > 0)
                live[ws.id] = ws;
        }

        const ids = new Set(root.persistent[root.screen.name] ?? []);
        for (const id of Object.keys(live))
            ids.add(parseInt(id));

        return Array.from(ids).sort((a, b) => a - b).map(id => ({
                    id: id,
                    workspace: live[id] ?? null
                }));
    }

    implicitWidth: row.implicitWidth + 12
    implicitHeight: Theme.barHeight - Theme.islandPadding * 2

    // Scrolling anywhere on the group steps through workspaces.
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        onWheel: event => Hyprland.dispatch(`hl.dsp.focus({ workspace = "e${event.angleDelta.y > 0 ? "+" : "-"}1" })`)
    }

    Row {
        id: row

        anchors.centerIn: parent
        spacing: 6

        Repeater {
            model: root.entries

            Item {
                id: slot

                required property var modelData

                readonly property var workspace: modelData.workspace
                readonly property bool focused: workspace?.focused ?? false
                readonly property bool visibleHere: workspace?.active ?? false
                readonly property bool urgent: workspace?.urgent ?? false
                readonly property bool occupied: (workspace?.toplevels.values.length ?? 0) > 0

                implicitWidth: pill.width
                implicitHeight: root.implicitHeight

                Rectangle {
                    id: pill

                    anchors.verticalCenter: parent.verticalCenter

                    // Three sizes, one shape: dot → dash → pill. The pill also
                    // opens for the workspace shown on an unfocused monitor,
                    // just in a quieter fill.
                    //
                    // Hovering an inactive one stretches it part of the way
                    // towards the open pill and lifts its fill — a preview of
                    // what clicking would do, in the same language as the
                    // switch itself.
                    readonly property bool previewing: mouse.containsMouse && !slot.visibleHere

                    width: slot.visibleHere ? 32 : previewing ? 24 : slot.occupied ? 18 : 10
                    height: slot.visibleHere ? 18 : previewing ? 14 : slot.occupied ? 10 : 8
                    radius: height / 2

                    color: {
                        if (slot.urgent)
                            return Theme.error;
                        if (slot.focused)
                            return Theme.primary;
                        if (slot.visibleHere)
                            return Theme.alpha(Theme.primary, 0.3);
                        if (previewing)
                            return Theme.alpha(Theme.primary, slot.occupied ? 0.6 : 0.4);
                        if (slot.occupied)
                            return Theme.alpha(Theme.textMuted, 0.45);
                        return Theme.alpha(Theme.textMuted, 0.18);
                    }

                    Behavior on width {
                        NumberAnimation {
                            duration: Motion.normal
                            easing.type: Easing.Bezier
                            easing.bezierCurve: Motion.bounce
                        }
                    }
                    Behavior on height {
                        NumberAnimation {
                            duration: Motion.normal
                            easing.type: Easing.Bezier
                            easing.bezierCurve: Motion.bounce
                        }
                    }
                    Behavior on color {
                        ColorAnimation {
                            duration: Motion.normal
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: slot.modelData.id
                        color: slot.urgent ? Theme.textOnError : slot.focused ? Theme.textOnPrimary : Theme.text
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSmall
                        font.weight: Font.DemiBold

                        // The number only exists while the pill is wide enough
                        // to hold it, and fades rather than pops.
                        opacity: slot.visibleHere ? 1 : 0
                        Behavior on opacity {
                            NumberAnimation {
                                duration: Motion.fast
                            }
                        }
                    }
                }

                MouseArea {
                    id: mouse

                    anchors.fill: parent
                    anchors.margins: -4
                    hoverEnabled: true
                    // Hyprland 0.56 takes Lua for dispatch requests, not the old
                    // `workspace 3` string — that silently does nothing.
                    onClicked: Hyprland.dispatch(`hl.dsp.focus({ workspace = ${slot.modelData.id} })`)
                }
            }
        }
    }
}
