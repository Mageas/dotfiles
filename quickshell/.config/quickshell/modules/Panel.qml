import QtQuick
import Quickshell
import Quickshell.Wayland
import ".." // Theme, Motion

// A dropdown panel — calendar, power menu, anything richer than a tooltip.
//
// It is drawn inside a full-screen overlay rather than a PopupWindow anchored
// to the bar. HyprlandFocusGrab reported itself cleared the instant the panel
// appeared, closing it again before it could ever be seen; owning the whole
// screen makes click-to-dismiss just a MouseArea, with no ordering games
// between the panel and whatever is meant to catch the click behind it.
Item {
    id: root

    property Item target: null
    property bool open: false
    property int panelWidth: 300
    property int panelHeight: 200
    property Component content: null

    // The owner closes the panel; the panel never writes to its own `open`.
    signal dismissed

    LazyLoader {
        active: root.open && root.target !== null

        PanelWindow {
            id: overlay

            screen: root.target.QsWindow.window?.screen ?? null
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            // Anywhere outside the card dismisses.
            MouseArea {
                anchors.fill: parent
                onClicked: root.dismissed()
            }

            Rectangle {
                id: card

                // Centred under the module that opened it, kept on screen.
                x: {
                    const centre = root.target.mapToItem(null, root.target.width / 2, 0).x;
                    const limit = overlay.width - width - Theme.barMarginSide;
                    return Math.max(Theme.barMarginSide, Math.min(Math.round(centre - width / 2), limit));
                }
                y: Theme.barMarginTop + Theme.barHeight + 6

                width: root.panelWidth
                height: root.panelHeight

                radius: Theme.radiusPanel
                color: Theme.alpha(Theme.surfaceContainer, 0.97)
                border.width: 1
                border.color: Theme.alpha(Theme.outlineVariant, 0.55)
                clip: true

                opacity: 0
                scale: 0.92
                transformOrigin: Item.Top

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
                        easing.bezierCurve: Motion.emphasized
                    }
                }

                // Swallows clicks so they do not reach the dismiss layer.
                MouseArea {
                    anchors.fill: parent
                }

                Loader {
                    anchors.fill: parent
                    sourceComponent: root.content
                }
            }
        }
    }
}
