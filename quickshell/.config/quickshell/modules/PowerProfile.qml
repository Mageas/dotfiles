import QtQuick
import Quickshell.Services.UPower
import ".." // Theme, Motion

// Clicking cycles power-saver → balanced → performance. The provider here is
// tuned-ppd, but it answers on the same bus name UPower.PowerProfiles reads.
ModuleButton {
    id: root

    readonly property string profileName: {
        switch (PowerProfiles.profile) {
        case PowerProfile.Performance:
            return "performance";
        case PowerProfile.PowerSaver:
            return "power-saver";
        case PowerProfile.Balanced:
            return "balanced";
        default:
            return "default";
        }
    }

    readonly property var icons: ({
            "performance": "\u{f0820}",
            "balanced": "\u{f0680}",
            "power-saver": "\u{f032a}",
            "default": ""
        })

    readonly property var tints: ({
            "performance": Theme.error,
            "balanced": Theme.textMuted,
            "power-saver": Theme.primary,
            "default": Theme.textMuted
        })

    icon: icons[profileName]
    foreground: tints[profileName]
    tooltipText: "Profil : " + profileName
    padding: 10

    onClicked: {
        if (PowerProfiles.profile === PowerProfile.PowerSaver)
            PowerProfiles.profile = PowerProfile.Balanced;
        else if (PowerProfiles.profile === PowerProfile.Balanced && PowerProfiles.hasPerformanceProfile)
            PowerProfiles.profile = PowerProfile.Performance;
        else
            PowerProfiles.profile = PowerProfile.PowerSaver;
    }

    // Spin a half turn whenever the profile actually changes, so the click has
    // a visible consequence beyond the glyph swapping.
    onProfileNameChanged: spin.restart()

    SequentialAnimation {
        id: spin

        NumberAnimation {
            target: root
            property: "iconRotation"
            from: 0
            to: 180
            duration: Motion.normal
            easing.type: Easing.Bezier
            easing.bezierCurve: Motion.emphasized
        }
        PropertyAction {
            target: root
            property: "iconRotation"
            value: 0
        }
    }
}
