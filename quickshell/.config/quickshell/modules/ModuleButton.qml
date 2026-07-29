import QtQuick
import ".." // Theme, Motion

// Every clickable thing in the bar: the hover wash, the press squash and the
// tooltip live here so modules only describe what they show.
//
// `icon` / `label` cover the common case; anything richer goes in `extra`,
// which is appended to the same row. (Deliberately not a default property —
// a default alias into the inner row would also swallow this component's own
// background and mouse area.)
//
// Direct children of a Row cannot use anchors, so everything in `layout` is
// given the button's full height and centres its own contents.
Item {
    id: root

    property string icon: ""
    property string label: ""
    property Component extra: null
    property string tooltipText: ""

    property int padding: Theme.modulePadding
    property real spacing: 7
    property color accent: Theme.primary
    property color foreground: Theme.textMuted
    property bool active: false
    property bool interactive: true

    // Modules drive this for their own flourish — a spin, a swing, a flip.
    property real iconRotation: 0

    // Content that carries its own MouseArea (the volume slider) swallows the
    // hover from the button's, and would otherwise make it collapse the moment
    // the cursor reached it.
    property bool extraHovered: false

    readonly property bool hovered: mouse.containsMouse || extraHovered
    readonly property bool pressed: mouse.pressed

    signal clicked(int button)
    signal scrolled(int delta)

    implicitWidth: layout.implicitWidth + padding * 2
    implicitHeight: Theme.barHeight - Theme.islandPadding * 2

    scale: mouse.pressed ? 0.93 : 1
    Behavior on scale {
        NumberAnimation {
            duration: Motion.fast
            easing.type: Easing.Bezier
            easing.bezierCurve: Motion.emphasized
        }
    }
    Behavior on implicitWidth {
        NumberAnimation {
            duration: Motion.normal
            easing.type: Easing.Bezier
            easing.bezierCurve: Motion.emphasized
        }
    }

    // The hover wash does not just fade — it springs out from the centre, so
    // the button feels like it reaches for the cursor.
    Rectangle {
        anchors.fill: parent
        radius: Theme.radiusModule
        color: {
            if (root.active)
                return Theme.alpha(root.accent, 0.22);
            if (mouse.pressed)
                return Theme.alpha(Theme.text, 0.16);
            return Theme.alpha(Theme.text, 0.10);
        }

        opacity: root.active || root.hovered ? 1 : 0
        scale: root.active || root.hovered ? 1 : 0.82

        Behavior on color {
            ColorAnimation {
                duration: Motion.fast
            }
        }
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

    // A hairline of accent that grows out of the middle on hover.
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 2
        height: 2
        radius: 1
        color: root.accent
        width: root.active || root.hovered ? parent.width * 0.42 : 0
        opacity: root.active || root.hovered ? 1 : 0

        Behavior on width {
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
    }

    MouseArea {
        id: mouse

        anchors.fill: parent
        enabled: root.interactive
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

        onClicked: event => root.clicked(event.button)
        onWheel: event => root.scrolled(event.angleDelta.y)
    }

    Row {
        id: layout

        anchors.centerIn: parent
        spacing: root.spacing

        Text {
            visible: root.icon !== ""
            text: root.icon
            color: root.active || root.hovered ? root.accent : root.foreground
            height: root.height
            verticalAlignment: Text.AlignVCenter
            font.family: Theme.iconFamily
            font.pixelSize: Theme.iconNormal

            // Icons bounce a little under the cursor and settle back.
            scale: root.hovered ? 1.16 : 1
            rotation: root.iconRotation

            Behavior on color {
                ColorAnimation {
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

        Text {
            visible: root.label !== ""
            text: root.label
            color: root.active ? root.accent : root.foreground
            height: root.height
            verticalAlignment: Text.AlignVCenter
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontNormal
            font.weight: Font.Medium

            Behavior on color {
                ColorAnimation {
                    duration: Motion.fast
                }
            }
        }

        Loader {
            height: root.height
            sourceComponent: root.extra
        }
    }

    Tooltip {
        target: root
        text: root.tooltipText
        shown: mouse.containsMouse && !mouse.pressed
    }
}
