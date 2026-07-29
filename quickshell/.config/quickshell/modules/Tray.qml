import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import ".." // Theme, Motion

// System tray. Icons lift slightly on hover; the whole island collapses when
// nothing is registered.
Item {
    id: root

    readonly property var items: SystemTray.items.values

    implicitWidth: items.length > 0 ? row.implicitWidth + 18 : 0
    implicitHeight: Theme.barHeight - Theme.islandPadding * 2
    opacity: items.length > 0 ? 1 : 0
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

    Row {
        id: row

        anchors.centerIn: parent
        spacing: 12

        Repeater {
            model: root.items

            MouseArea {
                id: entry

                required property SystemTrayItem modelData

                implicitWidth: 17
                implicitHeight: root.implicitHeight
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                hoverEnabled: true

                onClicked: event => {
                    if (event.button === Qt.RightButton || modelData.onlyMenu) {
                        if (modelData.hasMenu)
                            modelData.display(root.QsWindow.window, entry.mapToItem(null, width / 2, 0).x, Theme.barHeight);
                    } else if (event.button === Qt.MiddleButton) {
                        modelData.secondaryActivate();
                    } else {
                        modelData.activate();
                    }
                }

                IconImage {
                    anchors.centerIn: parent
                    width: 17
                    height: 17
                    source: entry.modelData.icon
                    asynchronous: true

                    scale: entry.containsMouse ? 1.25 : 1
                    y: entry.containsMouse ? -2 : 0
                    rotation: entry.containsMouse ? -6 : 0

                    Behavior on rotation {
                        NumberAnimation {
                            duration: Motion.normal
                            easing.type: Easing.Bezier
                            easing.bezierCurve: Motion.bounce
                        }
                    }

                    Behavior on scale {
                        NumberAnimation {
                            duration: Motion.normal
                            easing.type: Easing.Bezier
                            easing.bezierCurve: Motion.bounce
                        }
                    }
                    Behavior on y {
                        NumberAnimation {
                            duration: Motion.fast
                        }
                    }
                }

                Tooltip {
                    target: entry
                    shown: entry.containsMouse
                    text: entry.modelData.tooltipTitle || entry.modelData.title
                }
            }
        }
    }
}
