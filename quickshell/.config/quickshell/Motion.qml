pragma Singleton

import QtQuick
import Quickshell

// One motion vocabulary for the whole shell, so every transition feels like it
// came from the same place. The curves are Material 3's: `standard` for things
// that simply move, `emphasized` for anything the eye should follow, and
// `bounce` for the playful bits (workspace pills, badges).
Singleton {
    readonly property int instant: 90
    readonly property int fast: 150
    readonly property int normal: 260
    readonly property int slow: 420
    readonly property int lazy: 700

    readonly property list<real> standard: [0.2, 0.0, 0.0, 1.0, 1, 1]
    readonly property list<real> emphasized: [0.05, 0.7, 0.1, 1.0, 1, 1]
    readonly property list<real> decelerate: [0.0, 0.0, 0.0, 1.0, 1, 1]
    readonly property list<real> bounce: [0.34, 1.56, 0.64, 1.0, 1, 1]
}
