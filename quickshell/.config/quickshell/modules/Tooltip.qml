import QtQuick
import Quickshell
import ".." // Theme, Motion

// Hover label, hung under the module that owns it. Waits a beat before showing
// so sweeping the cursor across the bar does not strobe.
Item {
    id: root

    property Item target: null
    property string text: ""
    property bool shown: false
    property int delay: 350

    property bool open: false

    onShownChanged: shown ? timer.start() : (timer.stop(), root.open = false)

    Timer {
        id: timer

        interval: root.delay
        onTriggered: root.open = true
    }

    LazyLoader {
        active: root.open && root.text !== "" && root.target !== null

        PopupWindow {
            id: popup

            visible: true
            color: "transparent"

            anchor.window: root.target?.QsWindow.window ?? null
            anchor.rect.x: {
                const centre = root.target.mapToItem(null, root.target.width / 2, 0).x;
                return Math.round(centre - implicitWidth / 2);
            }
            anchor.rect.y: Theme.barHeight + 6

            implicitWidth: body.implicitWidth + 22
            implicitHeight: body.implicitHeight + 14

            Rectangle {
                anchors.fill: parent
                anchors.margins: 1
                radius: Theme.radiusSmall
                color: Theme.alpha(Theme.surfaceHigh, 0.97)
                border.width: 1
                border.color: Theme.alpha(Theme.outlineVariant, 0.6)

                opacity: 0
                scale: 0.9
                Component.onCompleted: {
                    opacity = 1;
                    scale = 1;
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: Motion.fast
                    }
                }
                Behavior on scale {
                    NumberAnimation {
                        duration: Motion.normal
                        easing.type: Easing.Bezier
                        easing.bezierCurve: Motion.bounce
                    }
                }

                Text {
                    id: body

                    anchors.centerIn: parent
                    text: root.text
                    color: Theme.text
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSmall
                }
            }
        }
    }
}
