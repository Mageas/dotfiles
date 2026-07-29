pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

// The three feeds that need a helper process. They live here rather than in the
// modules so a two-monitor setup runs one cava, one `nmcli monitor` and one
// swaync watcher — not one of each per bar.
Singleton {
    id: root

    // ── spectrum ──────────────────────────────────────────────────────────
    readonly property int spectrumBars: 14
    property var spectrum: []

    readonly property bool audioPlaying: Mpris.players.values.some(p => p.playbackState === MprisPlaybackState.Playing)

    Process {
        // Only while something is actually playing; a silent desktop pays nothing.
        running: root.audioPlaying
        command: ["cava", "-p", Quickshell.shellPath("cava.conf")]

        stdout: SplitParser {
            onRead: data => {
                const parts = data.trim().split(";").filter(v => v !== "");
                if (parts.length < root.spectrumBars)
                    return;
                root.spectrum = parts.slice(0, root.spectrumBars).map(v => parseInt(v) / 100);
            }
        }
    }

    // ── wired network ─────────────────────────────────────────────────────
    // Quickshell's Networking service only exposes wireless devices, so the
    // ethernet link is read through nmcli.
    readonly property string wiredInterface: "enp6s0"

    property bool wiredPresent: false
    property bool wiredConnected: false
    property string wiredAddress: ""

    Process {
        id: query

        command: ["nmcli", "-t", "-f", "GENERAL.STATE,IP4.ADDRESS", "device", "show", root.wiredInterface]

        stdout: StdioCollector {
            onStreamFinished: {
                root.wiredPresent = text.trim() !== "";
                root.wiredConnected = false;
                root.wiredAddress = "";

                for (const line of text.split("\n")) {
                    const split = line.indexOf(":");
                    if (split === -1)
                        continue;
                    const key = line.slice(0, split);
                    const value = line.slice(split + 1);

                    if (key === "GENERAL.STATE")
                        root.wiredConnected = value.startsWith("100");
                    else if (key.startsWith("IP4.ADDRESS") && root.wiredAddress === "")
                        root.wiredAddress = value;
                }
            }
        }
    }

    Process {
        // `nmcli monitor` prints a line whenever anything changes.
        running: true
        command: ["nmcli", "monitor"]

        stdout: SplitParser {
            onRead: debounce.restart()
        }
    }

    Timer {
        id: debounce

        interval: 300
        onTriggered: query.running = true
    }

    Timer {
        interval: 30000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: query.running = true
    }

    // ── notifications ─────────────────────────────────────────────────────
    property string notificationState: "none"
    property int notificationCount: 0

    Process {
        running: true
        command: ["swaync-client", "-swb"]

        stdout: SplitParser {
            onRead: data => {
                try {
                    const payload = JSON.parse(data);
                    root.notificationState = payload.alt ?? "none";
                    root.notificationCount = parseInt(payload.text) || 0;
                } catch (e) {
                    root.notificationState = "none";
                    root.notificationCount = 0;
                }
            }
        }
    }
}
