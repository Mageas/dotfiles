import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Mpris
import ".." // Theme, Motion

// Now playing: album art, a title that scrolls only when it has to, and the
// track position drawn as a hairline under the text. Hovering swaps the art for
// transport controls.
Item {
    id: root

    readonly property MprisPlayer player: {
        const players = Mpris.players.values;
        const playing = players.filter(p => p.playbackState === MprisPlaybackState.Playing);
        if (playing.length > 0)
            return playing[playing.length - 1];
        return players.length > 0 ? players[players.length - 1] : null;
    }

    readonly property bool has: player !== null && (player.trackTitle ?? "") !== ""
    readonly property bool playing: player?.playbackState === MprisPlaybackState.Playing
    readonly property real progress: {
        if (!player || !player.lengthSupported || player.length <= 0)
            return 0;
        return Math.max(0, Math.min(1, player.position / player.length));
    }

    implicitWidth: has ? content.implicitWidth + 16 : 0
    implicitHeight: Theme.barHeight - Theme.islandPadding * 2
    opacity: has ? 1 : 0
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

    // MPRIS only pushes position on seek, so nudge it for a smooth bar.
    Timer {
        running: root.playing
        repeat: true
        interval: 1000
        onTriggered: root.player.positionChanged()
    }

    Rectangle {
        anchors.fill: parent
        radius: Theme.radiusModule
        color: hover.containsMouse ? Theme.alpha(Theme.text, 0.08) : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: Motion.fast
            }
        }
    }

    Row {
        id: content

        anchors.centerIn: parent
        anchors.verticalCenterOffset: hover.containsMouse ? -1 : 0
        spacing: 9

        Behavior on anchors.verticalCenterOffset {
            NumberAnimation {
                duration: Motion.normal
                easing.type: Easing.Bezier
                easing.bezierCurve: Motion.bounce
            }
        }

        // Art on the left, flipping to a play/pause button on hover.
        Item {
            width: 22
            height: root.implicitHeight

            ClippingRectangle {
                anchors.centerIn: parent
                width: 22
                height: 22
                radius: 6
                color: Theme.alpha(Theme.primary, 0.18)
                opacity: hover.containsMouse ? 0 : 1

                Behavior on opacity {
                    NumberAnimation {
                        duration: Motion.fast
                    }
                }

                Image {
                    anchors.fill: parent
                    source: root.player?.trackArtUrl ?? ""
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    cache: true
                }

                Text {
                    anchors.centerIn: parent
                    visible: (root.player?.trackArtUrl ?? "") === ""
                    text: ""
                    color: Theme.primary
                    font.family: Theme.iconFamily
                    font.pixelSize: 12
                }
            }

            Text {
                anchors.centerIn: parent
                text: root.playing ? "\uf28b" : "\uf144"
                color: Theme.primary
                font.family: Theme.iconFamily
                font.pixelSize: Theme.iconLarge
                opacity: hover.containsMouse ? 1 : 0
                scale: hover.containsMouse ? 1 : 0.6

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
            }
        }

        Item {
            width: stack.implicitWidth
            height: root.implicitHeight

            Column {
                id: stack

                anchors.centerIn: parent
                spacing: 3

                Marquee {
                    id: title

                    // Only as wide as the title needs, up to a ceiling — past that
                    // it scrolls rather than stretching the bar.
                    width: Math.min(textWidth, 200)
                    height: 15
                    text: root.player?.trackTitle ?? ""
                    color: Theme.text
                    pixelSize: Theme.fontSmall
                    weight: Font.Medium
                    paused: hover.containsMouse
                }

                // Position line. Doubles as the artist row's underline, so the
                // module keeps a fixed height whether or not length is known.
                Rectangle {
                    width: title.width
                    height: 2
                    radius: 1
                    color: Theme.alpha(Theme.textMuted, 0.22)

                    Rectangle {
                        width: parent.width * root.progress
                        height: parent.height
                        radius: 1
                        color: Theme.primary

                        Behavior on width {
                            NumberAnimation {
                                duration: Motion.slow
                                easing.type: Easing.Linear
                            }
                        }
                    }

                    // Click along the line to seek there. The generous margin
                    // makes a 2px target actually hittable.
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -6
                        enabled: (root.player?.canSeek ?? false) && (root.player?.lengthSupported ?? false)
                        onClicked: event => {
                            const ratio = Math.max(0, Math.min(1, (event.x + 6) / width));
                            root.player.position = ratio * root.player.length;
                        }
                    }
                }
            }
        }
    }

    MouseArea {
        id: hover

        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: event => {
            if (!root.player)
                return;
            if (event.button === Qt.RightButton)
                root.player.next();
            else
                root.player.togglePlaying();
        }
        onWheel: event => {
            if (!root.player)
                return;
            if (event.angleDelta.y > 0)
                root.player.next();
            else
                root.player.previous();
        }
    }

    Tooltip {
        target: root
        shown: hover.containsMouse
        text: root.player ? `${root.player.trackArtist ?? ""} — ${root.player.trackTitle ?? ""}` : ""
    }
}
