import QtQuick
import Quickshell
import ".." // Theme, Motion, Panels

ModuleButton {
    id: root

    // Which screen this bar lives on, so the panel opens on that one only.
    required property string screenName

    readonly property bool panelOpen: Panels.isOpen("calendar", root.screenName)

    active: panelOpen
    tooltipText: panelOpen ? "" : Qt.formatDateTime(clock.date, "dddd d MMMM yyyy")
    padding: 14
    spacing: 9

    onClicked: Panels.toggle("calendar", root.screenName)

    SystemClock {
        id: clock

        precision: SystemClock.Seconds
    }

    // Every child of this Row carries the full button height and centres its
    // own contents — a Row ignores anchors on its direct children.
    extra: Component {
        Row {
            height: root.height
            spacing: 9

            Text {
                text: Qt.formatDateTime(clock.date, "HH:mm")
                color: root.panelOpen || root.hovered ? Theme.primary : Theme.text
                height: root.height
                verticalAlignment: Text.AlignVCenter
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontLarge
                font.weight: Font.DemiBold

                Behavior on color {
                    ColorAnimation {
                        duration: Motion.fast
                    }
                }
            }

            // The seconds tick as a bar rather than digits: legible at a glance,
            // and it keeps the module's width perfectly stable.
            Item {
                width: 2
                height: root.height

                Rectangle {
                    anchors.centerIn: parent
                    width: 2
                    height: 16
                    radius: 1
                    color: Theme.alpha(Theme.textMuted, 0.25)

                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: parent.height * (clock.seconds / 59)
                        radius: 1
                        color: Theme.primary

                        Behavior on height {
                            NumberAnimation {
                                duration: Motion.normal
                                easing.type: Easing.Bezier
                                easing.bezierCurve: Motion.emphasized
                            }
                        }
                    }
                }
            }

            Item {
                width: dateStack.implicitWidth
                height: root.height

                Column {
                    id: dateStack

                    anchors.centerIn: parent
                    spacing: -1

                    Text {
                        text: Qt.formatDateTime(clock.date, "ddd").toUpperCase()
                        color: root.hovered ? Theme.primary : Theme.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontTiny
                        font.weight: Font.DemiBold
                        font.letterSpacing: 0.6

                        Behavior on color {
                            ColorAnimation {
                                duration: Motion.fast
                            }
                        }
                    }

                    Text {
                        text: Qt.formatDateTime(clock.date, "d MMM")
                        color: Theme.alpha(Theme.textMuted, 0.75)
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontTiny
                    }
                }
            }
        }
    }

    Panel {
        target: root
        open: root.panelOpen
        onDismissed: Panels.close()
        panelWidth: 296
        panelHeight: 316

        content: Component {
            Calendar {
                date: clock.date
            }
        }
    }
}
