import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Hyprland
import ".." // Theme, Motion, WallpaperStore

// Wallpaper and theme picker. Each tile carries the palette that wallpaper
// would generate, so the choice is about the whole colour scheme and not just
// the picture. Arrows move, Enter applies, Escape leaves.
Scope {
    id: root

    // Prefer even rows: four wallpapers read better as a 2x2 than as 3 + 1.
    readonly property int columns: {
        const count = Math.max(1, WallpaperStore.entries.length);
        if (count <= 3)
            return count;
        if (count % 3 === 0)
            return 3;
        return Math.min(3, Math.ceil(count / 2));
    }

    readonly property int tileWidth: 300
    readonly property int tileHeight: 226
    readonly property int gap: 18

    property int selected: 0

    onSelectedChanged: {
        const count = WallpaperStore.entries.length;
        if (count === 0)
            return;
        root.selected = ((selected % count) + count) % count;
    }

    LazyLoader {
        active: WallpaperStore.open

        PanelWindow {
            id: overlay

            screen: {
                const wanted = Hyprland.focusedMonitor?.name ?? "";
                return Quickshell.screens.find(s => s.name === wanted) ?? null;
            }

            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            focusable: true
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            // Dim everything behind, and take the click that closes.
            Rectangle {
                anchors.fill: parent
                color: Theme.alpha(Theme.shadow, 0.55)

                opacity: 0
                Component.onCompleted: opacity = 1

                Behavior on opacity {
                    NumberAnimation {
                        duration: Motion.normal
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: WallpaperStore.close()
                }
            }

            Item {
                anchors.fill: parent
                focus: true

                Keys.onEscapePressed: WallpaperStore.close()
                Keys.onLeftPressed: root.selected -= 1
                Keys.onRightPressed: root.selected += 1
                Keys.onUpPressed: root.selected -= root.columns
                Keys.onDownPressed: root.selected += root.columns
                Keys.onReturnPressed: root.applySelected()
                Keys.onEnterPressed: root.applySelected()

                Rectangle {
                    id: card

                    anchors.centerIn: parent
                    width: grid.width + 56
                    height: grid.height + header.height + 76

                    radius: 28
                    color: Theme.alpha(Theme.surfaceContainer, 0.98)

                    opacity: 0
                    scale: 0.94

                    Component.onCompleted: {
                        opacity = 1;
                        scale = 1;
                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Motion.normal
                        }
                    }
                    Behavior on scale {
                        NumberAnimation {
                            duration: Motion.slow
                            easing.type: Easing.Bezier
                            easing.bezierCurve: Motion.bounce
                        }
                    }

                    // Clicks on the card itself must not reach the scrim.
                    MouseArea {
                        anchors.fill: parent
                    }

                    Column {
                        id: header

                        anchors.top: parent.top
                        anchors.topMargin: 26
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 3

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Thème"
                            color: Theme.text
                            font.family: Theme.fontFamily
                            font.pixelSize: 20
                            font.weight: Font.DemiBold
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: WallpaperStore.applying ? "Application en cours…" : "Le fond d'écran donne la palette de tout le bureau"
                            color: Theme.textMuted
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSmall
                        }
                    }

                    Grid {
                        id: grid

                        anchors.top: header.bottom
                        anchors.topMargin: 22
                        anchors.horizontalCenter: parent.horizontalCenter

                        columns: root.columns
                        spacing: root.gap

                        Repeater {
                            model: WallpaperStore.entries

                            Item {
                                id: tile

                                required property var modelData
                                required property int index

                                readonly property bool chosen: root.selected === index
                                readonly property bool live: WallpaperStore.current === modelData.file
                                readonly property bool lit: chosen || hover.containsMouse

                                width: root.tileWidth
                                height: root.tileHeight

                                // Lifts and grows under the cursor or the
                                // keyboard cursor — no outline, the motion and
                                // the accent bar carry the state.
                                //
                                // The lift is a transform, not a `y`: the Grid
                                // owns x and y, and writing to them collapses
                                // every row onto the first.
                                scale: lit ? 1.03 : 1

                                transform: Translate {
                                    y: tile.lit ? -6 : 0

                                    Behavior on y {
                                        NumberAnimation {
                                            duration: Motion.normal
                                            easing.type: Easing.Bezier
                                            easing.bezierCurve: Motion.emphasized
                                        }
                                    }
                                }

                                Behavior on scale {
                                    NumberAnimation {
                                        duration: Motion.normal
                                        easing.type: Easing.Bezier
                                        easing.bezierCurve: Motion.bounce
                                    }
                                }

                                Column {
                                    anchors.fill: parent
                                    spacing: 8

                                    ClippingRectangle {
                                        width: parent.width
                                        height: 168
                                        radius: 16
                                        color: Theme.surfaceHigh

                                        Image {
                                            anchors.fill: parent
                                            source: "file://" + tile.modelData.path
                                            fillMode: Image.PreserveAspectCrop
                                            asynchronous: true
                                            sourceSize.width: 500

                                            // A slow push-in on hover, clipped
                                            // by the rounded frame.
                                            scale: tile.lit ? 1.06 : 1

                                            Behavior on scale {
                                                NumberAnimation {
                                                    duration: Motion.slow
                                                    easing.type: Easing.Bezier
                                                    easing.bezierCurve: Motion.emphasized
                                                }
                                            }
                                        }

                                        // Marks the wallpaper already in use.
                                        Rectangle {
                                            anchors.top: parent.top
                                            anchors.right: parent.right
                                            anchors.margins: 8
                                            width: 22
                                            height: 22
                                            radius: 11
                                            visible: tile.live
                                            color: Theme.primary

                                            Text {
                                                anchors.centerIn: parent
                                                text: "\u{f012c}"
                                                color: Theme.textOnPrimary
                                                font.family: Theme.iconFamily
                                                font.pixelSize: 13
                                            }
                                        }
                                    }

                                    Row {
                                        width: parent.width
                                        spacing: 8

                                        Text {
                                            width: parent.width - swatches.width - 8
                                            elide: Text.ElideRight
                                            text: tile.modelData.name
                                            color: tile.lit ? Theme.text : Theme.textMuted
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.fontSmall
                                            font.weight: Font.Medium
                                            height: 18
                                            verticalAlignment: Text.AlignVCenter

                                            Behavior on color {
                                                ColorAnimation {
                                                    duration: Motion.fast
                                                }
                                            }
                                        }

                                        // The palette this wallpaper generates.
                                        Row {
                                            id: swatches

                                            spacing: 4
                                            height: 18

                                            Repeater {
                                                model: [tile.modelData.palette.primary, tile.modelData.palette.secondary, tile.modelData.palette.tertiary]

                                                Rectangle {
                                                    required property var modelData
                                                    required property int index

                                                    visible: modelData !== undefined
                                                    width: 12
                                                    height: 12
                                                    radius: 6
                                                    y: 3
                                                    color: modelData ?? "transparent"

                                                    // The swatches fan out when
                                                    // the tile wakes up.
                                                    scale: tile.lit ? 1.25 : 1

                                                    Behavior on scale {
                                                        NumberAnimation {
                                                            duration: Motion.normal + index * 40
                                                            easing.type: Easing.Bezier
                                                            easing.bezierCurve: Motion.bounce
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }

                                // Accent bar that grows from the middle, the
                                // same language as the bar's own modules.
                                Rectangle {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.top: parent.top
                                    anchors.topMargin: 174
                                    height: 3
                                    radius: 1.5
                                    color: Theme.primary
                                    width: tile.chosen ? parent.width * 0.5 : 0
                                    opacity: tile.chosen ? 1 : 0

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
                                    id: hover

                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onEntered: root.selected = tile.index
                                    onClicked: WallpaperStore.apply(tile.modelData.path)
                                }

                                // Staggered entrance, left to right.
                                opacity: 0
                                Component.onCompleted: reveal.start()

                                NumberAnimation {
                                    id: reveal

                                    target: tile
                                    property: "opacity"
                                    to: 1
                                    duration: Motion.normal
                                    easing.type: Easing.OutQuad
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    function applySelected() {
        const entry = WallpaperStore.entries[root.selected];
        if (entry)
            WallpaperStore.apply(entry.path);
    }
}
