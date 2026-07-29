import QtQuick
import Quickshell
import Quickshell.Networking
import ".." // Theme, Motion, Services

// Quickshell's Networking service only exposes wireless devices, so wifi comes
// from it directly while the wired link is read through nmcli.
ModuleButton {
    id: root

    readonly property NetworkDevice wifiDevice: Networking.devices.values.find(d => d.type === DeviceType.Wifi && d.connected) ?? null
    readonly property var wifiNetwork: wifiDevice?.networks.values.find(n => n.connected) ?? null
    readonly property var wifiIcons: ["\u{f092f}", "\u{f091f}", "\u{f0922}", "\u{f0925}", "\u{f0928}"]

    readonly property bool wiredConnected: Services.wiredConnected

    readonly property bool online: wifiDevice !== null || wiredConnected

    icon: {
        if (wifiDevice)
            return wifiIcons[Math.min(4, Math.floor((wifiNetwork?.signalStrength ?? 0) / 25))];
        return wiredConnected ? "\uef44" : "\u{f092d}";
    }
    foreground: online ? Theme.textMuted : Theme.error
    tooltipText: {
        if (wifiDevice)
            return `${wifiNetwork?.name ?? ""} · ${wifiNetwork?.signalStrength ?? 0}%`;
        if (wiredConnected)
            return `${Services.wiredInterface} · ${Services.wiredAddress}`;
        return "Hors ligne";
    }
    padding: 10

    onClicked: Quickshell.execDetached(["nm-connection-editor"])

}
