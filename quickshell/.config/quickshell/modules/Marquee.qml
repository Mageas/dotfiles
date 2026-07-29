import QtQuick
import ".." // Theme, Motion

// Text that scrolls only when it overflows, pausing at each end so the title is
// actually readable. Short titles just sit still.
Item {
    id: root

    property string text: ""
    property color color: Theme.text
    property int pixelSize: Theme.fontSmall
    property int weight: Font.Normal
    property bool paused: false
    property int gap: 28

    readonly property real textWidth: label.implicitWidth
    readonly property bool overflowing: label.implicitWidth > width

    clip: true

    onTextChanged: {
        label.x = 0;
        cycle.restart();
    }

    Text {
        id: label

        y: (root.height - height) / 2
        text: root.text
        color: root.color
        font.family: Theme.fontFamily
        font.pixelSize: root.pixelSize
        font.weight: root.weight
    }

    // The tail copy only exists while scrolling, so it never widens the item.
    Text {
        visible: root.overflowing
        x: label.x + label.implicitWidth + root.gap
        y: label.y
        text: root.text
        color: root.color
        font: label.font
    }

    SequentialAnimation {
        id: cycle

        running: root.overflowing && !root.paused
        loops: Animation.Infinite

        PauseAnimation {
            duration: 2200
        }
        NumberAnimation {
            target: label
            property: "x"
            to: -(label.implicitWidth + root.gap)
            duration: Math.max(1, label.implicitWidth + root.gap) * 22
            easing.type: Easing.Linear
        }
        PropertyAction {
            target: label
            property: "x"
            value: 0
        }
    }
}
