import QtQuick
import Quickshell
import ".." // Theme, Motion, Panels

// Session controls. The panel's buttons fan in one after another, and the
// destructive one only takes its red once you are hovering it.
ModuleButton {
    id: root

    required property string screenName

    readonly property bool panelOpen: Panels.isOpen("session", root.screenName)

    readonly property var actions: [
        {
            glyph: "\uf023",
            label: "Verrouiller",
            tint: Theme.primary,
            command: ["hyprlock"]
        },
        {
            glyph: "\u{f04b2}",
            label: "Veille",
            tint: Theme.tertiary,
            command: ["systemctl", "suspend"]
        },
        {
            glyph: "\uf2f5",
            label: "Déconnexion",
            tint: Theme.secondary,
            command: ["hyprctl", "dispatch", "exit"]
        },
        {
            glyph: "\uf021",
            label: "Redémarrer",
            tint: Theme.tertiary,
            command: ["systemctl", "reboot"]
        },
        {
            glyph: "\uf011",
            label: "Éteindre",
            tint: Theme.error,
            command: ["systemctl", "poweroff"]
        }
    ]

    icon: "\uf011"
    foreground: panelOpen || hovered ? Theme.error : Theme.textMuted
    active: panelOpen
    accent: Theme.error
    tooltipText: panelOpen ? "" : "Session"
    padding: 10

    onClicked: Panels.toggle("session", root.screenName)

    Panel {
        target: root
        open: root.panelOpen
        onDismissed: Panels.close()
        panelWidth: 236
        panelHeight: root.actions.length * 42 + 20

        content: Component {
            Column {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 2

                Repeater {
                    model: root.actions

                    Rectangle {
                        id: entry

                        required property var modelData
                        required property int index

                        width: parent.width
                        height: 40
                        radius: Theme.radiusModule
                        color: press.containsMouse ? Theme.alpha(entry.modelData.tint, 0.16) : "transparent"

                        opacity: 0
                        x: 12

                        Behavior on color {
                            ColorAnimation {
                                duration: Motion.fast
                            }
                        }

                        Row {
                            anchors.left: parent.left
                            anchors.leftMargin: 14
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 14

                            Text {
                                text: entry.modelData.glyph
                                color: press.containsMouse ? entry.modelData.tint : Theme.textMuted
                                font.family: Theme.iconFamily
                                font.pixelSize: Theme.iconNormal

                                Behavior on color {
                                    ColorAnimation {
                                        duration: Motion.fast
                                    }
                                }
                            }

                            Text {
                                text: entry.modelData.label
                                color: Theme.text
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontNormal
                                height: Theme.iconNormal
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        MouseArea {
                            id: press

                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                Panels.close();
                                Quickshell.execDetached(entry.modelData.command);
                            }
                        }

                        ParallelAnimation {
                            id: reveal

                            NumberAnimation {
                                target: entry
                                property: "opacity"
                                to: 1
                                duration: Motion.normal
                            }
                            NumberAnimation {
                                target: entry
                                property: "x"
                                to: 0
                                duration: Motion.normal
                                easing.type: Easing.Bezier
                                easing.bezierCurve: Motion.emphasized
                            }
                        }

                        Timer {
                            interval: 35 * entry.index
                            running: true
                            onTriggered: reveal.start()
                        }
                    }
                }
            }
        }
    }
}
