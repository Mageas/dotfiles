import QtQuick
import ".." // Theme, Motion

// Month grid for the clock panel. The arrows page through months; "today" only
// lights up when you are looking at the current one.
Item {
    id: root

    property date date: new Date()
    property int offset: 0

    readonly property date viewed: new Date(date.getFullYear(), date.getMonth() + offset, 1)
    readonly property int daysInMonth: new Date(viewed.getFullYear(), viewed.getMonth() + 1, 0).getDate()

    // Monday-first.
    readonly property int leading: (new Date(viewed.getFullYear(), viewed.getMonth(), 1).getDay() + 6) % 7
    readonly property int columnWidth: (width - 36) / 7

    readonly property var cells: {
        const out = [];
        for (let i = 0; i < leading; i++)
            out.push(0);
        for (let d = 1; d <= daysInMonth; d++)
            out.push(d);
        while (out.length % 7 !== 0)
            out.push(0);
        return out;
    }

    function isToday(day) {
        return offset === 0 && day === date.getDate();
    }

    Column {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 10

        Item {
            width: parent.width
            height: 30

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: Qt.formatDateTime(root.viewed, "MMMM yyyy")
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontLarge
                font.weight: Font.DemiBold
            }

            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                Repeater {
                    model: [
                        {
                            glyph: "\u{f0141}",
                            step: -1
                        },
                        {
                            glyph: "\u{f0142}",
                            step: 1
                        }
                    ]

                    Rectangle {
                        id: arrowButton

                        required property var modelData

                        width: 26
                        height: 26
                        radius: 13
                        color: arrow.containsMouse ? Theme.alpha(Theme.text, 0.1) : "transparent"
                        scale: arrow.pressed ? 0.9 : 1

                        Behavior on color {
                            ColorAnimation {
                                duration: Motion.fast
                            }
                        }
                        Behavior on scale {
                            NumberAnimation {
                                duration: Motion.fast
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: arrowButton.modelData.glyph
                            color: Theme.textMuted
                            font.family: Theme.iconFamily
                            font.pixelSize: Theme.fontNormal
                        }

                        MouseArea {
                            id: arrow

                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: root.offset += arrowButton.modelData.step
                        }
                    }
                }
            }
        }

        Row {
            width: parent.width

            Repeater {
                model: ["L", "M", "M", "J", "V", "S", "D"]

                Text {
                    required property string modelData

                    width: root.columnWidth
                    horizontalAlignment: Text.AlignHCenter
                    text: modelData
                    color: Theme.alpha(Theme.textMuted, 0.55)
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontTiny
                    font.weight: Font.DemiBold
                }
            }
        }

        Grid {
            columns: 7
            width: parent.width

            Repeater {
                model: root.cells

                Item {
                    id: cell

                    required property int modelData
                    required property int index

                    readonly property bool today: root.isToday(modelData)

                    width: root.columnWidth
                    height: 32

                    Rectangle {
                        id: disc

                        anchors.centerIn: parent
                        width: 28
                        height: 28
                        radius: 14
                        visible: cell.modelData > 0
                        color: cell.today ? Theme.primary : hover.containsMouse ? Theme.alpha(Theme.text, 0.08) : "transparent"

                        // The grid assembles itself instead of blinking into
                        // place. Only opacity and scale are animated — x and y
                        // belong to the Grid, and touching them collapses the
                        // rows on top of each other.
                        opacity: 0
                        scale: 0.6

                        Behavior on color {
                            ColorAnimation {
                                duration: Motion.fast
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: cell.modelData
                            color: cell.today ? Theme.textOnPrimary : Theme.textMuted
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSmall
                            font.weight: cell.today ? Font.DemiBold : Font.Normal
                        }

                        MouseArea {
                            id: hover

                            anchors.fill: parent
                            hoverEnabled: cell.modelData > 0
                        }
                    }

                    ParallelAnimation {
                        id: entrance

                        NumberAnimation {
                            target: disc
                            property: "opacity"
                            to: 1
                            duration: Motion.normal
                        }
                        NumberAnimation {
                            target: disc
                            property: "scale"
                            to: 1
                            duration: Motion.normal
                            easing.type: Easing.Bezier
                            easing.bezierCurve: Motion.bounce
                        }
                    }

                    Timer {
                        interval: 12 * cell.index
                        running: true
                        onTriggered: entrance.start()
                    }
                }
            }
        }
    }
}
