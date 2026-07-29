import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import ".." // Theme, Motion

// Floating volume readout. Appears on the focused screen when the level or the
// mute state changes — from the media keys, the bar's own slider, or anything
// else on the system — then fades itself out.
//
// The first value that arrives after start-up is the *current* volume, not a
// change, so it is swallowed rather than flashed at the user on login.
Scope {
    id: root

    property bool armed: false
    property bool showing: false

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property real level: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false

    function flash() {
        if (!root.armed)
            return;
        root.showing = true;
        hide.restart();
    }

    onLevelChanged: root.flash()
    onMutedChanged: root.flash()

    PwObjectTracker {
        objects: root.sink ? [root.sink] : []
    }

    Timer {
        // Long enough for PipeWire to have settled on the real starting value.
        interval: 1200
        running: true
        onTriggered: root.armed = true
    }

    Timer {
        id: hide

        interval: 1600
        onTriggered: root.showing = false
    }

    LazyLoader {
        active: root.showing

        PanelWindow {
            id: window

            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            implicitWidth: 260
            implicitHeight: 76

            anchors {
                bottom: true
            }
            margins.bottom: 120

            // Sits on whichever screen currently has focus.
            screen: {
                const wanted = Hyprland.focusedMonitor?.name ?? "";
                return Quickshell.screens.find(s => s.name === wanted) ?? null;
            }

            Rectangle {
                id: card

                anchors.fill: parent
                radius: Theme.radiusPanel
                color: Theme.alpha(Theme.surfaceContainer, 0.96)
                border.width: 1
                border.color: Theme.alpha(Theme.outlineVariant, 0.5)

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

                Row {
                    anchors.centerIn: parent
                    spacing: 16

                    Text {
                        text: root.muted ? "\u{f0581}" : root.level > 0.5 ? "\u{f057e}" : "\u{f057f}"
                        color: root.muted ? Theme.textMuted : Theme.primary
                        font.family: Theme.iconFamily
                        font.pixelSize: 26
                        height: 44
                        verticalAlignment: Text.AlignVCenter
                    }

                    Item {
                        width: 150
                        height: 44

                        Text {
                            anchors.left: parent.left
                            anchors.bottom: bar.top
                            anchors.bottomMargin: 8
                            text: root.muted ? "Muet" : Math.round(root.level * 100) + "%"
                            color: Theme.text
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontNormal
                            font.weight: Font.DemiBold
                        }

                        Rectangle {
                            id: bar

                            anchors.verticalCenter: parent.verticalCenter
                            anchors.verticalCenterOffset: 8
                            width: parent.width
                            height: 6
                            radius: 3
                            color: Theme.alpha(Theme.textMuted, 0.25)

                            Rectangle {
                                width: parent.width * (root.muted ? 0 : root.level)
                                height: parent.height
                                radius: 3
                                color: Theme.primary

                                Behavior on width {
                                    NumberAnimation {
                                        duration: Motion.normal
                                        easing.type: Easing.Bezier
                                        easing.bezierCurve: Motion.emphasized
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
