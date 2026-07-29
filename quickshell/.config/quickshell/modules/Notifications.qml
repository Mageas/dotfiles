import QtQuick
import Quickshell
import ".." // Theme, Motion, Services

// swaync bell. `swaync-client -swb` streams one JSON object per state change;
// the count rides along as a badge that pops when it grows.
ModuleButton {
    id: root

    readonly property string state: Services.notificationState
    readonly property int count: Services.notificationCount

    readonly property bool dnd: state.startsWith("dnd")

    icon: dnd ? "\uf1f7" : "\uf0a2"
    foreground: dnd ? Theme.alpha(Theme.textMuted, 0.5) : Theme.textMuted
    tooltipText: dnd ? "Ne pas déranger" : count > 0 ? `${count} notification${count > 1 ? "s" : ""}` : "Notifications"
    padding: 10
    spacing: 0

    onClicked: button => {
        if (button === Qt.RightButton)
            Quickshell.execDetached(["swaync-client", "-d", "-sw"]);
        else
            Quickshell.execDetached(["swaync-client", "-t", "-sw"]);
    }

    onHoveredChanged: if (hovered) swing.restart()

    // Four decaying swings; the bell rings rather than merely tilting.
    SequentialAnimation {
        id: swing

        NumberAnimation {
            target: root
            property: "iconRotation"
            to: -14
            duration: Motion.fast
            easing.type: Easing.OutQuad
        }
        NumberAnimation {
            target: root
            property: "iconRotation"
            to: 11
            duration: Motion.normal
            easing.type: Easing.InOutQuad
        }
        NumberAnimation {
            target: root
            property: "iconRotation"
            to: -6
            duration: Motion.fast
            easing.type: Easing.InOutQuad
        }
        NumberAnimation {
            target: root
            property: "iconRotation"
            to: 0
            duration: Motion.normal
            easing.type: Easing.Bezier
            easing.bezierCurve: Motion.bounce
        }
    }

    extra: Component {
        // Badge sits over the bell's shoulder rather than beside it, so the
        // module's width never shifts as notifications arrive.
        Item {
            width: 0
            height: parent.height

            Rectangle {
                id: badge

                x: -7
                y: 2
                width: 15
                height: 15
                radius: 7.5
                color: Theme.error
                visible: root.count > 0
                scale: root.count > 0 ? 1 : 0

                Behavior on scale {
                    NumberAnimation {
                        duration: Motion.normal
                        easing.type: Easing.Bezier
                        easing.bezierCurve: Motion.bounce
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: root.count > 9 ? "9+" : root.count
                    color: Theme.textOnError
                    font.family: Theme.fontFamily
                    font.pixelSize: 9
                    font.weight: Font.Bold
                }
            }

            // Lives inside the component so it can reach the badge; the button
            // itself has no handle on the loaded content.
            Connections {
                target: root

                function onCountChanged() {
                    if (root.count > 0)
                        pop.restart();
                }
            }

            SequentialAnimation {
                id: pop

                NumberAnimation {
                    target: badge
                    property: "scale"
                    to: 1.45
                    duration: Motion.fast
                    easing.type: Easing.OutQuad
                }
                NumberAnimation {
                    target: badge
                    property: "scale"
                    to: 1
                    duration: Motion.normal
                    easing.type: Easing.Bezier
                    easing.bezierCurve: Motion.bounce
                }
            }
        }
    }

}
