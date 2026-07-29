import QtQuick
import Quickshell.Services.UPower
import ".." // Theme, Motion

// Hidden entirely on desktops. On a laptop the icon turns amber below 20% and
// red below 10%, and the percentage only appears when it starts to matter.
ModuleButton {
    id: root

    readonly property UPowerDevice device: UPower.displayDevice
    readonly property int percent: Math.round((device?.percentage ?? 0) * 100)
    readonly property bool charging: device?.state === UPowerDeviceState.Charging
    readonly property bool low: percent <= 20 && !charging

    readonly property var levelIcons: ["\u{f007a}", "\u{f007b}", "\u{f007c}", "\u{f007d}", "\u{f007e}", "\u{f007f}", "\u{f0080}", "\u{f0081}", "\u{f0082}", "\u{f0079}"]

    visible: device?.isLaptopBattery ?? false
    icon: charging ? "\u{f0084}" : levelIcons[Math.min(9, Math.floor(percent / 10))]
    label: low || charging ? percent + "%" : ""
    foreground: percent <= 10 && !charging ? Theme.error : low ? Theme.tertiary : Theme.textMuted
    tooltipText: {
        if (charging)
            return `En charge · ${percent}%`;
        const left = device?.timeToEmpty ?? 0;
        if (left > 0)
            return `${percent}% · ${Math.floor(left / 3600)}h${String(Math.floor(left % 3600 / 60)).padStart(2, "0")} restantes`;
        return `${percent}%`;
    }
    padding: 10

    // A slow pulse when the battery is genuinely low — impossible to miss,
    // easy to ignore once you have seen it.
    SequentialAnimation {
        running: root.low && root.visible
        loops: Animation.Infinite

        NumberAnimation {
            target: root
            property: "opacity"
            to: 0.45
            duration: Motion.lazy
            easing.type: Easing.InOutQuad
        }
        NumberAnimation {
            target: root
            property: "opacity"
            to: 1
            duration: Motion.lazy
            easing.type: Easing.InOutQuad
        }
    }
}
