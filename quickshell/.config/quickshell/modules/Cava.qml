import QtQuick
import ".." // Theme, Motion, Services

// Live spectrum. The cava process itself lives in Services so both monitors
// share one; this is only the drawing.
Item {
    id: root

    implicitWidth: Services.audioPlaying ? Services.spectrumBars * 4 - 2 : 0
    implicitHeight: Theme.barHeight - Theme.islandPadding * 2
    opacity: Services.audioPlaying ? 1 : 0
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
            duration: Motion.normal
        }
    }

    Row {
        anchors.centerIn: parent
        spacing: 2

        Repeater {
            model: Services.spectrumBars

            // Each bar sits in a full-height slot and grows symmetrically about
            // the centre. Sizing the slot to the bar instead would make the row
            // itself breathe with the music.
            Item {
                required property int index

                readonly property real level: Services.spectrum[index] ?? 0

                width: 2
                height: root.implicitHeight

                Rectangle {
                    anchors.centerIn: parent
                    width: 2
                    height: Math.max(2, parent.level * 18)
                    radius: 1

                    // Sweep the accent across the spectrum: bass in `primary`,
                    // treble in `tertiary`.
                    color: Qt.tint(Theme.primary, Theme.alpha(Theme.tertiary, parent.index / Services.spectrumBars))

                    Behavior on height {
                        NumberAnimation {
                            duration: 90
                            easing.type: Easing.OutQuad
                        }
                    }
                }
            }
        }
    }
}
