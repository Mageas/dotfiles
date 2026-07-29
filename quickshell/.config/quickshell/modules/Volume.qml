import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import ".." // Theme, Motion

// Volume. Hovering unrolls a slider to the right of the icon — drag it, or
// scroll anywhere on the module.
ModuleButton {
    id: root

    readonly property string preferredSink: "alsa_output.pci-0000_0e_00.4.analog-stereo"

    readonly property PwNode sink: {
        const match = Pipewire.nodes.values.find(node => node.isSink && node.name === root.preferredSink);
        return match ?? Pipewire.defaultAudioSink;
    }

    readonly property real level: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false

    function setLevel(value) {
        if (sink?.audio)
            sink.audio.volume = Math.max(0, Math.min(1, value));
    }

    icon: muted ? "\u{f0581}" : level > 0.5 ? "\u{f057e}" : level > 0 ? "\u{f057f}" : "\u{f0580}"
    foreground: muted ? Theme.alpha(Theme.textMuted, 0.5) : Theme.textMuted
    tooltipText: hovered ? "" : (muted ? "Muet" : `Volume ${Math.round(level * 100)}%`)
    padding: 10
    spacing: 8

    onClicked: button => {
        if (button === Qt.RightButton)
            Quickshell.execDetached(["pavucontrol"]);
        else if (button === Qt.MiddleButton)
            Quickshell.execDetached(["easyeffects"]);
        else if (sink?.audio)
            sink.audio.muted = !sink.audio.muted;
    }

    onScrolled: delta => root.setLevel(root.level + (delta > 0 ? 0.05 : -0.05))

    extra: Component {
        Item {
            id: slider

            // Full button height so the track lands on the centre line; a Row
            // ignores anchors on its direct children.
            height: root.height
            width: root.hovered || drag.pressed ? 76 : 0
            clip: true

            // Tell the button the cursor is still on it while over the slider.
            Binding {
                target: root
                property: "extraHovered"
                value: drag.containsMouse || drag.pressed
            }

            Behavior on width {
                NumberAnimation {
                    duration: Motion.normal
                    easing.type: Easing.Bezier
                    easing.bezierCurve: Motion.emphasized
                }
            }

            Rectangle {
                id: track

                anchors.verticalCenter: parent.verticalCenter
                x: 3
                width: 70
                height: 4
                radius: 2
                color: Theme.alpha(Theme.textMuted, 0.25)

                Rectangle {
                    width: track.width * root.level
                    height: parent.height
                    radius: 2
                    color: root.muted ? Theme.alpha(Theme.textMuted, 0.4) : Theme.primary

                    Behavior on width {
                        NumberAnimation {
                            duration: Motion.fast
                            easing.type: Easing.Bezier
                            easing.bezierCurve: Motion.emphasized
                        }
                    }
                }

                Rectangle {
                    x: track.width * root.level - width / 2
                    anchors.verticalCenter: parent.verticalCenter
                    width: drag.pressed ? 13 : drag.containsMouse ? 11 : 9
                    height: width
                    radius: width / 2
                    color: root.muted ? Theme.textMuted : Theme.primary

                    Behavior on x {
                        NumberAnimation {
                            duration: Motion.fast
                            easing.type: Easing.Bezier
                            easing.bezierCurve: Motion.emphasized
                        }
                    }
                    Behavior on width {
                        NumberAnimation {
                            duration: Motion.normal
                            easing.type: Easing.Bezier
                            easing.bezierCurve: Motion.bounce
                        }
                    }
                }
            }

            MouseArea {
                id: drag

                anchors.fill: parent
                hoverEnabled: true
                onPressed: event => root.setLevel((event.x - track.x) / track.width)
                onPositionChanged: event => {
                    if (pressed)
                        root.setLevel((event.x - track.x) / track.width);
                }
                onWheel: event => root.scrolled(event.angleDelta.y)
            }
        }
    }

    // Keeps volume and mute live rather than fetched on demand.
    PwObjectTracker {
        objects: root.sink ? [root.sink] : []
    }
}
