import QtQuick
import Quickshell
import Quickshell.Io
import ".." // Theme, Motion

// CPU and memory as two small columns that fill from the bottom. Read straight
// from /proc — no helper process, no polling a shell every second.
ModuleButton {
    id: root

    property real cpu: 0
    property real memory: 0

    // /proc/stat is cumulative, so a sample is only meaningful against the last.
    property real lastBusy: 0
    property real lastTotal: 0

    tooltipText: `CPU ${Math.round(cpu * 100)}%   ·   RAM ${Math.round(memory * 100)}%`
    padding: 10
    spacing: 5

    onClicked: Quickshell.execDetached(["/bin/sh", "-c", "ghostty -e btop || kitty -e btop"])

    extra: Component {
        Row {
            spacing: 5

            Repeater {
                model: [
                    {
                        value: root.cpu,
                        tint: Theme.primary
                    },
                    {
                        value: root.memory,
                        tint: Theme.tertiary
                    }
                ]

                Item {
                    id: gauge

                    required property var modelData

                    width: 4
                    height: root.height

                    Rectangle {
                        id: gaugeTrack

                        anchors.centerIn: parent
                        width: 4
                        height: 18
                        radius: 2
                        color: Theme.alpha(Theme.textMuted, 0.2)
                    }

                    Rectangle {
                        anchors.bottom: gaugeTrack.bottom
                        anchors.horizontalCenter: gaugeTrack.horizontalCenter
                        width: gaugeTrack.width
                        height: Math.max(2, gaugeTrack.height * gauge.modelData.value)
                        radius: 2
                        color: gauge.modelData.value > 0.85 ? Theme.error : gauge.modelData.tint

                        Behavior on height {
                            NumberAnimation {
                                duration: Motion.slow
                                easing.type: Easing.Bezier
                                easing.bezierCurve: Motion.emphasized
                            }
                        }
                        Behavior on color {
                            ColorAnimation {
                                duration: Motion.normal
                            }
                        }
                    }
                }
            }
        }
    }

    FileView {
        id: stat

        path: "/proc/stat"
        printErrors: false

        onLoaded: {
            const fields = text().split("\n")[0].trim().split(/\s+/).slice(1).map(Number);
            const total = fields.reduce((a, b) => a + b, 0);
            const idle = fields[3] + (fields[4] ?? 0);
            const busy = total - idle;

            if (root.lastTotal > 0 && total > root.lastTotal)
                root.cpu = Math.max(0, Math.min(1, (busy - root.lastBusy) / (total - root.lastTotal)));

            root.lastBusy = busy;
            root.lastTotal = total;
        }
    }

    FileView {
        id: meminfo

        path: "/proc/meminfo"
        printErrors: false

        onLoaded: {
            const read = key => {
                const line = text().split("\n").find(l => l.startsWith(key));
                return line ? parseInt(line.replace(/\D+/g, "")) : 0;
            };
            const total = read("MemTotal:");
            const available = read("MemAvailable:");
            if (total > 0)
                root.memory = 1 - available / total;
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            stat.reload();
            meminfo.reload();
        }
    }
}
