import QtQuick
import Quickshell
import Quickshell.Widgets
import ".." // Theme, Motion, BarState

// A floating bar made of separate islands rather than one slab, so each group
// can grow, shrink or vanish on its own without disturbing the others.
PanelWindow {
    id: bar

    color: "transparent"
    implicitHeight: Theme.barHeight
    // Tucking the bar away also gives its space back to the windows.
    exclusiveZone: BarState.hidden ? 0 : Theme.barHeight + Theme.barMarginTop - Theme.exclusiveTrim
    margins.top: BarState.hidden ? -Theme.barHeight - 4 : Theme.barMarginTop

    Behavior on margins.top {
        NumberAnimation {
            duration: Motion.normal
            easing.type: Easing.Bezier
            easing.bezierCurve: Motion.emphasized
        }
    }

    anchors {
        top: true
        left: true
        right: true
    }

    component Island: WrapperRectangle {
        id: island

        // Each island drops in on its own beat at start-up, left to right.
        property int entranceDelay: 0

        radius: Theme.radiusFull
        color: Theme.alpha(Theme.surfaceContainer, Theme.islandAlpha)
        margin: Theme.islandPadding
        border.width: 1
        border.color: Theme.alpha(Theme.outlineVariant, 0.45)

        opacity: 0
        y: -Theme.barHeight

        ParallelAnimation {
            id: entrance

            NumberAnimation {
                target: island
                property: "opacity"
                to: 1
                duration: Motion.slow
            }
            NumberAnimation {
                target: island
                property: "y"
                to: 0
                duration: Motion.slow
                easing.type: Easing.Bezier
                easing.bezierCurve: Motion.bounce
            }
        }

        Timer {
            interval: 120 + island.entranceDelay
            running: true
            onTriggered: entrance.start()
        }
    }

    // ── left ──────────────────────────────────────────────────────────────
    Row {
        anchors.left: parent.left
        anchors.leftMargin: Theme.barMarginSide
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.islandGap

        Island {
            entranceDelay: 0

            Row {
                spacing: Theme.moduleGap

                Launcher {}
                Workspaces {
                    screen: bar.screen
                }
            }
        }

        Island {
            entranceDelay: 60
            visible: title.implicitWidth > 0

            ActiveWindow {
                id: title

                screen: bar.screen
            }
        }
    }

    // ── centre ────────────────────────────────────────────────────────────
    Island {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        Clock {
            screenName: bar.screen.name
        }
    }

    // ── right ─────────────────────────────────────────────────────────────
    Row {
        anchors.right: parent.right
        anchors.rightMargin: Theme.barMarginSide
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.islandGap

        Island {
            entranceDelay: 200
            visible: media.implicitWidth > 0

            Row {
                spacing: Theme.moduleGap

                Cava {}
                Media {
                    id: media
                }
            }
        }

        Island {
            entranceDelay: 140
            visible: tray.implicitWidth > 0

            Tray {
                id: tray
            }
        }

        Island {
            entranceDelay: 100

            Row {
                spacing: Theme.moduleGap

                Resources {}
                Volume {}
                NetworkStatus {}
                Battery {}
                PowerProfile {}
                Notifications {}
                PowerMenu {
                    screenName: bar.screen.name
                }
            }
        }
    }
}
